require('blink.cmp').setup {

  completion = {
    menu = {
      auto_show = true,
      draw = {
        columns = { { "label", "label_description", gap = 1 }, { "source_name", gap = 1, "kind" } },
      },
    },
    -- By default, you may press `<c-space>` to show the documentation.
    -- Optionally, set `auto_show = true` to show the documentation after a delay.
    documentation = { auto_show = true, auto_show_delay_ms = 1 },
    accept = { auto_brackets = { enabled = false }, },
  },

  keymap = { -- these keymaps are for the completion menu only
    preset = 'default',
    ['<C-space>'] = {},
    ['<C-n>'] = { 'select_next', 'fallback' },
    ['<C-p>'] = { 'select_prev', 'fallback' },
    ['<C-d>'] = { 'scroll_documentation_down', 'fallback' },
    ['<C-u>'] = { 'scroll_documentation_up', 'fallback' },
    ['<C-k>'] = { 'accept', 'fallback' } -- delegate snippets to luasnip
  },
  sources = {
    -- `lsp`, `buffer`, `snippets`, `path` and `omni` are built-in
    -- so you don't need to define them in `sources.providers`
    default = { 'lsp', 'snippets', 'path' },
    per_filetype = {
      --sql = { 'dadbod' },
    },
    providers = {
      --dadbod = { module = "vim_dadbod_completion.blink" },
    },
  },

  snippets = { preset = 'luasnip' },
  cmdline = { enabled = true },
  fuzzy = { implementation = 'lua' },
  -- Shows a signature help window while you type arguments for a function
  signature = { enabled = true },
}
