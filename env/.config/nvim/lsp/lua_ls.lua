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
        --See https://github.com/neovim/nvim-lspconfig/blob/master/lsp/lua_ls.lua
        --See https://github.com/folke/lazydev.nvim
        --See https://www.youtube.com/watch?v=bTWWFQZqzyI&list=PLep05UYkc6wTyBe7kPjQFWVXTlhKeQejM&index=8
        library = {
          vim.fn.expand('$VIMRUNTIME/lua'),
          -- { path = "${3rd}/luv/library", words = { "vim%.uv" } }
        },
        -- reduce CPU-intensive loading on attach
        checkThirdParty = false,
        maxPreload = 100,
      },
      telemetry = {
        enable = false,
      },
    }
  }
}
