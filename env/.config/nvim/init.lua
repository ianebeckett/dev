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
  underline = false,
  virtual_text = {
    enabled = true,
    virt_text_pos = 'eol',
  },
  signs = true,
  float = {
    header = '',
    source = true,
    prefix = '',
    style = 'minimal',
    border = 'none',
  },
  severity_sort = true,
})
