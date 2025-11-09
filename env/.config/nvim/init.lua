require("pack")
require("options")
require("keymaps")
require("autocommands")
--require("colors.rose-pine")
--require("colors.nord")
require("colors.nightfox")

vim.lsp.enable({
  'lua_ls',
  'clangd',
  'eslint',
  'ts_ls',
});

-- Interactive textual undotree
vim.cmd.packadd 'nvim.undotree'

-- Global diagnostics configuration
vim.diagnostic.config({
  virtual_text = {
    enabled = true,
    virt_text_pos = 'eol',
  },
  signs = true,
  update_in_insert = false,
})

require('gitsigns').setup {
  on_attach = function(bufnr)
    local gitsigns = require('gitsigns')
    vim.keymap.set('n', '<leader>b', gitsigns.blame)
  end
}

local harpoon = require("harpoon")
harpoon:setup() -- REQUIRED
harpoon.settings = {
  save_on_toggle = false,
  sync_on_ui_close = false,
  key = function()
    return vim.loop.cwd()
  end,
}

local telescope = require('telescope')
local actions = require('telescope.actions')
telescope.setup {
  defaults = {
    mappings = {
      i = {
        ["<C-p>"] = actions.move_selection_previous,
        ["<C-n>"] = actions.move_selection_next,
        ["<C-q>"] = actions.send_selected_to_qflist + actions.open_qflist
      } } }
    }

    require 'nvim-treesitter.configs'.setup {
      -- A list of parser names, or "all" (the first seven MUST always be installed)
      -- for list of available parsers see https://github.com/nvim-treesitter/nvim-treesitter
      ensure_installed = {
        "c",
        "lua",
        "vim",
        "vimdoc",
        "query",
        "markdown",
        "markdown_inline",
        "cpp",
        "python",
        "json",
        "javascript",
        "typescript",
      },

      -- Install parsers synchronously (only applied to `ensure_installed`)
      sync_install = false,

      -- Automatically install missing parsers when entering buffer
      -- Recommendation: set to false if you don't have `tree-sitter` CLI installed locally
      auto_install = false,

      highlight = {
        enable = true,

        -- List of parsers to ignore installing (or "all")
        -- ignore_install = { "javascript" },

        -- list of language that will be disabled
        -- NOTE: these are the names of the parsers and not the filetype. (for example if you want to
        -- disable highlighting for the `tex` filetype, you need to include `latex` in this list as this is
        -- the name of the parser)
        -- disable = { "c", "rust", "latex" },

        -- Or use a function for more flexibility, e.g. to disable slow treesitter highlight for large files
        disable = function(lang, buf)
          local max_filesize = 100 * 1024 -- 100 KB
          local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
          if ok and stats and stats.size > max_filesize then
            return true
          end
        end,

        -- Setting this to true will run `:h syntax` and tree-sitter at the same time.
        -- Set this to `true` if you depend on 'syntax' being enabled (like for indentation).
        -- Using this option may slow down your editor, and you may see some duplicate highlights.
        -- Instead of true it can also be a list of languages
        additional_vim_regex_highlighting = false, -- maybe helpful for Ruby, PHP
      },
    }

    vim.keymap.set('n', '<Leader>d', vim.diagnostic.open_float, { desc = "Show diagnostic" })
    vim.keymap.set("n", "[d", function() vim.diagnostic.jump({ float = true, count = 1 }) end)
    vim.keymap.set("n", "]d", function() vim.diagnostic.jump({ float = true, count = -1 }) end)

    local builtin = require('telescope.builtin')
    vim.keymap.set('n', '<leader>pf', builtin.find_files, { desc = "find files in project" }) --"project files"
    vim.keymap.set('n', '<leader>gf', builtin.git_files, { desc = "find files in git repo" }) --"git files"
    vim.keymap.set('n', '<leader>ps', builtin.live_grep, { desc = "search file contents in project for string" }) --"project search"

    vim.keymap.set("n", "<leader>a", function() harpoon:list():add() end)
    vim.keymap.set("n", "<C-e>", function() harpoon.ui:toggle_quick_menu(harpoon:list()) end)
    vim.keymap.set("n", "<A-h>", function() harpoon:list():select(1) end)
    vim.keymap.set("n", "<A-j>", function() harpoon:list():select(2) end)
    vim.keymap.set("n", "<A-k>", function() harpoon:list():select(3) end)
    vim.keymap.set("n", "<A-l>", function() harpoon:list():select(4) end)

    vim.keymap.set("n", "<C-f>", "<cmd>silent !tmux neww tmux-sessionizer<CR>")
    --run session commands while in neovim
    --Neovim registers super as alt, but alt+[hjkl] are used by Harpoon.
    --To avoid smearing harpoon keymaps, we could configure upstream to send
    --different keycodes. I've instead decided to map these to [7890]
    vim.keymap.set("n", "<M-7>", "<cmd>silent !tmux neww tmux-sessionizer -s 0<CR>")
    vim.keymap.set("n", "<M-8>", "<cmd>silent !tmux neww tmux-sessionizer -s 1<CR>")
    vim.keymap.set("n", "<M-9>", "<cmd>silent !tmux neww tmux-sessionizer -s 2<CR>")
