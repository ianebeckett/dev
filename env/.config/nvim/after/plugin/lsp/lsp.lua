vim.lsp.config('*', {
  capabilities = require('blink.cmp').get_lsp_capabilities(),
  root_markers = { '.git/', },
})

vim.lsp.enable({
  'lua_ls',
  'clangd',
  'eslint',
  'ts_ls',
});

-- Global diagnostics configuration
vim.diagnostic.config({
  underline = false,
  virtual_text = {
    enabled = true,
    virt_text_pos = 'eol',
  },
  signs = true,
  float = {
    header = '',
    source = true,
    prefix = '',
    style = 'minimal',
    border = 'none',
  },
  severity_sort = true,
})
