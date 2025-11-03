vim.keymap.set("n", "<C-f>", "<cmd>silent !tmux neww tmux-sessionizer<CR>")

--run session commands while in neovim
--Neovim registers super as alt, but alt+[hjkl] are used by Harpoon.
--To avoid smearing harpoon keymaps, we could configure upstream to send
--different keycodes. I've instead decided to map these to [7890]
vim.keymap.set("n", "<M-7>", "<cmd>silent !tmux neww tmux-sessionizer -s 0<CR>")
vim.keymap.set("n", "<M-8>", "<cmd>silent !tmux neww tmux-sessionizer -s 1<CR>")
vim.keymap.set("n", "<M-9>", "<cmd>silent !tmux neww tmux-sessionizer -s 2<CR>")
vim.keymap.set("n", "<M-0>", "<cmd>silent !tmux neww tmux-sessionizer -s 3<CR>")
