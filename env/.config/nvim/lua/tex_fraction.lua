local M = {}

-- These commands separate terms; they must not become part of a numerator.
local boundaries = {}
for word in ([=[cdot times div pm mp leq geq neq ne le ge in notin subset subseteq
supset supseteq to gets leftarrow rightarrow Leftrightarrow iff implies mapsto
approx sim simeq equiv propto land lor cup cap setminus mid colon quad qquad
sum prod int lim min max sup inf]=]):gmatch('%a+') do
    boundaries[word] = true
end

local opening = { [')'] = '(', [']'] = '[', ['}'] = '{' }
local closing = { ['('] = ')', ['['] = ']', ['{'] = '}' }

local function escaped(text, position)
    local slashes = 0
    position = position - 1
    while text:sub(position, position) == '\\' and position > 0 do
        slashes = slashes + 1
        position = position - 1
    end
    return slashes % 2 == 1
end

local function group_start(text, finish)
    local stack = {}
    for position = finish, 1, -1 do
        local char = text:sub(position, position)
        if not escaped(text, position) then
            if opening[char] then
                stack[#stack + 1] = opening[char]
            elseif closing[char] then
                if stack[#stack] ~= char then return nil end
                stack[#stack] = nil
                if #stack == 0 then return position end
            end
        end
    end
end

-- Match only the current line. Whitespace and top-level operators delimit a
-- term; balanced groups can contain both. Return the text LuaSnip must replace
-- and a numerator capture. An empty capture means // with no prefilled value.
function M.match(line)
    if line:sub(-2) == '//' then return '//', { '' } end
    if line:sub(-1) ~= '/' then return nil end
    local text = line:sub(1, -2)
    local finish = #text
    local position, start = finish, finish + 1
    local needs_base = false
    while position > 0 do
        local char = text:sub(position, position)
        if opening[char] then
            if escaped(text, position) then return nil end
            local first = group_start(text, position)
            if not first then return nil end
            start, position = first, first - 1
            needs_base = false
        elseif char:match('%a') then
            local first = text:sub(1, position):find('%a+$')
            local word = text:sub(first, position)
            if first > 1 and text:sub(first - 1, first - 1) == '\\'
                and not escaped(text, first - 1) then
                if boundaries[word] then break end
                first = first - 1
            end
            start, position = first, first - 1
            needs_base = false
        elseif char:match('[%d.]') then
            local first = text:sub(1, position):find('[%d.]+$')
            if not text:sub(first, position):find('%d') then break end
            start, position = first, first - 1
            needs_base = false
        elseif char == '^' or char == '_' then
            if start > finish then return nil end
            start, position = position, position - 1
            needs_base = true
        elseif char:match('%s') and needs_base then
            -- Greek snippets terminate their command with a space. TeX still
            -- binds a following script to that base, e.g. \pi ^{2}.
            position = position - 1
        else
            break
        end
    end
    if needs_base or start > finish or text:sub(start, start):match('[_^]') then return nil end
    local numerator = text:sub(start)
    -- Strip only a complete outer pair, retaining nested parentheses and
    -- function calls such as f(x), as well as \left(...\right) wrappers.
    if numerator:sub(1, 1) == '(' and numerator:sub(-1) == ')'
        and group_start(numerator, #numerator) == 1 then
        numerator = numerator:sub(2, -2)
    end
    if numerator:match('^%s*$') then return nil end
    return line:sub(start), { numerator }
end

return M
