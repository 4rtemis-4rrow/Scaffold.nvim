local M = {}

local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")
local conf = require("telescope.config").values

local json = vim.fn.json_decode
local encode = vim.fn.json_encode
local mkdir = vim.fn.mkdir
local writefile = vim.fn.writefile
local readfile = vim.fn.readfile
local isdir = vim.fn.isdirectory
local scandir = vim.fn.readdir
local stat = vim.loop.fs_stat
local system = vim.fn.system
local input = vim.fn.input

local plugin_path = debug.getinfo(1, "S").source:sub(2):match("(.*/)")
local template_path = plugin_path .. "project_templates.json"

local function load_templates()
  local f = io.open(template_path, "r")
  if not f then return {} end
  local content = f:read("*a")
  f:close()
  return json(content)
end

local function save_templates(tbl)
  local encoded = encode(tbl, { indent = true })
  writefile(vim.split(encoded, "\n"), template_path)
end

local function interpolate_placeholders(content, vars)
  return (content:gsub("%${(.-)}", function(key)
    return vars[key] or ""
  end))
end

local function write_structure(tbl, base_path, vars)
  for name, value in pairs(tbl) do
    if name == "_meta" then goto continue end
    local name_interpolated = interpolate_placeholders(name, vars)
    local path = base_path .. "/" .. name_interpolated
    if type(value) == "string" then
      mkdir(vim.fn.fnamemodify(path, ":h"), "p")
      local content = interpolate_placeholders(value, vars)
      writefile(vim.split(content, "\n"), path)
    elseif type(value) == "table" then
      mkdir(path, "p")
      write_structure(value, path, vars)
    end
    ::continue::
  end
end

local function execute_hooks(hooks, dest)
  if type(hooks) ~= "table" then return end
  for _, cmd in ipairs(hooks) do
    system(cmd, dest)
  end
end

local function build_project(structure)
  local meta = structure._meta or {}
  local vars = {}

  if meta.variables then
    for k, default in pairs(meta.variables) do
      vars[k] = input(k .. " [" .. (default or "") .. "]: ") or default
    end
  end

  vim.ui.input({ prompt = "Destination folder: ", default = vim.fn.getcwd() }, function(dest)
    if not dest or dest == "" then return end
    mkdir(dest, "p")

    if meta.pre_gen then execute_hooks(meta.pre_gen, dest) end

    write_structure(structure, dest, vars)

    if meta.post_gen then execute_hooks(meta.post_gen, dest) end

    vim.notify("\u{2705} Project created at " .. dest, vim.log.levels.INFO)
  end)
end

function M.create_project()
  local templates = load_templates()
  local languages = vim.tbl_keys(templates)

  pickers.new({}, {
    prompt_title = "Select Language",
    finder = finders.new_table { results = languages },
    sorter = conf.generic_sorter({}),
    attach_mappings = function(buf1)
      actions.select_default:replace(function()
        local lang = action_state.get_selected_entry().value
        actions.close(buf1)

        local lang_templates = templates[lang]
        local template_names = vim.tbl_keys(lang_templates)

        pickers.new({}, {
          prompt_title = "Select Template (" .. lang .. ")",
          finder = finders.new_table { results = template_names },
          sorter = conf.generic_sorter({}),
          attach_mappings = function(buf2)
            actions.select_default:replace(function()
              local template = action_state.get_selected_entry().value
              local structure = lang_templates[template]
              actions.close(buf2)
              build_project(structure)
            end)
            return true
          end
        }):find()
      end)
      return true
    end
  }):find()
end

local function directory_to_table(path)
  local result = {}
  local entries = scandir(path)

  for _, entry in ipairs(entries) do
    local full = path .. "/" .. entry
    local stats = stat(full)
    if stats then
      if stats.type == "file" then
        result[entry] = table.concat(readfile(full), "\n")
      elseif stats.type == "directory" then
        result[entry] = directory_to_table(full)
      end
    end
  end

  return result
end

function M.add_template(args)
  local lang = args.fargs[1]
  local name = args.fargs[2]
  local path = args.fargs[3]

  if not isdir(path) then
    vim.notify("\u{274C} Invalid directory: " .. path, vim.log.levels.ERROR)
    return
  end

  local templates = load_templates()
  templates[lang] = templates[lang] or {}
  templates[lang][name] = directory_to_table(path)
  save_templates(templates)

  vim.notify("\u{2705} Template added: " .. lang .. " / " .. name, vim.log.levels.INFO)
end

vim.api.nvim_create_user_command("Scaffold", function()
  M.create_project()
end, {})

vim.api.nvim_create_user_command("AddTemplate", function(opts)
  M.add_template(opts)
end, {
  nargs = "*",
  complete = "file",
})

return M
