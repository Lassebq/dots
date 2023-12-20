local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

local ok, lazy = pcall(require, "lazy")
if not ok then
	return
end

require("lazy").setup({
    root = vim.fn.stdpath("data") .. "/lazy",
	{
        "folke/tokyonight.nvim",
        name = "tokyonight",
        lazy = false,
        priority = 1000,
        config = function()
            require("themes.tokyonight")
        end
    },
    {
        "Mofiqul/vscode.nvim",
        lazy = false,
        priority = 1000,
    },
	{
        "catppuccin/nvim",
        name = "catppuccin",
        lazy = false,
        priority = 1000,
        config = function()
            require("themes.catppuccin")
        end
    },
    {
        "rose-pine/neovim",
        lazy = false,
        priority = 1000,
    },
    {
        "gbprod/nord.nvim",
        lazy = false,
        priority = 1000,
        config = function()
            require("themes.nord")
        end
    },
    {
        "neanias/everforest-nvim",
        lazy = false,
        priority = 1000,
    },
    {
        "moll/vim-bbye",
    },
	{
		"neovim/nvim-lspconfig",
		dependencies = {
			-- LSP Stuff
			"williamboman/mason.nvim",
			"williamboman/mason-lspconfig.nvim",
			"jose-elias-alvarez/null-ls.nvim",
			"glepnir/lspsaga.nvim",

			-- Completions
			"hrsh7th/nvim-cmp",
			"hrsh7th/cmp-buffer",
			"hrsh7th/cmp-path",
			"saadparwaiz1/cmp_luasnip",
			"hrsh7th/cmp-nvim-lsp",
			"hrsh7th/cmp-nvim-lua",
			"lukas-reineke/cmp-under-comparator",
			"L3MON4D3/LuaSnip",
			"hrsh7th/cmp-vsnip",
			"rafamadriz/friendly-snippets",
			"hrsh7th/cmp-nvim-lsp-signature-help",
			"onsails/lspkind.nvim",
		},
		config = function()
			-- Lsp Configs
			require("plugins.configs.lsp")
			-- Completions
			require("plugins.configs.cmp")
		end,
	},
    {
        "ahmedkhalf/project.nvim",
        config = function()
            require("project_nvim").setup()
        end
    },
	{
		"akinsho/bufferline.nvim",
        lazy = true,
		dependencies = {
			"kyazdani42/nvim-web-devicons",
		},
		config = function()
			require("plugins.configs.ui.bufferline")
		end,
	},
	{
		"nvim-lualine/lualine.nvim",
		dependencies = {
			"kyazdani42/nvim-web-devicons",
		},
		config = function()
			require("plugins.configs.ui.lualine")
		end,
	},
	{
		"nvim-neo-tree/neo-tree.nvim",
		dependencies = {
			"nvim-lua/plenary.nvim",
			"MunifTanjim/nui.nvim",
		},
		config = function()
			require("plugins.configs.ui.neotree")
		end,
	},
    {
		"nvim-telescope/telescope.nvim",
		dependencies = {
			"nvim-lua/plenary.nvim",
            "nvim-telescope/telescope-project.nvim",
		},
		config = function()
			require("plugins.configs.telescope")
		end,
	},
	{ "nvim-telescope/telescope-ui-select.nvim" },
	{
        "goolord/alpha-nvim",
        config = function()
			require("plugins.configs.ui.alpha")
		end,
    },
    { "tombh/novim-mode" },
	{
		"petertriho/nvim-scrollbar",
		config = function()
			require("plugins.configs.ui.scrollbar")
		end,
	},
	{
		"norcalli/nvim-colorizer.lua",
		config = function()
			require 'colorizer'.setup {
                'css';
                'sh';
                'yaml';
                'conf';
                'lua';
                'javascript';
            }
		end,
	},
})
