Create a complete Neovim Lua plugin called `neogo.nvim` that provides a streamlined API for various Go development tools. This plugin should automate the installation of missing Go tools and provide a clean, context-aware API for calling these tools from within Neovim.

## Plugin Structure

The plugin should follow this structure:

```
neogo.nvim/
└── lua/
    └── neogo/
        ├── init.lua                  -- Main entry point, exposing the API
        ├── config.lua                -- Configuration management
        ├── tools.lua                 -- Tool definitions and auto-installation logic
        ├── utils.lua                 -- Shared utilities and error handling
        └── commands/                 -- Individual tool implementations
            ├── gomodifytags.lua
            ├── gotests.lua
            ├── iferr.lua
            ├── impl.lua
            ├── fillstruct.lua
            ├── fillswitch.lua
            └── goenum.lua
```

## Core Requirements

1. **API Focus**:

   - Provide a clean API without setting any keymaps
   - Allow users to configure and integrate functions into their own setup
   - Don't automatically invoke functionality based on events

2. **Tool Management**:

   - Automatically check if tools are installed
   - Install missing tools using `go install` or equivalent. Notify the user when installing
   - Provide functions to manually check/install tools

3. **Error Handling**:

   - Use Neovim's default notification system for errors
   - Provide meaningful error messages

4. **Configuration**:
   - Allow users to configure tool-specific options
   - Provide sensible defaults

## Tools to Implement

The plugin should integrate with the following Go tools:

1. **gomodifytags**:

   - Functions to add, modify, or remove struct tags
   - Support for common tag types (json, xml, yaml, etc.)
   - Work with current cursor position/selection

2. **gotests**:

   - Generate test stubs for functions/methods
   - Create table-driven test templates
   - Support various test naming conventions

3. **iferr**:

   - Insert boilerplate error-checking snippets
   - Support contextual insertion

4. **impl**:

   - Auto-generate method stubs for implementing interfaces
   - Accept interface name and receiver type as inputs
   - Insert at appropriate location

5. **fillstruct**:

   - Auto-fill struct literals with default or placeholder values
   - Work with cursor position

6. **fillswitch**:

   - Generate switch-case branches for enumerated types
   - Support for adding default cases

7. **goenum**:
   - Automate generation of enumerated types and helper functions
   - Support customization of generated code

## API Design Guidelines

1. Each function should be context-aware (take the cursor's position, the file name, ...)
2. Functions should accept clear parameters for their operation if necessary
3. Consistent return values/patterns across all commands
4. All functions should be properly documented and typed

## Implementation Details

1. **init.lua**:

   - Expose a setup function for configuration
   - Export all command functions in a clean namespace
   - Provide version information

2. **config.lua**:

   - Store and validate configuration options
   - Provide defaults for all configurable options

3. **tools.lua**:

   - Define required tools, their installation commands
   - Functions to check and install tools
   - Utilities to execute tool commands

4. **utils.lua**:

   - Helper functions for buffer/cursor manipulation
   - Error handling and notification utilities
   - Common operations used across command modules

5. **command modules**:
   - Each tool gets its own module with a consistent interface
   - Support for tool-specific options
   - Handle appropriate error conditions

```lua
-- In user's init.lua
require('neogo').setup({
  -- Optional configuration
  tools = {
    gomodifytags = {
      -- Tool-specific options
    },
    -- Other tool configurations
  }
})

-- Example keybinding setup (to be done by the user)
vim.keymap.set('n', '<leader>gt', require('neogo').gotests.generate_for_function, { buffer = true })
vim.keymap.set('n', '<leader>gf', require('neogo').fillstruct.at_cursor, { buffer = true })
```

Implement this plugin with clean, maintainable code. The code and function should use annotation to explicitly type the objects. The plugin should be implemented as a first draft, it should be functioning but it doesn't need to be 'production-ready'.
