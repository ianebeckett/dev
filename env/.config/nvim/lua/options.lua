--netrw settings
vim.g.netrw_banner = 0
vim.g.netrw_browse_split = 0
vim.g.netrw_winsize = 25

vim.g.mapleader = " "
vim.g.maplocalleader = " "
vim.opt.conceallevel = 0
vim.opt.guicursor = ""
vim.opt.encoding = 'utf-8'
vim.opt.statusline = '%F %= %n %l,%c %P %{&fileencoding}'

-- Let tmux name the window after the active buffer, including netrw.
if vim.env.TMUX then
    vim.opt.title = true
    vim.opt.titlelen = 0
    vim.opt.titlestring = "%{&filetype == 'netrw' ? 'netrw' : (expand('%:t') == '' ? '[No Name]' : expand('%:t'))}"
end

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
vim.opt.showbreak = "~ "

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

vim.opt.colorcolumn = { '90' }
vim.opt.signcolumn = 'yes'

vim.o.winborder = 'rounded'

--NOTE: use shortmess when you remember what command you were trying to do
--without 'hit enter' prompt

-- Scheduling as this can impact startup time
vim.schedule(function() vim.opt.clipboard = "unnamedplus" end)

vim.opt.isfname:append('@-@') --include @ as a valid filename character
require("vim._extui").enable({})

-- add paths for gf
vim.opt.path:append({
    '/usr/include/c++/13',
    '/usr/include/x86_64-linux-gnu/c++/13',
    '/usr/include/c++/13/backward',
    '/usr/lib/gcc/x86_64-linux-gnu/13/include',
    '/usr/local/include',
    '/usr/include/x86_64-linux-gnu',
    '/usr/include',
})

-- Fix common uppercase typos
vim.api.nvim_create_user_command('W', 'w', {})
vim.api.nvim_create_user_command('Wq', 'wq', {})
vim.api.nvim_create_user_command('WQ', 'wq', {})
vim.api.nvim_create_user_command('Q', 'q', {})
vim.api.nvim_create_user_command('Qa', 'qa', {})
