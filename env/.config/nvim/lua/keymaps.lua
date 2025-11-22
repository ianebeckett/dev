--toggle line comment: gcc
--toggle block comment: vapgc
--indent lines: =

local map = function(keys, func, desc, mode)
  mode = mode or 'n'
  vim.keymap.set(mode, keys, func, { desc = desc })
end

vim.keymap.set('i', '<C-c>', '<esc>')
vim.keymap.set('n', 'Q', '<nop>')

--netrw window management
vim.keymap.set('n', '<leader>nw', vim.cmd.Ex)  --'new' window, or 'netrw'
vim.keymap.set('n', '<leader>vw', vim.cmd.Vex) --vertical window

--centered cursor for half-page jumping
vim.keymap.set('n', '<C-d>', '<C-d>zz')
vim.keymap.set('n', '<C-u>', '<C-u>zz')
--...and for jumping between search results
vim.keymap.set('n', 'n', 'nzzzv')
vim.keymap.set('n', 'N', 'Nzzzv')

--shift selection up/down
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")

--delete without overwriting clipboard
vim.keymap.set({ 'n', 'v' }, '<leader>d', '\'_d')

--replace selected text with clipboard contents
--try with ve<leader>p to replace a word
vim.keymap.set('x', '<leader>p', '\'_dP')

--yank into system clipboard
vim.keymap.set({ 'n', 'v' }, '<leader>y', '\'+y')
vim.keymap.set('n', '<leader>y', '\'+Y')

--quickfix list navigation
local telescope_builtin = require('telescope.builtin')
map('qf', telescope_builtin.quickfix, '[Q]uick[Fix]')
vim.keymap.set('n', '<C-j>', '<Cmd>cprev<CR>zz')
vim.keymap.set('n', '<C-k>', '<Cmd>cnext<CR>zz')
--jumplist navigation: C-i and C-o are prev and next
--location list navigation (none)

--edit all instances of cursor word in file
vim.keymap.set('n', '<leader>s', ':%s/\\<<C-r><C-w>\\>/<C-r><C-w>/gI<left><left><left>')

--chmod +x current file without leaving vim
vim.keymap.set('n', '<leader>x', '<Cmd>!chmod +x %<cr>', { silent = true })

vim.keymap.set('n', '<C-f>', '<Cmd>silent !tmux neww tmux-sessionizer<CR>')
vim.keymap.set('n', '<C-t>', '<Cmd>silent !tmux neww tmux-todo-finder<CR>')

vim.keymap.set('n', '<leader>u', vim.cmd.Undotree)

-- Make U opposite to u.
vim.keymap.set('n', 'U', '<C-r>', { desc = 'Redo' })

vim.keymap.set('n', '<C-b>', '<C-a>', { desc = 'Increment number' })
