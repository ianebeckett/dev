local trouble = require('trouble')
local opts = { skip_groups = true, jump = true }
trouble.setup({
    config = {
        icons = false,
    },
    vim.keymap.set("n", "<leader>tt", function() trouble.toggle('diagnostics') end),
    vim.keymap.set("n", "tn", function() trouble.next(opts); end),
    vim.keymap.set("n", "tp", function() trouble.previous(opts); end),
})
