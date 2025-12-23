---@diagnostic disable: unused-local
require("luasnip.session.snippet_collection").clear_snippets("all")

local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node

local snippets = {
    s({ trig = "hi" },
        { t("Hello, world!") }
    ),
}

local autosnippets = {
    s({ trig = "hi" },
        { t("Hello, world!") }
    ),
}

return snippets, autosnippets
