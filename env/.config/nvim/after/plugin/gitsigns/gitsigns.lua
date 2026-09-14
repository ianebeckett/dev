require('gitsigns').setup {
  on_attach = function()
    local gitsigns = require('gitsigns')
    vim.keymap.set('n', '<leader>gb', gitsigns.blame)
  end
}
