require("options")
require("keymaps")
require("autocommands")
require("colors.rose-pine")
--require("colors.nord")

vim.lsp.enable({
    'lua_ls',
    'clangd',
    -- 'eslint',
});

-- Interactive textual undotree:
vim.cmd.packadd 'nvim.undotree'

