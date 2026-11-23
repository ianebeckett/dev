return {
  cmd = { 'ruff', 'server' },
  filetypes = { 'python' },
  root_markers = { 'pyproject.toml', 'ruff.toml', '.ruff.toml', '.git' },
  init_options = {
    settings = {
      -- Use Ruff for formatting; keep the existing Python analysis setup.
      lint = { enable = false },
      showSyntaxErrors = false,
      fixAll = false,
      organizeImports = false,
    },
  },
  on_attach = function(client)
    client.server_capabilities.hoverProvider = false
  end,
}
