# neogo.nvim

Neogo.nvim is a Neovim plugin that streamlines Go development by providing a clean, context-aware API for various Go tools. It automatically installs missing tools and integrates their functionality directly into your Neovim workflow, all without imposing preset keymaps.

---

## Features

- **Streamlined API:**  
  Exposes a clean API that you can integrate with your own key mappings or commands.

- **Automatic Tool Management:**  
  Checks for and installs missing Go tools (e.g., `gomodifytags`, `gotests`, `iferr`, `impl`, `fillstruct`, `fillswitch`, `goenum`) using `go install`.

- **Context-Aware Execution:**  
  Retrieves the current file, cursor position, and indentation to insert generated code exactly where needed.

- **Built-In Notifications:**  
  Leverages Neovim's notification system to provide success and error messages.

- **Reusable Utilities:**  
  Common operations like calculating byte offsets and inserting text after the current line are abstracted in shared utilities for consistency across tools.

---

## Installation

### Using [packer.nvim](https://github.com/wbthomason/packer.nvim)

Add the following to your `init.lua` or Neovim configuration:

```lua
use {
  'yourusername/neogo.nvim',
  config = function()
    require('neogo').setup({
      -- Optional: Override default tool configurations
      tools = {
        gomodifytags = {
          cmd = "gomodifytags",
          install_cmd = "go install github.com/fatih/gomodifytags@latest",
        },
        gotests = {
          cmd = "gotests",
          install_cmd = "go install github.com/cweill/gotests/...@latest",
        },
        iferr = {
          cmd = "iferr",
          install_cmd = "go install github.com/surullabs/iferr@latest",
        },
        impl = {
          cmd = "impl",
          install_cmd = "go install github.com/josharian/impl@latest",
        },
        fillstruct = {
          cmd = "fillstruct",
          install_cmd = "go install github.com/davidrjonas/fillstruct@latest",
        },
        fillswitch = {
          cmd = "fillswitch",
          install_cmd = "go install github.com/davidrjonas/fillswitch@latest",
        },
        goenum = {
          cmd = "goenum",
          install_cmd = "go install github.com/cweill/goenum@latest",
        },
      },
    })
  end
}
```

---

## Usage

Neogo.nvim exposes all functionality via the `neogo` module. It does not bind any keys by default, giving you full control over integration and key mappings.

### Example Keybindings

Configure your custom keybindings in your Neovim configuration:

```lua
local neogo = require('neogo')

-- Generate tests for the function under the cursor.
vim.keymap.set('n', '<leader>gt', neogo.gotests.generate_for_function, { buffer = true })

-- Fill struct literal at cursor position.
vim.keymap.set('n', '<leader>gf', neogo.fillstruct.at_cursor, { buffer = true })

-- Insert error-checking snippet.
vim.keymap.set('n', '<leader>ie', neogo.iferr.insert, { buffer = true })

-- Modify struct tags.
vim.keymap.set('n', '<leader>mt', function()
  neogo.gomodifytags.modify({ field = "MyField", new_tag = "json" })
end, { buffer = true })
```

---

## API Overview

### Setup

- **`neogo.setup(config: table?)`**  
  Initializes the plugin with optional configuration.

### Tool-Specific Commands

- **gomodifytags:**

  - `neogo.gomodifytags.add(opts: table?)`
  - `neogo.gomodifytags.modify(opts: table?)`
  - `neogo.gomodifytags.remove(opts: table?)`

- **gotests:**

  - `neogo.gotests.generate_for_function(opts: table?)`
  - `neogo.gotests.generate_table_tests(opts: table?)`

- **iferr:**

  - `neogo.iferr.insert(opts: { message?: string }?)`

- **impl:**

  - `neogo.impl.generate(interface_name: string, receiver: string)`

- **fillstruct:**

  - `neogo.fillstruct.at_cursor(opts: table?)`

- **fillswitch:**

  - `neogo.fillswitch.generate(opts: table?)`

- **goenum:**
  - `neogo.goenum.generate(opts: table?)`

Each function takes care of:

- Retrieving the current file and cursor position.
- Calculating byte offsets where necessary.
- Inserting tool output into the buffer with correct indentation.
- Providing notifications on success or failure.

---

## Configuration

You can customize the tool-specific options during setup. For example, to override the installation command for `iferr`:

```lua
require('neogo').setup({
  tools = {
    iferr = {
      cmd = "iferr", -- Default command name
      install_cmd = "go install github.com/surullabs/iferr@latest", -- Custom install command if needed
    },
    -- You can similarly configure other tools.
  }
})
```
