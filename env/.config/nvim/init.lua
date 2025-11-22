-- this order matters
require('pack')
require('autocommands')
require('options')
require('keymaps')

require('colors.rose-pine')

-- Interactive textual undotree
vim.cmd.packadd 'nvim.undotree'
