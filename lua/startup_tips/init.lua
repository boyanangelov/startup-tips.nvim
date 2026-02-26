local M = {}

local tips = require("startup_tips.tips")

local defaults = {
  -- "float" or "echo"
  display = "float",
  -- seconds before float auto-closes (0 = stay open until dismissed)
  auto_close = 0,
  -- show on VimEnter only when no file arguments were passed
  only_on_empty = true,
  -- keymap to manually trigger the tip window
  keymap = "<leader>vt",
  -- float window appearance
  float = {
    width = 60,
    border = "rounded",
    title = " Vim Tip of the Day ",
    title_pos = "center",
  },
}

local config = {}

local function pick_tip()
  math.randomseed(os.time())
  return tips.list[math.random(#tips.list)]
end

local function build_lines(tip)
  local w = config.float.width - 4 -- account for border + padding
  local sep = string.rep("─", w)
  return {
    "",
    ("  Category : %s"):format(tip.category),
    ("  Shortcut : %s"):format(tip.shortcut),
    "",
    sep,
    "",
    ("  %s"):format(tip.description),
    "",
    sep,
    "",
    "  q / Esc  close   n  next tip",
    "",
  }
end

local function show_float(tip)
  local lines = build_lines(tip)

  local height = #lines

  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  vim.bo[buf].modifiable = false
  vim.bo[buf].bufhidden = "wipe"

  local ui = vim.api.nvim_list_uis()[1]
  local win_w = config.float.width
  local win_h = height
  local row = math.floor((ui.height - win_h) / 2)
  local col = math.floor((ui.width - win_w) / 2)

  local win_cfg = {
    relative = "editor",
    row = row,
    col = col,
    width = win_w,
    height = win_h,
    style = "minimal",
    border = config.float.border,
    title = config.float.title,
    title_pos = config.float.title_pos,
    zindex = 50,
  }

  local win = vim.api.nvim_open_win(buf, true, win_cfg)

  local ns = vim.api.nvim_create_namespace("startup_tips")
  -- line index 2 = "  Shortcut : ..."
  vim.api.nvim_buf_add_highlight(buf, ns, "Special", 2, 0, -1)
  -- line index 1 = "  Category : ..."
  vim.api.nvim_buf_add_highlight(buf, ns, "Comment", 1, 0, -1)
  -- separators
  vim.api.nvim_buf_add_highlight(buf, ns, "NonText", 4, 0, -1)
  vim.api.nvim_buf_add_highlight(buf, ns, "NonText", 8, 0, -1)
  -- hint line (index 10)
  vim.api.nvim_buf_add_highlight(buf, ns, "Comment", 10, 0, -1)

  local close = function()
    if vim.api.nvim_win_is_valid(win) then
      vim.api.nvim_win_close(win, true)
    end
  end
  for _, key in ipairs({ "q", "<Esc>", "<CR>" }) do
    vim.keymap.set("n", key, close, { buffer = buf, nowait = true, silent = true })
  end

  vim.keymap.set("n", "n", function()
    close()
    vim.schedule(function()
      show_float(pick_tip())
    end)
  end, { buffer = buf, nowait = true, silent = true })

  if config.auto_close > 0 then
    vim.defer_fn(close, config.auto_close * 1000)
  end
end

local function show_echo(tip)
  vim.api.nvim_echo({
    { "[Vim Tip] ", "Title" },
    { tip.shortcut, "Special" },
    { "  —  ", "Comment" },
    { tip.description, "Normal" },
  }, true, {})
end

function M.show()
  local tip = pick_tip()
  if config.display == "echo" then
    show_echo(tip)
  else
    show_float(tip)
  end
end

function M.setup(opts)
  config = vim.tbl_deep_extend("force", defaults, opts or {})

  if config.keymap and config.keymap ~= "" then
    vim.keymap.set("n", config.keymap, M.show, {
      desc = "Show random Vim tip",
      silent = true,
    })
  end

  vim.api.nvim_create_autocmd("VimEnter", {
    group = vim.api.nvim_create_augroup("StartupTips", { clear = true }),
    callback = function()
      if config.only_on_empty and #vim.fn.argv() > 0 then
        return
      end
      vim.defer_fn(M.show, 100)
    end,
  })
end

return M
