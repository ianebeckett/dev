local ls = require("luasnip")

ls.config.set_config({
    history = true,
    enable_autosnippets = true,
    updateevents = "TextChanged,TextChangedI",
    store_selection_keys = '<Tab>',
})

ls.setup({
    require("luasnip.loaders.from_vscode").lazy_load(),
    require("luasnip.loaders.from_lua").lazy_load({
        paths = {
            "~/dev/env/.config/nvim/after/plugin/luasnip/",
        }
    }),
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

-- ls.filetype_extend("javascript", { "jsdoc" })
-- vim.keymap.set({"i"}, "<C-s>e", function() ls.expand() end, {silent = true})
-- vim.keymap.set({"i", "s"}, "<C-s>;", function() ls.jump(1) end, {silent = true})
-- vim.keymap.set({"i", "s"}, "<C-s>,", function() ls.jump(-1) end, {silent = true})
--
-- vim.keymap.set({"i", "s"}, "<C-E>", function()
--     if ls.choice_active() then
--         ls.change_choice(1)
--     end end, {silent = true})
