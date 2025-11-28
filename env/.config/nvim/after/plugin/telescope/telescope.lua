local telescope = require('telescope')
local actions = require('telescope.actions')
local builtin = require('telescope.builtin')

telescope.setup {
    defaults = {
        layout_strategy = 'horizontal',
        path_display = { 'truncate' },
        mappings = {
            i = {
                ['<C-q>'] = actions.send_selected_to_qflist + actions.open_qflist,
            },
        },
    },
    pickers = {
        grep_string = {
            layout_strategy = 'vertical',
        },
        live_grep = {
            layout_strategy = 'vertical',
        },
        help_tags = {
            layout_strategy = 'center',
            previewer = false,
        },
        find_files = {
            layout_strategy = 'center',
            previewer = false,
        },
        git_files = {
            layout_strategy = 'center',
            previewer = false,
        },
        git_commits = {
            layout_strategy = 'horizontal',
            sorting_strategy = 'ascending',
        },
        git_bcommits = {
            layout_strategy = 'horizontal',
            sorting_strategy = 'ascending',
        },
    },
}

--greps, in order of specificity
vim.keymap.set('n', '<leader>pws', function() local word = vim.fn.expand("<cword>") builtin.grep_string({ search = word }) end)
vim.keymap.set('n', '<leader>pWs', function() local word = vim.fn.expand("<cWORD>") builtin.grep_string({ search = word }) end)
vim.keymap.set('n', '<leader>gs', function() builtin.grep_string({ search = vim.fn.input("Grep > ") }) end)
vim.keymap.set('n', '<leader>ps', builtin.live_grep, { desc = 'search [p]roject for [s]tring' })

--finds
vim.keymap.set('n', '<leader>vh', builtin.help_tags, { desc = 'index neo[v]im [h]elp docs' })
vim.keymap.set('n', '<leader>pf', builtin.find_files, { desc = 'index [p]roject [f]iles' })
vim.keymap.set('n', '<C-p>', builtin.git_files, { desc = 'index files in git repo' })
vim.keymap.set('n', '<leader>gl', builtin.git_commits, { desc = 'index [g]it [l]og' })
vim.keymap.set('n', '<leader>gb', builtin.git_bcommits, { desc = 'index [g]it log for the current [b]uffer' })

vim.keymap.set('n', '<leader>qf', builtin.quickfix, { desc = '[Q]uick[Fix]' })
