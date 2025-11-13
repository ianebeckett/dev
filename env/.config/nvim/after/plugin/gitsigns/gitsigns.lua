require('gitsigns').setup {
  on_attach = function()
    local gitsigns = require('gitsigns')
    vim.keymap.set('n', '<leader>b', gitsigns.blame)
  end
}
