-- Run from this config: nvim --headless -u NONE -i NONE -l tests/test_tex_snippets.lua
-- Uses installed plugins, real keystrokes, and a temporary TeX document. No GUI.
local root = vim.fn.fnamemodify(debug.getinfo(1, 'S').source:sub(2), ':p:h:h')
local scratch = assert(vim.uv.fs_mkdtemp('/tmp/nvim-tex-snippets-XXXXXX'))
local errors = {}
local child = vim.fn.jobstart({vim.v.progpath, '--headless', '--embed', '-u', 'NONE', '-i', 'NONE'}, {
    rpc = true,
    env = { NVIM_LOG_FILE = scratch .. '/child.log', XDG_CACHE_HOME = scratch .. '/cache',
        XDG_STATE_HOME = scratch .. '/state', XDG_RUNTIME_DIR = scratch },
    on_stderr = function(_, lines) vim.list_extend(errors, lines) end,
})
assert(child > 0, 'Could not start test Neovim')
local function lua(code, args)
    return vim.rpcrequest(child, 'nvim_exec_lua', code, args or {})
end
local function key(value)
    vim.rpcrequest(child, 'nvim_input', value)
    vim.wait(50)
    vim.rpcrequest(child, 'nvim_eval', '1')
end
local function type_keys(value)
    while #value > 0 do
        local token = value:match('^<[^>]+>') or value:sub(1, 1)
        key(token)
        value = value:sub(#token + 1)
    end
end
local number = 0
local function document(body)
    key('<Esc>')
    number = number + 1
    lua([=[
        local scratch, number, body = ...
        vim.cmd.enew({bang = true})
        vim.bo.swapfile = false
        vim.opt.virtualedit = 'onemore'
        vim.opt.expandtab = true
        vim.opt.shiftwidth = 4
        vim.api.nvim_buf_set_name(0, scratch .. '/case-' .. number .. '.tex')
        local lines = {[[\documentclass{article}]], [[\usepackage{amsmath,amssymb}]], [[\begin{document}]]}
        local cursor
        for _, line in ipairs(vim.split(body, '\n', {plain = true})) do
            local column = line:find('[CURSOR]', 1, true)
            if column then
                cursor = {#lines + 1, column - 1}
                line = line:sub(1, column - 1) .. line:sub(column + 8)
            end
            table.insert(lines, line)
        end
        table.insert(lines, [[\end{document}]])
        vim.api.nvim_buf_set_lines(0, 0, -1, false, lines)
        vim.bo.filetype = 'tex'
        vim.api.nvim_win_set_cursor(0, assert(cursor))
    ]=], {scratch, number, body})
    key('i')
end
local function body()
    return lua([=[return table.concat(vim.api.nvim_buf_get_lines(0, 3, -2, false), '\n')]=])
end
local function expect(expected)
    assert(vim.wait(1000, function() return body() == expected end, 20),
        'Expected ' .. vim.inspect(expected) .. ', got ' .. vim.inspect(body()))
end
local passed = 0
local function test(name, fn)
    fn()
    passed = passed + 1
    print('PASS: ' .. name)
end
local examples = {}
local function save_example()
    table.insert(examples, body())
end

local ok, failure = xpcall(function()
    lua([=[
        local root, scratch = ...
        vim.opt.rtp = {vim.env.VIMRUNTIME, root}
        for _, name in ipairs({'vimtex', 'LuaSnip', 'blink.cmp', 'nvim-treesitter'}) do
            local paths = vim.fn.globpath(vim.o.packpath, 'pack/*/opt/' .. name, false, true)
            assert(#paths > 0, 'Open the normal config once to install ' .. name)
            vim.opt.rtp:prepend(paths[1])
        end
        vim.opt.rtp:append(root .. '/after')
        vim.g.vimtex_compiler_enabled = 0
        vim.g.vimtex_view_enabled = 0
        vim.g.vimtex_cache_root = scratch .. '/vimtex'
        vim.cmd('runtime plugin/vimtex.vim')
        vim.cmd('runtime plugin/luasnip.vim')
        vim.cmd('runtime plugin/luasnip.lua')
        dofile(root .. '/after/plugin/blink.cmp/blink.cmp.lua')
        dofile(root .. '/after/plugin/luasnip/luasnip.lua')
        -- Provisioning parsers is outside this test; run the real FileType setup.
        require('nvim-treesitter').install = function() end
        dofile(root .. '/after/plugin/nvim-treesitter/nvim-treesitter.lua')
        vim.cmd('filetype plugin indent on')
        vim.cmd('syntax enable')
    ]=], {root, scratch})

    test('VimTeX owns TeX syntax and indentation', function()
        document('[CURSOR]')
        assert(lua('return vim.bo.syntax') == 'tex')
        assert(lua('return vim.bo.indentexpr') == 'VimtexIndentExpr()')
        assert(lua('return vim.treesitter.highlighter.active[vim.api.nvim_get_current_buf()] == nil'))
    end)
    test('automatic triggers have no ambiguous prefixes', function()
        assert(lua([=[
            local snippets = require('luasnip').get_snippets('tex', {type = 'autosnippets'})
            for a, first in ipairs(snippets) do
                for b, second in ipairs(snippets) do
                    if a ~= b then
                        assert(second.trigger:sub(1, #first.trigger) ~= first.trigger,
                            first.trigger .. ' expands before ' .. second.trigger)
                    end
                end
            end
            return true
        ]=]))
    end)
    test('inline math, fraction, and exit to prose', function()
        document('[CURSOR]')
        type_keys('mkff')
        expect('$\\frac{}{}$')
        type_keys('a<C-k>b<C-k><C-k> done')
        expect('$\\frac{a}{b}$ done')
        save_example()
    end)
    test('double slash creates an empty fraction with ordinary navigation', function()
        document('$[CURSOR]$')
        type_keys('//a<C-k>b<C-k>')
        expect([[$\frac{a}{b}$]])
        save_example()
    end)
    test('postfix slash captures each requested expression and enters its denominator', function()
        local cases = {
            {'3', [=[\frac{3}{x}]=]},
            {[=[4\pi^2]=], [=[\frac{4\pi^2}{x}]=]},
            {'(1 + 2 + 3)', [=[\frac{1 + 2 + 3}{x}]=]},
            {'(1 + (2+3))', [=[\frac{1 + (2+3)}{x}]=]},
        }
        for _, case in ipairs(cases) do
            document('$[CURSOR]$')
            type_keys(case[1] .. '/x<C-k>')
            expect('$' .. case[2] .. '$')
            save_example()
        end
        document('$(1+(2+3)[CURSOR])$')
        type_keys('/x<C-k>')
        expect([[$(1+\frac{2+3}{x})$]])
        save_example()
    end)
    test('postfix numerator can be revisited with Ctrl-J', function()
        document('$[CURSOR]$')
        type_keys('3/b<C-j>4<C-k><C-k>')
        expect([[$\frac{4}{b}$]])
        save_example()
    end)
    test('postfix fractions accept Greek and superscript snippet output', function()
        document('$[CURSOR]$')
        type_keys('4;pi^^2<C-k>/x<C-k>')
        expect([=[$\frac{4\pi ^{2}}{x}$]=])
        save_example()
    end)
    test('slash fractions nest in an existing snippet', function()
        document('[CURSOR]')
        type_keys('mkff1<C-k>3/4<C-k><C-k><C-k> done')
        expect([[$\frac{1}{\frac{3}{4}}$ done]])
        save_example()
    end)
    test('slash fractions respect math context and literal spaced division', function()
        for _, content in ipairs({'[CURSOR]', '% [CURSOR]', [=[$\text{[CURSOR]}$]=],
            [=[\verb|[CURSOR]|]=]}) do
            document(content)
            type_keys('3/ //')
            expect(content:gsub('%[CURSOR%]', '3/ //'))
        end
        document('$[CURSOR]$')
        type_keys('3 / 4')
        expect('$3 / 4$')
        save_example()
    end)
    test('nested square root and backward jumps', function()
        document('[CURSOR]')
        type_keys('mkffsrx<C-k><C-k>b<C-j>')
        -- Re-enter the numerator, then navigate forward out of both snippets.
        assert(lua('return require("luasnip").jumpable(1)'))
        type_keys('<C-k><C-k><C-k>')
        expect('$\\frac{\\sqrt{x}}{b}$')
        save_example()
    end)
    test('backward jump edits the earlier placeholder', function()
        document('[CURSOR]')
        type_keys('mkffa<C-k>b<C-j>c<C-k><C-k><C-k>')
        expect('$\\frac{c}{b}$')
    end)
    test('math snippets do not expand in prose, comments, or text arguments', function()
        for _, content in ipairs({'[CURSOR]', '% [CURSOR]', '$\\text{[CURSOR]}$'}) do
            document(content)
            type_keys('ff ;al RR __ ^^ sum int lim')
            expect(content:gsub('%[CURSOR%]', 'ff ;al RR __ ^^ sum int lim'))
            assert(not lua('return require("tex_context").math()'))
        end
    end)
    test('comments and verbatim also block math-entry snippets', function()
        for _, content in ipairs({'% [CURSOR]', '\\verb|[CURSOR]|', '\\begin{verbatim}\n[CURSOR]\n\\end{verbatim}'}) do
            document(content)
            type_keys('mk dm')
            expect(content:gsub('%[CURSOR%]', 'mk dm'))
        end
    end)
    test('word boundaries and literal TeX commands are preserved', function()
        document('[CURSOR]')
        type_keys('bookmk mid dm')
        expect('bookmk mid dm')
        document('$[CURSOR]$')
        type_keys('\\sum \\int \\lim \\RR suffer')
        expect('$\\sum \\int \\lim \\RR suffer$')
    end)
    test('symbols, number sets, scripts, and manual fonts', function()
        document('$[CURSOR]$')
        type_keys(';al;leRR + x__n<C-k>')
        type_keys('^^2<C-k>')
        type_keys(' + bb')
        type_keys('<C-k>')
        type_keys('F<C-k>')
        expect('$\\alpha \\leq \\mathbb{R} + x_{n}^{2} + \\mathbb{F}$')
        save_example()
        document('[CURSOR]')
        type_keys('bb<C-k>')
        expect('bb')
        assert(not lua([=[
            for _, snippet in ipairs(require('luasnip').get_snippets('tex')) do
                if snippet.trigger == 'bb' then return snippet.show_condition() end
            end
            error('bb missing')
        ]=]))
    end)
    test('display math and operators with default limits', function()
        document('[CURSOR]')
        type_keys('dmsum<C-k><C-k>x__i<C-k><C-k>')
        expect('\\[\n    \\sum_{i=1}^{n} x_{i}\n\\]\n')
        save_example()
        document('$[CURSOR]$')
        type_keys('int<C-k><C-k>f(x)<C-k><C-k>')
        expect('$\\int_{a}^{b} f(x)\\,\\mathrm{d}x$')
        save_example()
        document('$[CURSOR]$')
        type_keys('lim<C-k><C-k>x__n<C-k>')
        expect('$\\lim_{n \\to \\infty} x_{n}$')
        save_example()
    end)
    test('matrix, cases, and aligned equations', function()
        document('$[CURSOR]$')
        type_keys('mat1<C-k>0<C-k>0<C-k>1<C-k>')
        expect('$\\begin{pmatrix}\n    1 & 0 \\\\\n    0 & 1\n\\end{pmatrix}$')
        save_example()
        document('$[CURSOR]$')
        type_keys('casesx<C-k>x>0<C-k>0<C-k>x=0<C-k>')
        expect('$\\begin{cases}\n    x & x>0 \\\\\n    0 & x=0\n\\end{cases}$')
        save_example()
        document('[CURSOR]')
        type_keys('alia<C-k>b<C-k>c<C-k>d<C-k>')
        expect('\\begin{align*}\n    a &= b \\\\\n    c &= d\n\\end{align*}\n')
        save_example()
    end)
    test('generic environment mirrors its edited name', function()
        document('[CURSOR]')
        type_keys('beg<C-k>enumerate<C-k>\\item First<C-k>')
        expect('\\begin{enumerate}\n    \\item First\n\\end{enumerate}\n')
        save_example()
    end)
    test('uppercase Theta is available in completion and through Ctrl-K', function()
        document('$[CURSOR]$')
        type_keys('Th')
        assert(vim.wait(2000, function()
            return lua([=[
                for _, item in ipairs(require('blink.cmp').get_items()) do
                    if item.label == 'Th' then return true end
                end
                return false
            ]=])
        end, 20), 'Uppercase Th missing from Blink completion')
        lua([=[
            for index, item in ipairs(require('blink.cmp').get_items()) do
                if item.label == 'Th' then
                    require('blink.cmp').accept({index = index})
                    return
                end
            end
        ]=])
        expect([[$\Theta $]])
        document('$[CURSOR]$')
        type_keys('Th<C-k>')
        expect([[$\Theta $]])
        save_example()
    end)
    test('all Greek letters have lowercase and uppercase expansions', function()
        local alphabet = {
            {'al', [[\alpha]], [[\mathrm{A}]]}, {'be', [[\beta]], [[\mathrm{B}]]},
            {'ga', [[\gamma]], [[\Gamma]]}, {'de', [[\delta]], [[\Delta]]},
            {'ep', [[\varepsilon]], [[\mathrm{E}]]}, {'ze', [[\zeta]], [[\mathrm{Z}]]},
            {'et', [[\eta]], [[\mathrm{H}]]}, {'th', [[\theta]], [[\Theta]]},
            {'io', [[\iota]], [[\mathrm{I}]]}, {'ka', [[\kappa]], [[\mathrm{K}]]},
            {'la', [[\lambda]], [[\Lambda]]}, {'mu', [[\mu]], [[\mathrm{M}]]},
            {'nu', [[\nu]], [[\mathrm{N}]]}, {'xi', [[\xi]], [[\Xi]]},
            {'oc', 'o', [[\mathrm{O}]]}, {'pi', [[\pi]], [[\Pi]]},
            {'rh', [[\rho]], [[\mathrm{P}]]}, {'si', [[\sigma]], [[\Sigma]]},
            {'ta', [[\tau]], [[\mathrm{T}]]}, {'up', [[\upsilon]], [[\Upsilon]]},
            {'ph', [[\phi]], [[\Phi]]}, {'ch', [[\chi]], [[\mathrm{X}]]},
            {'ps', [[\psi]], [[\Psi]]}, {'om', [[\omega]], [[\Omega]]},
        }
        for _, letter in ipairs(alphabet) do
            document('$[CURSOR]$')
            local upper = letter[1]:sub(1, 1):upper() .. letter[1]:sub(2)
            type_keys(';' .. letter[1] .. ';' .. upper .. upper .. '<C-k>')
            expect('$' .. letter[2] .. ' ' .. letter[3] .. ' ' .. letter[3] .. ' $')
            save_example()
        end
    end)
    test('uppercase Greek still respects prose and comment contexts', function()
        for _, content in ipairs({'[CURSOR]', '% [CURSOR]', [[$\text{[CURSOR]}$]]}) do
            document(content)
            type_keys(';Th Th<C-k>')
            expect(content:gsub('%[CURSOR%]', ';Th Th'))
        end
    end)
    test('manual triggers are not consumed by shorter autosnippets', function()
        assert(lua([=[
            local ls = require('luasnip')
            for _, manual in ipairs(ls.get_snippets('tex')) do
                for _, automatic in ipairs(ls.get_snippets('tex', {type = 'autosnippets'})) do
                    assert(manual.trigger:sub(1, #automatic.trigger) ~= automatic.trigger,
                        automatic.trigger .. ' expands before manual ' .. manual.trigger)
                end
            end
            return true
        ]=]))
    end)
    test('course probabilities accept nested fractions and conditioning', function()
        document('$[CURSOR]$')
        type_keys('prbX;geff1<C-k>n<C-k><C-k>')
        expect([[$\Pr\left[X\geq \frac{1}{n}\right]$]])
        save_example()
        document('$[CURSOR]$')
        type_keys('cprA<C-k>B<C-k>')
        expect([[$\Pr\left[A\,\middle|\,B\right]$]])
        save_example()
    end)
    test('course norms have editable indices and composable inner products', function()
        document('$[CURSOR]$')
        type_keys('nrmf<C-k>p<C-k> + innu<C-k>v<C-k>')
        expect([[$\left\lVert f \right\rVert_{p} + \left\langle u,v \right\rangle$]])
        save_example()
    end)
    test('complexity templates wait for manual expansion', function()
        document('$[CURSOR]$')
        type_keys('bigTheta')
        expect('$bigTheta$')
        type_keys('<C-k>m<C-k>')
        expect([[$\Theta\!\left(m\right)$]])
        save_example()
    end)
    test('optimization templates mirror variable and time-index edits', function()
        document('$[CURSOR]$')
        type_keys('gdstep<C-k>z<C-k>s<C-k><C-k>F<C-k>')
        expect([[$z_{s+1}=z_{s}-\eta_{s}\nabla F\!\left(z_{s}\right)$]])
        save_example()
    end)
    test('privacy templates mirror mechanism and output-event edits', function()
        document('$[CURSOR]$')
        type_keys('dpineq<C-k>A<C-k>D<C-k>S<C-k>e<C-k>E<C-k>d<C-k>')
        expect([[$\Pr\left[A(D)\in S\right]\leq e^{e}\Pr\left[A(E)\in S\right]+d$]])
        save_example()
    end)
    test('course notation stays out of prose, comments, and text arguments', function()
        for _, content in ipairs({'[CURSOR]', '% [CURSOR]', [[$\text{[CURSOR]}$]]}) do
            document(content)
            type_keys('prb exv nrm ;fa dpineq<C-k>')
            expect(content:gsub('%[CURSOR%]', 'prb exv nrm ;fa dpineq'))
        end
    end)
    test('new relation symbols do not collide with Greek letters', function()
        document('$[CURSOR]$')
        type_keys(';fa;ex;sb;sc;iid')
        expect([[$\forall \exists \subseteq \succeq \overset{\mathrm{iid}}{\sim} $]])
        save_example()
    end)
    test('every course template expands for the compilation smoke test', function()
        local triggers = lua([=[
            local result = {}
            for _, kind in ipairs({'snippets', 'autosnippets'}) do
                for _, snippet in ipairs(require('luasnip').get_snippets('tex', {type = kind})) do
                    if snippet.name:match('^Data science:') then
                        table.insert(result, {trigger = snippet.trigger, kind = kind})
                    end
                end
            end
            return result
        ]=])
        assert(#triggers >= 60, 'Course snippet file did not fully load')
        for _, entry in ipairs(triggers) do
            document('$[CURSOR]$')
            lua([=[
                local entry = ...
                local ls = require('luasnip')
                for _, snippet in ipairs(ls.get_snippets('tex', {type = entry.kind})) do
                    if snippet.trigger == entry.trigger then
                        ls.snip_expand(snippet)
                        return
                    end
                end
                error('Missing template ' .. entry.trigger)
            ]=], {entry})
            assert(not body():find('<%d+>'), 'Unexpanded placeholder in ' .. entry.trigger)
            save_example()
        end
        print('Expanded ' .. #triggers .. ' course templates for compilation')
    end)
    test('generated examples compile as LaTeX', function()
        local lines = { [[\documentclass{article}]], [[\usepackage{amsmath,amssymb}]], [[\begin{document}]] }
        for _, example in ipairs(examples) do
            vim.list_extend(lines, vim.split(example, '\n', {plain = true}))
            table.insert(lines, '')
        end
        table.insert(lines, [[\end{document}]])
        vim.fn.writefile(lines, scratch .. '/snippets.tex')
        local output = vim.fn.system({'latexmk', '-cd', '-pdf', '-interaction=nonstopmode',
            '-halt-on-error', scratch .. '/snippets.tex'})
        assert(vim.v.shell_error == 0, output)
    end)
end, debug.traceback)
vim.fn.jobstop(child)
vim.fn.jobwait({child}, 2000)
if not ok then
    io.stderr:write(tostring(failure) .. '\n' .. table.concat(errors, '\n') .. '\nArtifacts: ' .. scratch .. '\n')
    vim.cmd('cquit 1')
end
print(passed .. ' snippet tests passed; artifacts: ' .. scratch)
vim.cmd('qa!')
