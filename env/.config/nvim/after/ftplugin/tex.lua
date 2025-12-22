--let vimtex replace treesitter textobjects with vimtex ones when editing .tex files
vim.keymap.del({ "x", "o" }, "am")
vim.keymap.del({ "x", "o" }, "im")
vim.keymap.del({ "x", "o" }, "ac")
vim.keymap.del({ "x", "o" }, "ic")
vim.keymap.del({ "n", "x", "o" }, "[m")
vim.keymap.del({ "n", "x", "o" }, "]m")
