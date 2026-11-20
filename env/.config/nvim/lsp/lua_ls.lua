return {
  cmd = { 'lua-language-server' },
  root_markers = { '.luarc.json', '.luarc.jsonc', '.luacheckrc', '.stylua.toml',
    'stylua.toml', 'selene.toml', 'selene.yml', '.git/',
  },
  filetypes = { 'lua' },
  settings = {
    Lua = {
      runtime = {
        version = 'LuaJIT',
        pathStrict = true,
        path = {
          "lua/?.lua",
          "lua/?/init.lua",
        },
      },
      workspace = {
        -- reduce CPU-intensive loading on attach
        checkThirdParty = false,
        -- maxPreload = 100,
      },
      telemetry = {
        enable = false,
      },
    }
  }
}
