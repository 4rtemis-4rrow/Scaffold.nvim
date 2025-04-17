# Scaffold.nvim

**Scaffold.nvim** is a Neovim plugin for quickly scaffolding new projects using customizable templates. Define once, reuse forever, boost your workflow with smart, language-specific boilerplate generation.

---

## Installation

Requires **Neovim 0.8+** and **Telescope.nvim**.

### Using [lazy.nvim](https://github.com/folke/lazy.nvim)

```lua
{
  "4rtemis-4rrow/Scaffold.nvim",
  dependencies = { "nvim-telescope/telescope.nvim" },
  cmd = { "Scaffold", "AddTemplate" },
}
```

### Using [packer.nvim](https://github.com/wbthomason/packer.nvim)

```lua
use {
  "4rtemis-4rrow/Scaffold.nvim",
  requires = { "nvim-telescope/telescope.nvim" },
  cmd = { "Scaffold", "AddTemplate" },
}
```

---

## Setup

No setup required. The plugin is lazy-loaded via the `:Scaffold` and `:AddTemplate` commands.

---

## Usage

### Create a new project

```vim
:Scaffold
```

- Select a language (e.g. Python, Rust, etc.)
- Choose a template for that language
- Enter any requested variables (e.g. project name)
- Choose a destination path
- Your scaffolded project is created

---

### Add a new template

```vim
:AddTemplate <language> <template_name> <path_to_template_folder>
```

- `language`: Category (e.g. `rust`, `python`)
- `template_name`: Name of the template (e.g. `cli`, `web`)
- `path_to_template_folder`: The folder to turn into a template

This recursively saves the folder as a template in `project_templates.json`, capturing all structure and file contents.

---

### Template Format

Each template is stored as nested Lua tables (mirroring folder structure), with optional placeholders:

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

- `${project_name}` will be prompted and interpolated into files and folder names
- `_meta` supports:
  - `variables`: list of prompts and defaults
  - `pre_gen`: commands to run before generating files
  - `post_gen`: commands to run after

---

## Contributing

Contributions are welcome!

### To contribute:

1. Fork the repo
2. Add features or fix bugs
3. Open a pull request with a clear description
4. Bonus: Add a test template in `project_templates.json`

