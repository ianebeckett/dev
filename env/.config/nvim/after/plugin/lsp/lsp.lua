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
