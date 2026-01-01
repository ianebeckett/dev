-- this order matters
require('pack')
require('autocommands')
require('options')
require('keymaps')

--notes on colorschemes I've tried:
--gruvbox-material - I don't like red or green keywords, green labels
--kanagawa - looks too muted on my screen. Might look better on a glossy display
--mellifluous - I don't like beige strings
--nord - floating windows are white on black. Also, it's too blue
--solarized light for daytime?
require('colors.rose-pine')

-- Interactive textual undotree
vim.cmd.packadd 'nvim.undotree'
