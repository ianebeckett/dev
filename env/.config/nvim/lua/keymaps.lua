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

--replace selected text with clipboard contents
--try with ve<leader>p to replace a word
vim.keymap.set('x', '<leader>p', '\'_dP')

--yank into system clipboard
vim.keymap.set({ 'n', 'v' }, '<leader>y', '\'+y')
vim.keymap.set('n', '<leader>y', '\'+Y')

--quickfix list navigation
vim.keymap.set('n', '<C-j>', '<Cmd>cnext<CR>zz')
vim.keymap.set('n', '<C-k>', '<Cmd>cprev<CR>zz')

--edit all instances of cursor word in file
--superceded by "vrn" -> lsp buf rename
--vim.keymap.set('n', '<leader>s', ':%s/\\<<C-r><C-w>\\>/<C-r><C-w>/gI<left><left><left>')

--chmod +x current file without leaving vim
vim.keymap.set('n', '<leader>ch', '<Cmd>!chmod +x %<cr>', { silent = true })

-- Source stuff
vim.keymap.set("n", "<leader>xl", "<cmd>.lua<CR>", { desc = "Execute the current line" })
vim.keymap.set("n", "<leader>xf", "<cmd>source %<CR>", { desc = "Execute the current file" })

vim.keymap.set('n', '<C-f>', '<Cmd>silent !tmux neww tmux-sessionizer<CR>')
vim.keymap.set('n', '<C-t>', '<Cmd>silent !tmux neww tmux-todo-finder<CR>')

vim.keymap.set('n', '<leader>u', vim.cmd.Undotree)

-- Make U opposite to u.
vim.keymap.set('n', 'U', '<C-r>', { desc = 'Redo' })

vim.keymap.set('n', '<C-b>', '<C-a>', { desc = 'Increment number' })

--delete without overwriting clipboard
--vim.keymap.set({ 'n', 'v' }, '<leader>d', '\'_d')

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

-- --these could be useful for git diffs
-- set("n", "<M-j>", function()
--   if vim.opt.diff:get() then
--     vim.cmd [[normal! ]c]]
--   else
--     vim.cmd [[m .+1<CR>==]]
--   end
-- end)

-- set("n", "<M-k>", function()
--   if vim.opt.diff:get() then
--     vim.cmd [[normal! [c]]
--   else
--     vim.cmd [[m .-2<CR>==]]
--   end
-- end)

-- Use a vertical split instead of the default horizontal split for <c-w><c-f>
vim.keymap.set("n", "<c-w><c-f>", [[:vsplit<cr>gF]], { desc = "Open file under cursor" })

vim.keymap.set("n", "<leader>yf", function()
	vim.fn.setreg("+", vim.fn.expand("%"))
end, { desc = "Yank the current file path" })

-- vim.keymap.set("n", "<leader>tc", function()
-- 	local colorscheme = vim.trim(vim.fn.execute("colorscheme"))
-- 	if colorscheme == "rose-pine" then
-- 		vim.cmd.colorscheme("tokyonight-day")
-- 	elseif colorschema == "tokyonight-day" then
-- 		vim.cmd.colorscheme("cobalt")
-- 	end
-- end, { desc = "[T]oggle [c]olorscheme" })
