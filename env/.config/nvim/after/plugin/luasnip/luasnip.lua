local ls = require("luasnip")

ls.config.set_config({
    enable_autosnippets = true,
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

-- https://ejmastnak.com/tutorials/vim-latex/luasnip/#what-snippets-do
vim.cmd[[
    imap <silent><expr> <Tab> luasnip#expand_or_jumpable() ? '<Plug>luasnip-expand-or-jump' : '<Tab>'
    imap <silent><expr> <S-Tab> luasnip#jumpable(-1) ? '<Plug>luasnip-jump-prev' : '<S-Tab>'
    smap <silent><expr> <S-Tab> luasnip#jumpable(-1) ? '<Plug>luasnip-jump-prev' : '<S-Tab>'
    smap <silent><expr> <Tab> luasnip#jumpable(1) ? '<Plug>luasnip-jump-next' : '<Tab>'
    smap <silent><expr> <C-p> luasnip#choice_active() ? '<Plug>luasnip-prev-choice' : '<C-p>'
    imap <silent><expr> <C-n> luasnip#choice_active() ? '<Plug>luasnip-next-choice' : '<C-n>'
]]

-- ls.filetype_extend("javascript", { "jsdoc" })
-- vim.keymap.set({"i"}, "<C-s>e", function() ls.expand() end, {silent = true})
-- vim.keymap.set({"i", "s"}, "<C-s>;", function() ls.jump(1) end, {silent = true})
-- vim.keymap.set({"i", "s"}, "<C-s>,", function() ls.jump(-1) end, {silent = true})
--
-- vim.keymap.set({"i", "s"}, "<C-E>", function()
--     if ls.choice_active() then
--         ls.change_choice(1)
--     end end, {silent = true})
