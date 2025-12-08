--netrw settings
vim.g.netrw_banner = 0
vim.g.netrw_browse_split = 0
vim.g.netrw_winsize = 25

vim.g.mapleader = " "
vim.opt.guicursor = ""
vim.opt.encoding = 'utf-8'
vim.opt.statusline = '%F %= %l,%c %P %{&fileencoding}'

vim.opt.number = true
vim.opt.relativenumber = true
-- high scrolloff minimizes vertical scanning with eyes
-- if scrolloff is too high, we get screen jank when doing jkjkjkjk
vim.opt.scrolloff = 20

vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true

vim.opt.smartindent = true

vim.opt.wrap = false

--use undofile and undotree intead of swapfile
vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.undofile = true

vim.opt.incsearch = true
vim.opt.ignorecase = true
vim.opt.smartcase = true

vim.opt.termguicolors = true

vim.opt.updatetime = 50
vim.opt.timeoutlen = 500

vim.opt.colorcolumn = { '100' }
vim.opt.signcolumn = 'yes'

vim.o.winborder = 'rounded'

--NOTE: use shortmess when you remember what command you were trying to do
--without 'hit enter' prompt

-- Sync clipboard between the OS and Neovim.
vim.o.clipboard = 'unnamedplus'

vim.opt.isfname:append('@-@') --include @ as a valid filename character
require('vim._extui').enable({})

--vim.o.iskeyword = '@,48-57,_,192-255,-' -- Don't delimit `word` textobjects on dash
