# ez-multi-cursor

A lightweight and intuitive multi-cursor editing plugin for Neovim. Create and
manipulate multiple cursors simultaneously to edit text at multiple locations
efficiently.

## Features

- ✨ **Easy Cursor Management** - Add/remove pseudo cursors with a single keymap
- 🎯 **Multi-cursor Navigation** - Move all cursors together with arrow key
  combinations
- ✏️ **Simultaneous Text Insertion** - Insert text at all cursor positions at
  once
- 🎨 **Visual Cursor Indicators** - Yellow vertical bars show cursor positions
- 🚀 **Lightweight** - Minimal dependencies, written in pure Lua
- 🔧 **Configurable** - Easy to customize keymaps and highlight colors

## Requirements

- Neovim (>= 0.7)

## Installation

### Using Lazy:

```lua
{
    "HarshGaur387R/ez-multi-cursor",
    config = function()
        require("ez-multi-cursor").setup()
    end,
}
```

### Using Packer:

```lua
use {
    "HarshGaur387R/ez-multi-cursor",
    config = function()
        require("ez-multi-cursor").setup()
    end,
}
```

## Usage

### Default Keymaps

| Keymap               | Action                                |
| -------------------- | ------------------------------------- |
| `<C-d>`              | Add/remove cursor at current position |
| `<A-Right>`          | Move all cursors right                |
| `<A-Left>`           | Move all cursors left                 |
| `<A-Up>`             | Move all cursors up                   |
| `<A-Down>`           | Move all cursors down                 |
| `<Esc>`              | Clear all cursors                     |
| `:InsertText <text>` | Insert text at all cursor positions   |

### Quick Example

1. Position your cursor on a word
2. Press `<C-d>` to add a cursor at that position
3. Move to another location and press `<C-d>` again to add another cursor
4. Use `<A-Right>`, `<A-Left>`, `<A-Up>`, `<A-Down>` to move all cursors
5. Use `:InsertText foo` to insert "foo" at all cursor positions
6. Press `<Esc>` to clear all cursors and exit multi-cursor mode

## Configuration

```lua
require("ez-multi-cursor").setup({
    highlight_group = 'Visual',  -- Highlight group for cursor appearance
    insert_mode_keys = true,      -- Enable insert mode key handling
})
```

### Highlight Customization

The plugin uses a `CursorBar` highlight group. To customize the cursor
appearance, add this to your Neovim config:

```lua
vim.api.nvim_set_hl(0, "CursorBar", { fg = "Yellow", bg = "NONE" })
```

## Architecture

The plugin is organized into modular components for maintainability:

- **cursor.lua** - Cursor class and data structure
- **cursors_manager.lua** - Manage cursor collection
- **rendering.lua** - Handle highlighting and visual rendering
- **movement.lua** - Cursor movement operations
- **text_operations.lua** - Text insertion functionality
- **utils.lua** - Utility functions
- **config.lua** - Configuration management

## Limitations

- Cursors are limited to the current buffer
- Works in normal mode (exits on entering insert mode)
- Pseudo-cursors are visual only (not actual Neovim cursors)
