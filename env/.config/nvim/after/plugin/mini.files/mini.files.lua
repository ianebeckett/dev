local mf = require('mini.files')

mf.setup(
    -- No need to copy this inside `setup()`. Will be used automatically.
    {
        -- Customization of shown content
        content = {
            -- Predicate for which file system entries to show
            filter = nil,
            -- Highlight group to use for a file system entry
            highlight = nil,
            -- Prefix text and highlight to show to the left of file system entry
            prefix = nil,
            -- Order in which to show file system entries
            sort = nil,
        },

        -- Module mappings created only inside explorer.
        -- Use `''` (empty string) to not create one.
        mappings = {
            close       = 'q',
            go_in       = 'l',
            go_in_plus  = '<CR>',
            go_out      = 'h',
            go_out_plus = '',
            mark_goto   = "'",
            mark_set    = 'm',
            reset       = '<BS>',
            reveal_cwd  = '@',
            show_help   = 'g?',
            synchronize = ':w',
            trim_left   = '<',
            trim_right  = '>',
        },

        -- General options
        options = {

            -- `options.permanent_delete` is a boolean indicating whether to perform
            -- permanent delete or move into special trash directory.
            -- This is a module-specific variant of "remove to trash".
            -- Target directory is 'mini.files/trash' inside standard path of Neovim data
            -- directory (execute `:echo stdpath('data')` to see its path in your case).
            permanent_delete = false,
            -- Whether to use for editing directories
            use_as_default_explorer = true,
        },

        -- Customization of explorer windows
        windows = {
            -- Maximum number of windows to show side by side
            max_number = math.huge,
            -- Whether to show preview of file/directory under cursor
            preview = false,
            -- Width of focused window
            width_focus = 50,
            -- Width of non-focused window
            width_nofocus = 15,
            -- Width of preview window
            width_preview = 25,
        },
    }
)

vim.keymap.set('n', '<leader>pv', mf.open, { desc = '[p]roject [v]iew' })
