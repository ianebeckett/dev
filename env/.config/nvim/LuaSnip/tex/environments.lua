local ls = require('luasnip')
local s, i = ls.snippet, ls.insert_node
local fmta = require('luasnip.extras.fmt').fmta
local rep = require('luasnip.extras').rep
local context = require('tex_context')

local snippets = {
    s({ trig = 'beg', name = 'Environment with mirrored name', condition = context.text_line,
        show_condition = context.text },
        fmta('\\begin{<>}\n    <>\n\\end{<>}\n<>', { i(1, 'itemize'), i(2), rep(1), i(0) })),
}
local autosnippets = {
    s({ trig = 'ali', name = 'Aligned equations', condition = context.text_line, show_condition = context.text },
        fmta('\\begin{align*}\n    <> &= <> \\\\\n    <> &= <>\n\\end{align*}\n<>',
            { i(1), i(2), i(3), i(4), i(0) })),
    s({ trig = 'mat', name = 'Two by two matrix', condition = context.math, show_condition = context.math },
        fmta('\\begin{pmatrix}\n    <> & <> \\\\\n    <> & <>\n\\end{pmatrix}<>',
            { i(1), i(2), i(3), i(4), i(0) })),
    s({ trig = 'cases', name = 'Two cases', condition = context.math, show_condition = context.math },
        fmta('\\begin{cases}\n    <> & <> \\\\\n    <> & <>\n\\end{cases}<>',
            { i(1), i(2), i(3), i(4), i(0) })),
}

return snippets, autosnippets
