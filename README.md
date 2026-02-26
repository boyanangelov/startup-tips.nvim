# startup-tips.nvim

Shows a random Vim tip in a floating window every time you open Neovim. Includes 580 motion-focused tips across Navigation, Motions, Text Objects, Search, Visual, and Marks.

## Preview

```
╭──────────────────────────── Vim Tip of the Day ─────────────────────────────╮
│                                                                             │
│  Category : Search                                                          │
│  Shortcut : cgn                                                             │
│                                                                             │
│  ────────────────────────────────────────────────────                       │
│                                                                             │
│  Change next search match — combine with . to repeat                        │
│                                                                             │
│  ─────────────────────────────────────────────────────                      │
│                                                                             │
│  q / Esc  close   n  next tip                                               │
│                                                                             │
╰─────────────────────────────────────────────────────────────────────────────╯
```

Press `q`, `<Esc>`, or `<CR>` to dismiss. Press `n` to cycle to the next tip.

## Installation

**lazy.nvim**
```lua
{
  "boyanangelov/startup-tips.nvim",
  event = "VimEnter",
  config = function()
    require("startup_tips").setup()
  end,
}
```

**packer.nvim**
```lua
use {
  "boyanangelov/startup-tips.nvim",
  config = function()
    require("startup_tips").setup()
  end,
}
```

## Configuration

```lua
require("startup_tips").setup({
  -- "float" (default) or "echo"
  display = "float",

  -- seconds before float auto-closes; 0 = manual dismiss only
  auto_close = 0,

  -- only show when Neovim is opened with no file arguments
  only_on_empty = true,

  -- keymap to manually show a tip at any time
  keymap = "<leader>vt",

  float = {
    width = 60,
    border = "rounded",          -- see :h nvim_open_win for options
    title = " Vim Tip of the Day ",
    title_pos = "center",
  },
})
```

## Manual trigger

```
:lua require("startup_tips").show()
```

Or use the default keymap `<leader>vt`.
