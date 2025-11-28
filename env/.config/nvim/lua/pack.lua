-- check status
-- lua vim.print(vim.pack.get())
-- delete a package by name
-- lua vim.pack.del({<name>})
-- it will reinstall unless it's been removed from vim.pack.add()
vim.pack.add({
    --colorschemes
    'https://github.com/rose-pine/neovim.git',
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
    'https://github.com/saghen/blink.cmp.git',
    {
        src = 'https://github.com/L3MON4D3/LuaSnip.git',
        version = 'v2.*',
    },
    'https://github.com/rafamadriz/friendly-snippets',
})
