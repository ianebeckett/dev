return {
  cmd = { 'lua-language-server' },
  root_markers = { '.luarc.json', '.luarc.jsonc', '.luacheckrc', '.stylua.toml',
    'stylua.toml', 'selene.toml', 'selene.yml', '.git',
  },
  filetypes = { 'lua' },
  settings = {
    Lua = {
      runtime = {
        version = 'LuaJIT',
        pathStrict = true,
        path = {
            "lua/?.lua",
        },
      },
      workspace = {
        --See https://github.com/neovim/nvim-lspconfig/blob/master/lsp/lua_ls.lua
        library = vim.api.nvim_get_runtime_file('', true),
        checkThirdParty = false,
      },
      -- diagnostics= {
      --     globals = { 'vim' },
      -- },
      telemetry = {
        enable = false,
      },
    }
  }
}

