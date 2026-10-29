local ls = require('luasnip')
local s, i = ls.snippet, ls.insert_node
local fmta = require('luasnip.extras.fmt').fmta
local context = require('tex_context')

return {}, {
    s({ trig = 'mk', name = 'Inline math', condition = context.text, show_condition = context.text },
        fmta('$<>$<>', { i(1), i(0) })),
    s({ trig = 'dm', name = 'Display math', condition = context.text_line, show_condition = context.text },
        fmta('\\[\n    <>\n\\]\n<>', { i(1), i(0) })),
    s({ trig = 'lr', name = 'Sized parentheses', condition = context.math, show_condition = context.math },
        fmta('\\left(<>\\right)<>', { i(1), i(0) })),
}
