-- reload without quitting neovim with :restart
-- check status with :lua vim.print(vim.pack.get())
-- delete a package by name with :lua vim.pack.del(<name>)
-- it will reinstall unless it's been remobed from vim.pack.add()
vim.pack.add({
  'https://github.com/rose-pine/neovim.git',
  'https://github.com/EdenEast/nightfox.nvim.git',
  'https://github.com/lewis6991/gitsigns.nvim.git',
  'https://github.com/nvim-treesitter/nvim-treesitter.git',
  'https://github.com/nvim-lua/plenary.nvim.git',
  { --depends on plenary, ripgrep, fd
    src = 'https://github.com/nvim-telescope/telescope.nvim.git',
    version = 'release',
  },
  { --depends on plenary
    src = 'https://github.com/ThePrimeagen/harpoon',
    version = 'harpoon2',
  },
  'https://github.com/ThePrimeagen/vim-be-good.git',
  'https://github.com/folke/trouble.nvim.git',
  'https://github.com/saghen/blink.cmp.git',
})
