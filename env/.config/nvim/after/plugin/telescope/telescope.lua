local telescope = require('telescope')
local actions = require('telescope.actions')
local builtin = require('telescope.builtin')
telescope.setup {
  defaults = {
    mappings = {
      i = {
        ['<C-p>'] = actions.move_selection_previous,
        ['<C-n>'] = actions.move_selection_next,
        ['<C-q>'] = actions.send_selected_to_qflist + actions.open_qflist,
      } } }
}

vim.keymap.set('n', '<leader>pf', builtin.find_files, { desc = 'find files in project' }) --'project files'
vim.keymap.set('n', '<leader>gf', builtin.git_files, { desc = 'find files in git repo' }) --'git files'
vim.keymap.set('n', '<leader>ps', builtin.live_grep, { desc = 'search file contents in project for string' }) --'project search'
vim.keymap.set('n', '<C-h>', builtin.help_tags, { desc = 'search neovim help docs' })
