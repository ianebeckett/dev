vim.keymap.set('i', '<C-c>', '<esc>')
vim.keymap.set('n', 'Q', '<nop>')

-- Ctrl+BS sends keycode ^H for deleting words in insert mode. depends on similar binding in tmux
vim.keymap.set('i', '<C-H>', '<C-W>')

--netrw window management
vim.keymap.set('n', '<leader>pv', vim.cmd.Ex)  --'new' window, or 'netrw'

--vim split window management
--if the cursor is not moving, you probably didn't press the keys quickly enough
vim.keymap.set('n', '<C-w>v', '<C-w>v<C-w>l', { desc = 'Move cursor when splitting window'})
vim.keymap.set('n', '<C-w>s', '<C-w>s<C-w>j', { desc = 'Move cursor when splitting window'})

--center cursor after jumping
vim.keymap.set('n', '<C-d>', '<C-d>zz')
vim.keymap.set('n', '<C-u>', '<C-u>zz')
vim.keymap.set('n', '<C-o>', '<C-o>zz')
vim.keymap.set('n', '<C-i>', '<C-i>zz')
vim.keymap.set('n', '<C-]>', '<C-d>zz')
vim.keymap.set('n', 'n', 'nzzzv')
vim.keymap.set('n', 'N', 'Nzzzv')

--delete without overwriting clipboard
vim.keymap.set({ 'n', 'v' }, '<leader>d', '\'_d')

--replace selected text with clipboard contents
--try with ve<leader>p to replace a word
vim.keymap.set('x', '<leader>p', '\'_dP')

--yank into system clipboard
vim.keymap.set({ 'n', 'v' }, '<leader>y', '\'+y')
vim.keymap.set('n', '<leader>y', '\'+Y')

--quickfix list navigation
vim.keymap.set('n', '<C-j>', '<Cmd>cnext<CR>zz')
vim.keymap.set('n', '<C-k>', '<Cmd>cprev<CR>zz')
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

function Date()
    local row = vim.api.nvim_get_current_line()
    local col = vim.api.nvim_win_get_cursor(0)[2]
    local date = row:sub(0, col) .. '# ' .. os.date('%a %d %b %Y')
    vim.api.nvim_set_current_line(date)
    vim.api.nvim_feedkeys('o', 'n', true)
end
vim.keymap.set('n', '<leader>d', '<cmd>lua Date()<cr>', { desc = 'insert [d]ate' })
