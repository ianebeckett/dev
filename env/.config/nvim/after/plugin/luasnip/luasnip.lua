local ls = require("luasnip")

ls.setup({
    update_events = "TextChanged,TextChangedI",
    cut_selection_keys = '<Tab>', -- if not used, disable this by deleting the line
    enable_autosnippets = true,
})

require("luasnip.loaders.from_vscode").load()
require("luasnip.loaders.from_lua").load({
    paths = { "~/dev/env/.config/nvim/LuaSnip/", }
})

vim.keymap.set({'i','s'}, "<c-k>", function()
    if ls.expand_or_jumpable(1) then
        ls.expand_or_jump()
    end
end, {silent = true})

vim.keymap.set({'i','s'}, "<c-j>", function()
    if ls.jumpable(-1) then
        ls.jump(-1)
    end
end, {silent = true})

vim.keymap.set('i', "<c-l>", function()
    if ls.choice_active() then
        ls.change_choice(1)
    end
end)

--useful for jumping to end of nested snippets
--the silly jump to the line start via ^ is a hack to ensure cursor exits a possible UltiSnips snippet scope
vim.keymap.set('n', '<C-L>', '<ESC>^$a')
