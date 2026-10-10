-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
vim.keymap.set("i", "jk", "<Esc>")
vim.keymap.set("i", "kj", "<Esc>")

-- wheel over an unfocused scrollbind pane (diff views) doesn't sync its partner,
-- so focus the hovered pane first
local function wheel(key)
  return function()
    local pos = vim.fn.getmousepos()
    if pos.winid ~= 0 and pos.winid ~= vim.api.nvim_get_current_win() and vim.wo[pos.winid].scrollbind then
      vim.api.nvim_set_current_win(pos.winid)
    end
    vim.cmd("normal! " .. vim.v.count1 * 3 .. key)
  end
end
vim.keymap.set("n", "<ScrollWheelDown>", wheel("\5"), { desc = "Scroll down (scrollbind aware)" })
vim.keymap.set("n", "<ScrollWheelUp>", wheel("\25"), { desc = "Scroll up (scrollbind aware)" })
