require 'nvim-treesitter.configs'.setup {
  -- A list of parser names, or 'all' (the first seven MUST always be installed)
  -- for list of available parsers see https://github.com/nvim-treesitter/nvim-treesitter
  ensure_installed = {
    'c',
    'lua',
    'vim',
    'vimdoc',
    'query',
    'markdown',
    'markdown_inline',
    'cpp',
    'python',
    'json',
    'javascript',
    'typescript',
  },

  -- Install parsers synchronously (only applied to `ensure_installed`)
  sync_install = false,

  -- Automatically install missing parsers when entering buffer
  -- Recommendation: set to false if you don't have `tree-sitter` CLI installed locally
  auto_install = true,

  -- List of parsers to ignore installing (or 'all')
  -- ignore_install = { 'javascript' },

  highlight = {
    enable = true,

    --use this for didsabling in big files?
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
