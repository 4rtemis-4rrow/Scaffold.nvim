# Scaffold.nvim

**Scaffold.nvim** is a Neovim plugin for quickly scaffolding new projects using customizable templates. Define once, reuse forever, and boost your workflow with smart, language-specific boilerplate generation.

---

## Features

- 🧱 Easily scaffold projects from structured templates
- 🔁 Supports placeholder variables and lifecycle hooks
- 🔍 Picker-agnostic: works with `telescope.nvim`, `fzf-lua`, `mini.pick`, or `snacks.nvim`
- 📁 Templates stored in a readable JSON format

---

## Installation

Requires **Neovim 0.8+**.

### Using [lazy.nvim](https://github.com/folke/lazy.nvim)

```lua
{
  "4rtemis-4rrow/Scaffold.nvim",
  dependencies = {
    "nvim-telescope/telescope.nvim",  -- optional
    "ibhagwan/fzf-lua",               -- optional
    "echasnovski/mini.pick",          -- optional
    "tamton-aquib/snacks.nvim",       -- optional
  },
  cmd = { "Scaffold", "AddTemplate" },
}
```

### Using [packer.nvim](https://github.com/wbthomason/packer.nvim)

```lua
use {
  "4rtemis-4rrow/Scaffold.nvim",
  requires = {
    "nvim-telescope/telescope.nvim",  -- optional
    "ibhagwan/fzf-lua",               -- optional
    "echasnovski/mini.pick",          -- optional
    "tamton-aquib/snacks.nvim",       -- optional
  },
  cmd = { "Scaffold", "AddTemplate" },
}
```

---

## Setup

```lua
require("scaffold").setup({
  picker = "telescope", -- options: "telescope", "fzf-lua", "mini.pick", "snacks"
})
```

If no setup is called, the default picker used is `telescope`.

---

## Usage

### 🚀 Create a new project

```vim
:Scaffold
```

- Select a language (e.g. Python, Rust)
- Choose a template
- Fill in any placeholder variables
- Set the destination folder
- Project is scaffolded instantly!

### 🧩 Add a new template

```vim
:AddTemplate <language> <template_name> <path_to_template_folder>
```

- `language`: Template category (e.g. `rust`)
- `template_name`: Template name (e.g. `cli`)
- `path_to_template_folder`: Directory to turn into a reusable template

This will recursively serialize the folder into `project_templates.json`, storing file contents and structure.

---

## 🧠 Template Format

Each template is stored as a nested Lua-style JSON structure:

```json
{
  "python": {
    "cli": {
      "_meta": {
        "variables": {
          "project_name": "my_cli"
        },
        "pre_gen": ["echo 'Preparing...'"],
        "post_gen": ["echo 'Done!'"]
      },
      "${project_name}/main.py": "print('Hello, ${project_name}')"
    }
  }
}
```

- `${variable}` placeholders are replaced during generation
- `_meta` supports:
  - `variables`: prompts the user for values
  - `pre_gen`: commands to run *before* generating files
  - `post_gen`: commands to run *after* generation

---

## 🔧 Supported Pickers

Scaffold supports the following pickers:

| Picker       | Config Value | Required Plugin                         |
|--------------|--------------|------------------------------------------|
| Telescope    | `"telescope"`| `nvim-telescope/telescope.nvim`         |
| FZF-Lua      | `"fzf-lua"`  | `ibhagwan/fzf-lua`                      |
| Mini.pick    | `"mini.pick"`| `echasnovski/mini.pick`                 |
| Snacks.nvim  | `"snacks"`   | `tamton-aquib/snacks.nvim`             |

Switch pickers anytime by changing the `picker` in your setup.

---

## 🛠 Contributing

Contributions are welcome and appreciated!

### To contribute:

1. Fork this repository
2. Create your feature branch
3. Add your changes (features, fixes, templates, etc.)
4. Open a PR with a clear explanation

Bonus: add a test template to `project_templates.json` to demonstrate your feature 🚀

