local telescope = require('telescope')
local actions = require('telescope.actions')
local builtin = require('telescope.builtin')

telescope.setup {
    defaults = {
        mappings = {
            i = {
                --TODO: j/k  vs p/n
                ["<C-p>"] = actions.move_selection_previous,
                ["<C-n>"] = actions.move_selection_next,
                ["<C-q>"] = actions.send_selected_to_qflist + actions.open_qflist
            } } }
}

vim.keymap.set('n', '<leader>sf', builtin.find_files, { desc = "find files in cwd" })
vim.keymap.set('n', '<leader>gf', builtin.live_grep, { desc = "grep files in cwd for string" })
vim.keymap.set('n', '<leader>sg', builtin.git_files, { desc = "find files in git repo" })
