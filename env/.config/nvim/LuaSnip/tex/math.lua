local ls = require('luasnip')
local s, i, t = ls.snippet, ls.insert_node, ls.text_node
local fmta = require('luasnip.extras.fmt').fmta
local context = require('tex_context')

local autosnippets = {
    s({ trig = 'ff', name = 'Fraction', condition = context.math, show_condition = context.math },
        fmta('\\frac{<>}{<>}<>', { i(1), i(2), i(0) })),
    s({ trig = 'sr', name = 'Square root', condition = context.math, show_condition = context.math },
        fmta('\\sqrt{<>}<>', { i(1), i(0) })),
    s({ trig = '__', name = 'Subscript', wordTrig = false, condition = context.math, show_condition = context.math },
        fmta('_{<>}<>', { i(1), i(0) })),
    s({ trig = '^^', name = 'Superscript', wordTrig = false, condition = context.math, show_condition = context.math },
        fmta('^{<>}<>', { i(1), i(0) })),
    s({ trig = 'sum', name = 'Sum with limits', condition = context.math, show_condition = context.math },
        fmta('\\sum_{<>}^{<>} <>', { i(1, 'i=1'), i(2, 'n'), i(0) })),
    s({ trig = 'int', name = 'Integral with limits', condition = context.math, show_condition = context.math },
        fmta('\\int_{<>}^{<>} <>\\,\\mathrm{d}<>', { i(1, 'a'), i(2, 'b'), i(3), i(4, 'x') })),
    s({ trig = 'lim', name = 'Limit', condition = context.math, show_condition = context.math },
        fmta('\\lim_{<> \\to <>} <>', { i(1, 'n'), i(2, '\\infty'), i(0) })),
    s({ trig = 'tt', name = 'Text within math', condition = context.math, show_condition = context.math },
        fmta('\\text{<>}<>', { i(1), i(0) })),
}

-- A prefix makes symbols available directly after variables without rewriting
-- ordinary words. The trailing space terminates each TeX control word.
local symbols = {
    { ';in', 'in' }, { ';le', 'leq' }, { ';ge', 'geq' },
    { ';ne', 'neq' }, { ';to', 'to' }, { ';iff', 'iff' },
    { ';oo', 'infty' },
    { ';fa', 'forall' }, { ';ex', 'exists' }, { ';ni', 'notin' },
    { ';sb', 'subseteq' }, { ';cu', 'cup' }, { ';ca', 'cap' },
    { ';es', 'emptyset' }, { ';cd', 'cdot' }, { ';tm', 'times' },
    { ';ot', 'otimes' }, { ';ap', 'approx' }, { ';sm', 'sim' },
    { ';sc', 'succeq' }, { ';pc', 'preceq' }, { ';as', 'gets' },
    { ';pt', 'propto' }, { ';nb', 'nabla' }, { ';pd', 'partial' },
    { ';ell', 'ell' }, { ';df', 'mathrel{:=}' },
    { ';iid', 'overset{\\mathrm{iid}}{\\sim}' },
}
for _, symbol in ipairs(symbols) do
    table.insert(autosnippets, s({ trig = symbol[1], name = '\\' .. symbol[2],
        wordTrig = false, condition = context.math, show_condition = context.math }, { t('\\' .. symbol[2] .. ' ') }))
end

return {}, autosnippets
