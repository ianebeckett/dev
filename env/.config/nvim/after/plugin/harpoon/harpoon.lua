local harpoon = require("harpoon")
harpoon:setup() -- REQUIRED
harpoon.settings = {
  save_on_toggle = false,
  sync_on_ui_close = false,
  key = function()
    return vim.loop.cwd()
  end,
}

vim.keymap.set('n', '<C-e>', function() harpoon.ui:toggle_quick_menu(harpoon:list()) end)
vim.keymap.set('n', '<leader>a', function() harpoon:list():add() end)
vim.keymap.set('n', '<leader>A', function() harpoon:list():add() end)
-- remap these to C+1243 once I figure out how to mamke it work with tmux
vim.keymap.set('n', '<A-h>', function() harpoon:list():select(1) end)
vim.keymap.set('n', '<A-j>', function() harpoon:list():select(2) end)
vim.keymap.set('n', '<A-k>', function() harpoon:list():select(3) end)
vim.keymap.set('n', '<A-l>', function() harpoon:list():select(4) end)
