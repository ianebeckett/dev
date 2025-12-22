-- this order matters
require('pack')
require('autocommands')
require('options')
require('keymaps')

--notes on colorschemes I've tried:
--gruvbox-material
--gruvbox-baby
--kanagawa - looks too muted on my screen. Might look better on a glossy display
--mellifluous - I don't like beige strings
--nord - floating windows are white on black. Also, the dusty blue bg is not my fave
require('colors.rose-pine')

-- Interactive textual undotree
vim.cmd.packadd 'nvim.undotree'
