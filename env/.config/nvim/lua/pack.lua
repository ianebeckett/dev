-- check status
-- lua vim.print(vim.pack.get())
-- delete a package by name
-- lua vim.pack.del({<name>})
-- it will reinstall unless it's been removed from vim.pack.add()
vim.pack.add(
    {
        'https://github.com/rose-pine/neovim.git',
        'https://github.com/lewis6991/gitsigns.nvim.git',
        'https://github.com/nvim-treesitter/nvim-treesitter.git',
        {
            src = 'https://github.com/nvim-treesitter/nvim-treesitter-textobjects.git',
            version = 'main',
        },
        'https://github.com/nvim-lua/plenary.nvim.git',
        { --depends on plenary, ripgrep, fd
            src = 'https://github.com/nvim-telescope/telescope.nvim.git',
            version = vim.version.range('^0.2.0'),
        },
        { --depends on plenary
            src = 'https://github.com/ThePrimeagen/harpoon',
            version = 'harpoon2',
        },
        'https://github.com/saghen/blink.cmp.git',
        {
            src = 'https://github.com/L3MON4D3/LuaSnip.git',
            version = vim.version.range( '^2.4.1'),
        },
        'https://github.com/lervag/vimtex.git',
    },
    { confirm = false }
)
