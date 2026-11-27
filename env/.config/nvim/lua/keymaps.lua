vim.keymap.set('i', '<C-c>', '<esc>')
vim.keymap.set('n', 'Q', '<nop>')

-- Ctrl+BS sends keycode ^H for deleting words in insert mode. depends on similar binding in tmux
vim.keymap.set({'i', 'n'}, '<C-H>', '<C-w>')

vim.keymap.set({'i', 'n'}, '<C-BS>', '<C-w>', { desc = 'Delete previous word' })
vim.keymap.set('i', '<C-Del>', function()
    return vim.fn.col('.') <= #vim.api.nvim_get_current_line() and '<C-o>"_dw' or ''
end, { expr = true, desc = 'Delete next word' })
vim.keymap.set('n', '<C-Del>', '"_dw', { desc = 'Delete next word' })

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

--replace selected text with clipboard contents
--try with ve<leader>p to replace a word
vim.keymap.set('x', '<leader>p', '"_dP')
--delete without overwriting clipboard
vim.keymap.set({ 'n', 'v' }, '<leader>d', '\'_d')

--yank into system clipboard by default
vim.keymap.set({ 'n', 'v' }, '<leader>y', '"+y')
vim.keymap.set('n', '<leader>Y', '"+Y')

--quickfix list navigation
vim.keymap.set('n', '<C-j>', '<Cmd>cnext<CR>zz')
vim.keymap.set('n', '<C-k>', '<Cmd>cprev<CR>zz')

--chmod +x current file without leaving vim
vim.keymap.set('n', '<leader>x', '<Cmd>!chmod +x %<cr>', { silent = true })

-- Source stuff
--vim.keymap.set("n", "<leader>xl", "<cmd>.lua<CR>", { desc = "Execute the current line" })
--vim.keymap.set("n", "<leader>xf", "<cmd>source %<CR>", { desc = "Execute the current file" })

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
vim.keymap.set('n', '<leader>dl', '<cmd>lua Date()<cr>', { desc = '[d]ate [l]ine' })

-- stay in in visual mode when adjusting indentation
vim.keymap.set("v", "<", "<gv")
vim.keymap.set("v", ">", ">gv")

-- Use a vertical split instead of the default horizontal split for <c-w><c-f>
vim.keymap.set("n", "<c-w><c-f>", [[:vsplit<cr>gF]], { desc = "Open file under cursor" })

vim.keymap.set("n", "yf", function()
	vim.fn.setreg("+", vim.fn.expand("%"))
end, { desc = "Yank the current buffer's path (usually relative to cwd)" })

vim.keymap.set("n", "yp", function()
	vim.fn.setreg("+", vim.fn.expand("%:p"))
end, { desc = "Yank the current buffer's absolute path" })

vim.keymap.set("n", "<leader>td", function()
  vim.diagnostic.enable(not vim.diagnostic.is_enabled())
end, { desc = "Toggle diagnostics" })

vim.keymap.set("n", "<leader>tn", function()
    local option = vim.opt.relativenumber --[[@as vim.Option]]
    vim.opt.relativenumber = not option:get()
end, { desc = "Toggle relative line number" })
