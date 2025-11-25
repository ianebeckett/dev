local telescope = require('telescope')
local actions = require('telescope.actions')
local builtin = require('telescope.builtin')
local themes = require('telescope.themes')

telescope.setup {
    defaults = {
        path_display = { shorten = 8, 'truncate' },
        mappings = {
            i = {
                ['<C-q>'] = actions.send_selected_to_qflist + actions.open_qflist,
            },
        },
    },
}

vim.keymap.set('n', '<leader>pf', builtin.find_files, { desc = 'find files in project' })
vim.keymap.set('n', '<C-p>', builtin.git_files, { desc = 'find files in git repo' })
vim.keymap.set('n', '<leader>ps', builtin.live_grep, { desc = 'search file contents in project for string' })
vim.keymap.set('n', '<leader>pws', function() local word = vim.fn.expand("<cword>") builtin.grep_string({ search = word }) end)
vim.keymap.set('n', '<leader>pWs', function() local word = vim.fn.expand("<cWORD>") builtin.grep_string({ search = word }) end)
--vim.keymap.set('n', '<leader>ps', function() builtin.grep_string({ search = vim.fn.input("Grep > ") }) end)
vim.keymap.set('n', '<leader>gl', builtin.git_commits, { desc = 'search git commit history' })
vim.keymap.set('n', '<leader>gb', builtin.git_bcommits, { desc = 'search git commit history for the current buffer' })
vim.keymap.set('n', '<leader>vh', builtin.help_tags, { desc = 'search neovim help docs' })
