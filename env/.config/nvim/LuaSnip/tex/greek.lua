local ls = require('luasnip')
local s, t = ls.snippet, ls.text_node
local context = require('tex_context')

-- Standard LaTeX has dedicated commands for eleven Greek capitals. The
-- remaining capitals use upright Latin-shaped glyphs; omicron uses o/O.
-- Preserve the existing epsilon trigger's varepsilon shape.
local letters = {
    { 'al', 'alpha',      [[\mathrm{A}]] },
    { 'be', 'beta',       [[\mathrm{B}]] },
    { 'ga', 'gamma',      [[\Gamma]] },
    { 'de', 'delta',      [[\Delta]] },
    { 'ep', 'varepsilon', [[\mathrm{E}]] },
    { 'ze', 'zeta',       [[\mathrm{Z}]] },
    { 'et', 'eta',        [[\mathrm{H}]] },
    { 'th', 'theta',      [[\Theta]] },
    { 'io', 'iota',       [[\mathrm{I}]] },
    { 'ka', 'kappa',      [[\mathrm{K}]] },
    { 'la', 'lambda',     [[\Lambda]] },
    { 'mu', 'mu',         [[\mathrm{M}]] },
    { 'nu', 'nu',         [[\mathrm{N}]] },
    { 'xi', 'xi',         [[\Xi]] },
    { 'oc', 'omicron',    [[\mathrm{O}]] },
    { 'pi', 'pi',         [[\Pi]] },
    { 'rh', 'rho',        [[\mathrm{P}]] },
    { 'si', 'sigma',      [[\Sigma]] },
    { 'ta', 'tau',        [[\mathrm{T}]] },
    { 'up', 'upsilon',    [[\Upsilon]] },
    { 'ph', 'phi',        [[\Phi]] },
    { 'ch', 'chi',        [[\mathrm{X}]] },
    { 'ps', 'psi',        [[\Psi]] },
    { 'om', 'omega',      [[\Omega]] },
}

local snippets, autosnippets = {}, {}
for _, letter in ipairs(letters) do
    local lower, name, upper_body = unpack(letter)
    local upper = lower:sub(1, 1):upper() .. lower:sub(2)
    local lower_body = name == 'omicron' and 'o' or '\\' .. name
    local upper_name = name:gsub('^var', ''):gsub('^%l', string.upper)
    table.insert(autosnippets, s({ trig = ';' .. lower, name = lower_body,
        wordTrig = false, condition = context.math, show_condition = context.math }, { t(lower_body .. ' ') }))
    table.insert(autosnippets, s({ trig = ';' .. upper, name = upper_name .. ': ' .. upper_body,
        wordTrig = false, condition = context.math, show_condition = context.math }, { t(upper_body .. ' ') }))
    -- Exact manual aliases also make a query such as Th useful in completion.
    table.insert(snippets, s({ trig = upper, name = upper_name .. ': ' .. upper_body,
        condition = context.math, show_condition = context.math }, { t(upper_body .. ' ') }))
end

return snippets, autosnippets
