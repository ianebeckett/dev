vim.bo.makeprg = "lualatex"

--remove conflicts with treesitter textobjects
vim.keymap.del({ "n", "x", "o" }, "[m")
vim.keymap.del({ "n", "x", "o" }, "]m")
