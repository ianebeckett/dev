--netrw settings
vim.g.netrw_banner = 0

vim.g.mapleader = " "
vim.opt.guicursor = ""
vim.opt.encoding = "utf-8"
vim.opt.statusline="%f %= bufnr %n column %9.9c byte %9.9o: 0x%2.2B %{&fileencoding}"

vim.opt.number = true
vim.opt.relativenumber = true
-- high scrolloff minimizes vertical scanning with eyes
-- set to rows / 2 - 1 to prevent text from moving when spamming jkjkjk
vim.opt.scrolloff = 10

vim.opt.tabstop = 2
vim.opt.softtabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = true

vim.opt.smartindent = true

vim.opt.wrap = false

--use undofile and undotree intead of swapfile
vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.undodir = os.getenv("XDG_STATE_HOME") .. "/vim/undodir"
vim.opt.undofile = true

vim.opt.hlsearch = false
vim.opt.incsearch = true
vim.opt.ignorecase = true
vim.opt.smartcase = true

vim.opt.termguicolors = true

vim.opt.updatetime = 50
vim.opt.timeoutlen = 500

vim.opt.colorcolumn = { "80" }
vim.opt.signcolumn = "yes"

vim.o.pumheight = 15
vim.o.pumborder = 'rounded'

vim.o.winborder = 'rounded'

--NOTE: use shortmess when you remember what command you were trying to do
--without 'hit enter' prompt

-- Sync clipboard between the OS and Neovim.
--vim.o.clipboard = 'unnamedplus'
