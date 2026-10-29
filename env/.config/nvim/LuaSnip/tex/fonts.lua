local ls = require('luasnip')
local s, i, t = ls.snippet, ls.insert_node, ls.text_node
local fmta = require('luasnip.extras.fmt').fmta
local context = require('tex_context')

local snippets = {
    s({ trig = 'bb', name = 'Blackboard bold', condition = context.math, show_condition = context.math },
        fmta('\\mathbb{<>}<>', { i(1), i(0) })),
    s({ trig = 'cal', name = 'Calligraphic letter', condition = context.math, show_condition = context.math },
        fmta('\\mathcal{<>}<>', { i(1), i(0) })),
}
local autosnippets = {}
for _, letter in ipairs({ 'R', 'N', 'Z', 'Q', 'C' }) do
    table.insert(autosnippets, s({ trig = letter .. letter, name = '\\mathbb{' .. letter .. '}',
        condition = context.math, show_condition = context.math }, { t('\\mathbb{' .. letter .. '}') }))
end

return snippets, autosnippets
