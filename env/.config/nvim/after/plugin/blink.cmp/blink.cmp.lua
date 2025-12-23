require('blink.cmp').setup {
  signature = { enabled = true },
  cmdline = { enabled = true },
  snippets = { preset = 'luasnip' },
  fuzzy = { implementation = 'lua' },
  completion = {
    menu = {
      auto_show = true,
      draw = {
        columns = { { "label", "label_description", gap = 1 }, { "source_name", gap = 1, "kind" } },
      },
    },
    documentation = { auto_show = true, auto_show_delay_ms = 1 },
    accept = { auto_brackets = { enabled = false }, },
  },
  keymap = {
    preset = 'none',
    ['<C-y>'] = { 'accept' },
    ['<C-n>'] = { 'select_next', 'fallback' },
    ['<C-p>'] = { 'select_prev', 'fallback' },
    ['<C-d>'] = { 'scroll_documentation_down', 'fallback' },
    ['<C-u>'] = { 'scroll_documentation_up', 'fallback' },
    ['<C-k>'] = { 'fallback' } -- delegate snippets to luasnip
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
}
