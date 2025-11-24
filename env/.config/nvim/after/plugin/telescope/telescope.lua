local telescope = require('telescope')
local actions = require('telescope.actions')
local builtin = require('telescope.builtin')
telescope.setup {
  defaults = {
    path_display = { shorten = 8, 'truncate' },
    mappings = {
      i = {
        ['<C-p>'] = actions.move_selection_previous,
        ['<C-n>'] = actions.move_selection_next,
        ['<C-q>'] = actions.send_selected_to_qflist + actions.open_qflist,
      },
    },
  },
  pickers = {
    -- Default configuration for builtin pickers goes here:
    -- picker_name = {
    --   picker_config_key = value,
    --   ...
    -- }
    -- Now the picker_config_key will be applied every time you call this
    -- builtin picker

  },
  extensions = {
    -- Your extension configuration goes here:
    -- extension_name = {
    --   extension_config_key = value,
    -- }
    -- please take a look at the readme of the extension you want to configure
  },
}

vim.keymap.set('n', '<leader>pf', builtin.find_files, { desc = 'find files in project' })                     --'project files'
vim.keymap.set('n', '<C-p>', builtin.git_files, { desc = 'find files in git repo' })                     --'git files'
vim.keymap.set('n', '<leader>ps', builtin.live_grep, { desc = 'search file contents in project for string' }) --'project search'
vim.keymap.set('n', '<C-h>', builtin.help_tags, { desc = 'search neovim help docs' })
vim.keymap.set('n', '<leader>gl', builtin.git_commits, { desc = 'search git commit history' })
vim.keymap.set('n', '<leader>gb', builtin.git_bcommits, { desc = 'search git commit history for the current buffer' })
