local M = {}

local function usable(line, trigger)
    if vim.bo.filetype ~= 'tex' or not vim.b.vimtex then return false end
    if vim.fn['vimtex#syntax#in_comment']() == 1 then return false end
    for _, group in ipairs(vim.fn['vimtex#syntax#stack']()) do
        if group:match('^texVerb') or group:match('^texZone') then return false end
    end
    -- Typing a literal command such as \sum must not produce \\sum.
    if line and trigger and line:sub(1, #line - #trigger):sub(-1) == '\\' then
        return false
    end
    return true
end

function M.math(line, trigger)
    return usable(line, trigger) and vim.fn['vimtex#syntax#in_mathzone']() == 1
end

function M.text(line, trigger)
    return usable(line, trigger) and vim.fn['vimtex#syntax#in_mathzone']() == 0
end

function M.text_line(line, trigger)
    return M.text(line, trigger) and line:sub(1, #line - #(trigger or '')):match('^%s*$') ~= nil
end

return M
