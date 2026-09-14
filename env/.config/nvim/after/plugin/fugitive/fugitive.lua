-- Using Vim: Vim + Git - Fugitive
-- <leader>gs: Git Status
-- Use s to stage and u to unstage.
-- :Gcommit: Commits stuff
-- :Gpush: Pushes stuff
-- :Git merge <branchname>: Merge
-- Use dv on the file you want to resolve if you have merge conflicts.
-- The window on the left should be the current branch, the window on the right should be the one you just merged from, and the middle window is the resulting merge.
-- Ctrl-w and ctrl-O: save and close

vim.keymap.set("n", "<leader>gs", vim.cmd.Git)

local FugitiveGroup = vim.api.nvim_create_augroup("FugitiveGroup", {})
local autocmd = vim.api.nvim_create_autocmd

-- Diff conflict resolution mappings (only active in diff mode)
autocmd("BufEnter", {
    group = FugitiveGroup,
    pattern = "*",
    callback = function()
        if vim.wo.diff then
            local opts = { buffer = 0, remap = false }
            -- Grab from the window on the left
            vim.keymap.set("n", "gf", "<cmd>diffget //2 | diffupdate<CR>", opts)
            -- Grab from the window on the right
            vim.keymap.set("n", "gj", "<cmd>diffget //3 | diffupdate<CR>", opts)
        end
    end,
})

autocmd("BufWinEnter", {
    group = FugitiveGroup,
    pattern = "*",
    callback = function()
        if vim.bo.ft ~= "fugitive" then
            return
        end

        local bufnr = vim.api.nvim_get_current_buf()
        local opts = {buffer = bufnr, remap = false}
        vim.keymap.set("n", "<leader>p", function()
            vim.cmd.Git('push')
        end, opts)

        -- rebase always
        vim.keymap.set("n", "<leader>P", function()
            vim.cmd.Git({'pull',  '--rebase'})
        end, opts)

        -- Push up and track branch
        vim.keymap.set("n", "<leader>t", ":Git push -u origin ", opts)
    end,
})
