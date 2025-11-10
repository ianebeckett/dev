-- this order matters
require('pack')
require('autocommands')
require('options')
require('keymaps')

--require('colors.rose-pine')
--require('colors.nord')
require('colors.nightfox')

-- Interactive textual undotree
vim.cmd.packadd 'nvim.undotree'

-- Global diagnostics configuration
vim.diagnostic.config({
  virtual_text = {
    enabled = true,
    virt_text_pos = 'eol',
  },
  signs = true,
  update_in_insert = false,
})
