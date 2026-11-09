# whiteboard.nvim

Open [Excalidraw](https://excalidraw.com) in its own window straight from Neovim for quick sketches and diagrams.

## requirements

- Neovim 0.8+
- A Chromium-based browser (`chromium`, `google-chrome`, `brave`) or Firefox
- An internet connection (Excalidraw loads from the web)

## installation

### [lazy.nvim](https://github.com/folke/lazy.nvim)

```lua
{
  "IanMacwan/whiteboard.nvim",
  cmd = { "Whiteboard", "WhiteboardClose" },
  keys = {
    { "<leader>wb", "<cmd>Whiteboard<cr>", desc = "Open whiteboard" },
  },
  opts = {},
}
```

### [packer.nvim](https://github.com/wbthomason/packer.nvim)

```lua
use({
  "IanMacwan/whiteboard.nvim",
  cmd = { "Whiteboard", "WhiteboardClose" },
  config = function()
    require("whiteboard").setup()
  end,
})

vim.keymap.set("n", "<leader>wb", "<cmd>Whiteboard<cr>", { desc = "Open whiteboard" })
```

### [vim-plug](https://github.com/junegunn/vim-plug)

```vim
Plug 'IanMacwan/whiteboard.nvim'
```

Then call setup somewhere in your Lua config:

```lua
require("whiteboard").setup()
vim.keymap.set("n", "<leader>wb", "<cmd>Whiteboard<cr>", { desc = "Open whiteboard" })
```

## Usage

| Command             | Description                                  |
| ------------------- | -------------------------------------------- |
| `:Whiteboard`       | Open the whiteboard window                   |
| `:WhiteboardClose`  | Close the window (the drawing is kept)       |

Closing the window and running `:Whiteboard` again brings your drawing back. Quitting Neovim kills the browser and deletes the profile, so the board is gone. Use Excalidraw's own export (PNG, SVG, `.excalidraw`) if you want to keep a drawing.

## Configuration

Defaults:

```lua
require("whiteboard").setup({
  browser = nil,                  -- e.g. "firefox"; auto-detected when nil
  url = "https://excalidraw.com", -- any Excalidraw instance
  window_size = "1280,800",       -- Chromium-based browsers only
})
```

Auto-detection tries `chromium`, `google-chrome-stable`, `google-chrome`, `brave`, `brave-browser`, then `firefox`.
