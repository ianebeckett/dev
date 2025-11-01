-- Only required if you have packer configured as `opt`
vim.cmd [[packadd packer.nvim]]

--installs plugins in ~/.local/share/nvim/
return require('packer').startup(function(use)
    use 'wbthomason/packer.nvim' -- Packer can manage itself
    use 'mbbill/undotree' -- todo: replace with builtin undotree?
    use 'lewis6991/gitsigns.nvim'

    use 'rose-pine/neovim'

    -- --todo: fix use of deprecated functions here:
    -- --:checkhealth vim.deprecated
    -- use {
    --     "windwp/nvim-autopairs",
    --     event = "InsertEnter",
    --     -- can I move this func to autopairs.lua?
    --     config = function()
    --         require("nvim-autopairs").setup {}
    --     end
    -- }
    --

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
