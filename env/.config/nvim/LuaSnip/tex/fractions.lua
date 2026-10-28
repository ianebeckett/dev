local ls = require('luasnip')
local s, sn, d, i = ls.snippet, ls.snippet_node, ls.dynamic_node, ls.insert_node
local fmta = require('luasnip.extras.fmt').fmta
local events = require('luasnip.util.events')
local context = require('tex_context')

return {}, {
    s({ trig = '//', name = 'Slash fraction', wordTrig = false,
        trigEngine = function() return require('tex_fraction').match end,
        condition = context.math,
        -- This snippet needs text immediately before the cursor. ff remains
        -- the completion-menu entry for a fraction without a captured operand.
        show_condition = function() return false end }, {
        d(1, function(_, parent)
            local numerator = parent.captures and parent.captures[1] or ''
            local first_entry = true
            return sn(nil, fmta('\\frac{<>}{<>}', { i(1, numerator), i(2) }), {
                callbacks = {
                    [1] = {
                        [events.enter] = function(node)
                            if not first_entry or numerator == '' then return end
                            first_entry = false
                            local buf = vim.api.nvim_get_current_buf()
                            -- Enter the denominator initially; keep the numerator
                            -- in the normal jump order for subsequent CTRL-J edits.
                            vim.schedule(function()
                                if vim.api.nvim_get_current_buf() == buf
                                    and ls.session.current_nodes[buf] == node then
                                    ls.jump(1)
                                end
                            end)
                        end,
                    },
                },
            })
        end, {}),
        i(0),
    }),
}
