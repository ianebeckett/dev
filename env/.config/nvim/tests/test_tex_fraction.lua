-- Pure parser tests: nvim --headless -u NONE -i NONE -l tests/test_tex_fraction.lua
local root = vim.fn.fnamemodify(debug.getinfo(1, 'S').source:sub(2), ':p:h:h')
vim.opt.rtp:prepend(root)
local match = require('tex_fraction').match
local cases = {
    { '//', '//', '' },
    { '$3/', '3/', '3' },
    { [=[$4\pi^2/]=], [=[4\pi^2/]=], [=[4\pi^2]=] },
    { [=[$4\pi ^{2}/]=], [=[4\pi ^{2}/]=], [=[4\pi ^{2}]=] },
    { '$(1 + 2 + 3)/', '(1 + 2 + 3)/', '1 + 2 + 3' },
    { '$(1+(2+3)/', '(2+3)/', '2+3' },
    { '$(1 + (2+3))/', '(1 + (2+3))/', '1 + (2+3)' },
    { '$a+b/', 'b/', 'b' },
    { '$12.5x_{i+1}^{2}/', '12.5x_{i+1}^{2}/', '12.5x_{i+1}^{2}' },
    { [=[$a\leq\pi/]=], [=[\pi/]=], [=[\pi]=] },
    { '$2(x+1)/', '2(x+1)/', '2(x+1)' },
    { [=[$\sin(x)/]=], [=[\sin(x)/]=], [=[\sin(x)]=] },
    { [=[$\left(1+x\right)/]=], [=[\left(1+x\right)/]=], [=[\left(1+x\right)]=] },
    { [=[$\frac{a+b}{c}/]=], [=[\frac{a+b}{c}/]=], [=[\frac{a+b}{c}]=] },
    { [=[$\frac{a}{3/]=], '3/', '3' },
    { '$[a+b]/', '[a+b]/', '[a+b]' },
}
for _, case in ipairs(cases) do
    local trigger, captures = match(case[1])
    assert(trigger == case[2], vim.inspect({input = case[1], expected = case[2], actual = trigger}))
    assert(captures[1] == case[3], vim.inspect({input = case[1], expected = case[3], actual = captures}))
end
for _, line in ipairs({ '/', '$3 /', '$()/','$(a+b]/', '$a+b)/', '$^2/', '$x^/',
    [=[$\sum_i/]=], [=[$\/]=], [=[$\left\{x\right\}/]=] }) do
    assert(match(line) == nil, 'Should not capture ' .. line)
end
print('26 slash-fraction parser cases passed')
vim.cmd('qa!')
