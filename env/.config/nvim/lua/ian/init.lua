require("ian.options")
require("ian.keymaps")
require("ian.autocommands")
require("ian.colors.rose-pine")
--require("ian.colors.nord")

vim.lsp.enable({
    'lua_ls',
    'clangd',
    -- 'eslint',
});
