require("nvim-treesitter-textobjects").setup {
    select = {
        lookahead = false,
        include_surrounding_whitespace = false,
    },
    move = {
        set_jumps = true,
    },
}

local select = require("nvim-treesitter-textobjects.select")

vim.keymap.set({ "x", "o" }, "af", function()
  select.select_textobject("@function.outer", "textobjects")
end)
vim.keymap.set({ "x", "o" }, "if", function()
  select.select_textobject("@function.inner", "textobjects")
end)
vim.keymap.set({ "x", "o" }, "am", function()
  select.select_textobject("@function.outer", "textobjects")
end)
vim.keymap.set({ "x", "o" }, "im", function()
  select.select_textobject("@function.inner", "textobjects")
end)
vim.keymap.set({ "x", "o" }, "ac", function()
  select.select_textobject("@class.outer", "textobjects")
end)
vim.keymap.set({ "x", "o" }, "ic", function()
  select.select_textobject("@class.inner", "textobjects")
end)

local move = require("nvim-treesitter-textobjects.move")

vim.keymap.set({ "n", "x", "o" }, "[f", function()
  move.goto_previous_start("@function.outer", "textobjects")
end)
vim.keymap.set({ "n", "x", "o" }, "]f", function()
  move.goto_next_start("@function.outer", "textobjects")
end)
vim.keymap.set({ "n", "x", "o" }, "[m", function()
  move.goto_previous_start("@function.outer", "textobjects")
end)
vim.keymap.set({ "n", "x", "o" }, "]m", function()
  move.goto_next_start("@function.outer", "textobjects")
end)
vim.keymap.set({ "n", "x", "o" }, "[c", function()
  move.goto_previous_start("@class.outer", "textobjects")
end)
vim.keymap.set({ "n", "x", "o" }, "]c", function()
  move.goto_next_start("@class.outer", "textobjects")
end)
