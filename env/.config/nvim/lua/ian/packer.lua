-- Only required if you have packer configured as `opt`
vim.cmd [[packadd packer.nvim]]

--installs plugins in ~/.local/share/nvim/
return require('packer').startup(function(use)
    use 'wbthomason/packer.nvim' -- Packer can manage itself
    use 'lewis6991/gitsigns.nvim'
    use 'rose-pine/neovim'

    use {
        'nvim-treesitter/nvim-treesitter',
        run = ':TSUpdate'
    }

    use {
        'nvim-telescope/telescope.nvim',
        tag = '0.1.5',
        requires = { { 'nvim-lua/plenary.nvim' } }
    }

    use {
        "ThePrimeagen/harpoon",
        branch = "harpoon2",
        requires = { { "nvim-lua/plenary.nvim" } }
    }

end)
