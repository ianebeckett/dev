local ls = require('luasnip')
local s, i = ls.snippet, ls.insert_node
local fmta = require('luasnip.extras.fmt').fmta
local context = require('tex_context')

local snippets, autosnippets = {}, {}
local function add(target, definition)
    local trigger, name, template, defaults = unpack(definition)
    local nodes = {}
    for index, default in ipairs(defaults) do nodes[index] = i(index, default) end
    nodes[#nodes + 1] = i(0)
    -- Numbered placeholders mirror repeated variables without extra tab stops.
    table.insert(target, s({ trig = trigger, name = 'Data science: ' .. name,
        condition = context.math, show_condition = context.math },
        fmta(template .. '<' .. #nodes .. '>', nodes, { repeat_duplicates = true })))
end

local automatic = {
    -- Probability and concentration notation.
    { 'prb', 'Probability', [=[\Pr\left[<1>\right]]=], { 'A' } },
    { 'prx', 'Probability over a random choice', [=[\Pr_{<1>}\left[<2>\right]]=], { [=[h\sim\mathcal{H}]=], 'A' } },
    { 'cpr', 'Conditional probability', [=[\Pr\left[<1>\,\middle|\,<2>\right]]=], { 'A', 'B' } },
    { 'exv', 'Expectation', [=[\mathbb{E}\left[<1>\right]]=], { 'X' } },
    { 'cex', 'Conditional expectation', [=[\mathbb{E}\left[<1>\,\middle|\,<2>\right]]=], { 'X', 'Y' } },
    { 'var', 'Variance', [=[\operatorname{Var}\left[<1>\right]]=], { 'X' } },
    { 'cov', 'Covariance', [=[\operatorname{Cov}\left(<1>,<2>\right)]=], { 'X', 'Y' } },
    { 'ind', 'Indicator', [=[\mathbf{1}_{\{<1>\}}]=], { 'A' } },
    -- Geometry, sets, and estimators.
    { 'nrm', 'Norm with editable index', [=[\left\lVert <1> \right\rVert_{<2>}]=], { 'x', '2' } },
    { 'nr2', 'Squared Euclidean norm', [=[\left\lVert <1> \right\rVert_{2}^{2}]=], { 'x' } },
    { 'nrF', 'Frobenius norm', [=[\left\lVert <1> \right\rVert_{F}]=], { 'A' } },
    { 'abs', 'Absolute value or cardinality', [=[\left\lvert <1> \right\rvert]=], { 'x' } },
    { 'inn', 'Inner product', [=[\left\langle <1>,<2> \right\rangle]=], { 'x', 'y' } },
    { 'set', 'Set', [=[\left\{<1>\right\}]=], { 'x' } },
    { 'sbt', 'Set builder', [=[\left\{<1>\,\middle|\,<2>\right\}]=], { 'x', [=[x\in S]=] } },
    { 'ceil', 'Ceiling', [=[\left\lceil <1> \right\rceil]=], { 'x' } },
    { 'flr', 'Floor', [=[\left\lfloor <1> \right\rfloor]=], { 'x' } },
    { 'idx', 'Index set', [=[[<1>]]=], { 'n' } },
    { 'vct', 'Bold vector or Greek symbol', [=[\boldsymbol{<1>}]=], { 'x' } },
    { 'hat', 'Estimator accent', [=[\widehat{<1>}]=], { 'x' } },
    { 'til', 'Approximation accent', [=[\widetilde{<1>}]=], { 'x' } },
    { 'prod', 'Product with limits', [=[\prod_{<1>}^{<2>} <3>]=], { 'i=1', 'n', 'x_i' } },
}

local manual = {
    -- Complexity of streaming/distributed algorithms, sample bounds, and regret.
    { 'bigO', 'Big O', [=[O\!\left(<1>\right)]=], { 'n' } },
    { 'bigOmega', 'Big Omega', [=[\Omega\!\left(<1>\right)]=], { 'n' } },
    { 'bigTheta', 'Big Theta', [=[\Theta\!\left(<1>\right)]=], { 'n' } },
    { 'littleo', 'Little o', [=[o\!\left(<1>\right)]=], { 'n' } },
    { 'littleomega', 'Little omega', [=[\omega\!\left(<1>\right)]=], { 'n' } },
    { 'softO', 'Soft O (suppressed logarithmic factors)', [=[\widetilde{O}\!\left(<1>\right)]=], { 'n' } },
    { 'logb', 'Logarithm with editable base', [=[\log_{<1>}\!\left(<2>\right)]=], { '2', 'n' } },
    { 'binom', 'Binomial coefficient', [=[\binom{<1>}{<2>}]=], { 'n', 'k' } },
    -- Distributions: parameters remain editable, including scalar/vector normals.
    { 'normal', 'Normal distribution (mean, variance/covariance)', [=[\mathcal{N}\!\left(<1>,<2>\right)]=], { [=[\mu]=], [=[\sigma^2]=] } },
    { 'bern', 'Bernoulli distribution', [=[\operatorname{Bernoulli}\!\left(<1>\right)]=], { 'p' } },
    { 'binomial', 'Binomial distribution', [=[\operatorname{Bin}\!\left(<1>,<2>\right)]=], { 'n', 'p' } },
    { 'poisson', 'Poisson distribution', [=[\operatorname{Poisson}\!\left(<1>\right)]=], { [=[\lambda]=] } },
    { 'laplace', 'Laplace distribution (location, scale)', [=[\operatorname{Lap}\!\left(<1>,<2>\right)]=], { '0', 'b' } },
    { 'uniform', 'Uniform distribution', [=[\operatorname{Unif}\!\left(<1>\right)]=], { 'S' } },
    -- Linear algebra and optimization building blocks.
    { 'trans', 'Transpose', [=[<1>^{\mathsf{T}}]=], { 'A' } },
    { 'pinv', 'Pseudoinverse', [=[<1>^{\dagger}]=], { 'A' } },
    { 'rank', 'Rank', [=[\operatorname{rank}\!\left(<1>\right)]=], { 'A' } },
    { 'trace', 'Trace', [=[\operatorname{tr}\!\left(<1>\right)]=], { 'A' } },
    { 'diag', 'Diagonal matrix', [=[\operatorname{diag}\!\left(<1>\right)]=], { 'd' } },
    { 'span', 'Linear span', [=[\operatorname{span}\!\left\{<1>\right\}]=], { [=[v_1,\ldots,v_k]=] } },
    { 'supp', 'Support', [=[\operatorname{supp}\!\left(<1>\right)]=], { 'f' } },
    { 'nnz', 'Number of nonzero entries', [=[\operatorname{nnz}\!\left(<1>\right)]=], { 'A' } },
    { 'argmin', 'Arg min', [=[\operatorname*{arg\,min}_{<1>} <2>]=], { [=[x\in\mathcal{X}]=], 'f(x)' } },
    { 'argmax', 'Arg max', [=[\operatorname*{arg\,max}_{<1>} <2>]=], { [=[x\in\mathcal{X}]=], 'f(x)' } },
    { 'grad', 'Gradient', [=[\nabla_{<1>} <2>]=], { 'x', 'f(x)' } },
    { 'pdv', 'Partial derivative', [=[\frac{\partial <1>}{\partial <2>}]=], { 'f', 'x' } },
    { 'proj', 'Projection', [=[\Pi_{<1>}\!\left(<2>\right)]=], { [=[\mathcal{C}]=], 'x' } },
    { 'gdstep', 'Gradient descent update', [=[<1>_{<2>+1}=<1>_{<2>}-<3>_{<2>}\nabla <4>\!\left(<1>_{<2>}\right)]=], { 'x', 't', [=[\eta]=], 'f' } },
    { 'sgdstep', 'SGD update (g is the stochastic gradient)', [=[<1>_{<2>+1}=<1>_{<2>}-<3>_{<2>}<4>_{<2>}]=], { 'x', 't', [=[\eta]=], 'g' } },
    { 'opt', 'Constrained optimization (LP/SDP template)', [=[\begin{aligned}
    \underset{<1>}{\operatorname{minimize}}\quad & <2> \\
    \text{subject to}\quad & <3>
\end{aligned}]=], { 'x', 'f(x)', [=[g(x)\leq 0]=] } },
    { 'lsq', 'Least-squares objective', [=[\operatorname*{arg\,min}_{<1>}\left\lVert <2> <1>-<3>\right\rVert_2^2]=], { 'x', 'A', 'b' } },
    { 'svd', 'SVD factorization', [=[<1>=<2> <3> <4>^{\mathsf{T}}]=], { 'A', 'U', [=[\Sigma]=], 'V' } },
    { 'regret', 'External regret against the best fixed action', [=[R_{<1>}=\sum_{t=1}^{<1>}<2>_t(<3>_t)-\min_{<3>\in <4>}\sum_{t=1}^{<1>}<2>_t(<3>)]=], { 'T', [=[\ell]=], 'x', [=[\mathcal{X}]=] } },
    -- Course expressions, expanded manually so their assumptions stay deliberate.
    { 'fmom', 'Frequency moment (sum over nonzero coordinates)', [=[F_{<1>}=\sum_{i\in\operatorname{supp}(<2>)}\left|<2>_i\right|^{<1>}]=], { 'p', 'f' } },
    { 'lsh', 'Hash collision probability', [=[\Pr_{<1>\sim <2>}\left[<1>(<3>)=<1>(<4>)\right]]=], { 'h', [=[\mathcal{H}]=], 'x', 'y' } },
    { 'jl', 'JL squared-distance preservation (requires a suitable embedding)', [=[(1-<1>)\left\lVert <2>\right\rVert_2^2\leq\left\lVert <3>(<2>)\right\rVert_2^2\leq(1+<1>)\left\lVert <2>\right\rVert_2^2]=], { [=[\varepsilon]=], 'x-y', [=[\Pi]=] } },
    { 'relerr', 'Relative-error guarantee (e.g. coreset cost)', [=[(1-<1>)<2>\leq <3>\leq(1+<1>)<2>]=], { [=[\varepsilon]=], 'C', [=[\widehat{C}]=] } },
    { 'dpineq', 'DP inequality (all adjacent datasets and output events)', [=[\Pr\left[<1>(<2>)\in <3>\right]\leq e^{<4>}\Pr\left[<1>(<5>)\in <3>\right]+<6>]=], { [=[\mathcal{M}]=], 'D', 'S', [=[\varepsilon]=], "D'", [=[\delta]=] } },
    { 'sens', 'Global p-norm sensitivity (adjacent D and D prime)', [=[\Delta_{<1>}(<2>)=\sup_{D\sim D'}\left\lVert <2>(D)-<2>(D')\right\rVert_{<1>}]=], { '1', 'f' } },
    { 'softmax', 'Softmax operator', [=[\operatorname{softmax}\!\left(<1>\right)]=], { 'z' } },
    { 'attn', 'Scaled dot-product attention (unmasked)', [=[\operatorname{softmax}\!\left(\frac{<1> <2>^{\mathsf{T}}}{\sqrt{<3>}}\right)<4>]=], { 'Q', 'K', 'd_k', 'V' } },
    { 'streamwin', 'Last w items of a stream', [=[\left(<1>_{<2>-<3>+1},\ldots,<1>_{<2>}\right)]=], { 'x', 't', 'w' } },
    { 'markov', 'Markov (X nonnegative; a positive)', [=[\Pr\left[<1>\geq <2>\right]\leq\frac{\mathbb{E}[<1>]}{<2>}]=], { 'X', 'a' } },
    { 'cheby', 'Chebyshev (finite variance; a positive)', [=[\Pr\left[\left|<1>-\mathbb{E}[<1>]\right|\geq <2>\right]\leq\frac{\operatorname{Var}[<1>]}{<2>^2}]=], { 'X', 'a' } },
    { 'chernoff', 'Chernoff upper tail (independent Bernoulli sum; 0 < delta <= 1)', [=[\Pr\left[<1>\geq(1+<2>)<3>\right]\leq\exp\!\left(-\frac{<2>^2<3>}{3}\right)]=], { 'X', [=[\delta]=], [=[\mu]=] } },
}

for _, definition in ipairs(automatic) do add(autosnippets, definition) end
for _, definition in ipairs(manual) do add(snippets, definition) end
return snippets, autosnippets
