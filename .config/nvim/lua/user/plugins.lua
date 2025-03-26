-- plugin git repos are downloaded to ~/.local/share/nvim/site/pack/packer/

local fn = vim.fn

-- Automatically install packer
local install_path = fn.stdpath("data") .. "/site/pack/packer/start/packer.nvim"
if fn.empty(fn.glob(install_path)) > 0 then
  PACKER_BOOTSTRAP = fn.system({
    "git",
    "clone",
    "--depth",
    "1",
    "https://github.com/wbthomason/packer.nvim",
    install_path,
  })
  print("Installing packer close and reopen Neovim...")
  vim.cmd([[packadd packer.nvim]])
end

-- Autocommand that reloads neovim whenever you save the plugins.lua file
vim.cmd([[
  augroup packer_user_config
    autocmd!
    autocmd BufWritePost plugins.lua source <afile> | PackerSync
  augroup end
]])

-- Use a protected call so we don't error out on first use
local status_ok, packer = pcall(require, "packer")
if not status_ok then
  return
end

-- Have packer use a popup window
packer.init({
  display = {
    open_fn = function()
      return require("packer.util").float({ border = "rounded" })
    end,
  },
})

-- Install your plugins here
return packer.startup(function(use)
  use({ "wbthomason/packer.nvim" })                                                    -- Have packer manage itself
  use({ "nvim-lua/plenary.nvim" }) -- Useful lua functions used by lots of plugins
  use({ "windwp/nvim-autopairs" }) -- Autopairs, integrates with both cmp and treesitter
  use({ "numToStr/Comment.nvim" })
  use({ "JoosepAlviste/nvim-ts-context-commentstring", commit = "4d3a68c41a53add8804f471fcc49bb398fe8de08" })
  -- use({ "kyazdani42/nvim-web-devicons", commit = "563f3635c2d8a7be7933b9e547f7c178ba0d4352" })
  use({ "kyazdani42/nvim-tree.lua", commit = "7282f7de8aedf861fe0162a559fc2b214383c51c" }) -- Tree navigation to replace netrw
  use({ "akinsho/bufferline.nvim" })
  use({ "moll/vim-bbye", commit = "25ef93ac5a87526111f43e5110675032dbcacf56" })
  use({ "nvim-lualine/lualine.nvim" })
  use { "lukas-reineke/indent-blankline.nvim", tag = "v2.*" }
  use({ "goolord/alpha-nvim" })
  use({ "folke/which-key.nvim" })

  -- Debugger
  use({ "mfussenegger/nvim-dap" })
  use({ "leoluz/nvim-dap-go" })
  use({ "theHamsta/nvim-dap-virtual-text" })
  use({ "rcarriga/nvim-dap-ui" })
  use({ "nvim-neotest/nvim-nio"})

  -- Colorschemes
  use({ "folke/tokyonight.nvim" })
  use({ "lunarvim/darkplus.nvim" })
  use({ "lunarvim/colorschemes" })
  use({ "catppuccin/nvim", as = "catppuccin" })

  -- Completions
  use({ "hrsh7th/nvim-cmp" })        -- The completion plugin
  use({ "hrsh7th/cmp-buffer" })      -- buffer completions
  use({ "hrsh7th/cmp-path" })        -- path completions
  use({ "hrsh7th/cmp-nvim-lsp" })    -- completions for lsp
  use({ "hrsh7th/cmp-nvim-lua" })    -- completions for lua
  use({ "saadparwaiz1/cmp_luasnip" }) -- snippet completions

  -- Snippets, required for cmp (completions)
  use({
    "L3MON4D3/LuaSnip",
    tag = "v2.*", -- Replace <CurrentMajor> by the latest released major (first number of latest release)
    run = "make install_jsregexp",
    dependencies = { "rafamadriz/friendly-snippets" },
  })
  use({ "rafamadriz/friendly-snippets" }) -- a bunch of snippets to use

  -- LSP
  use({ "neovim/nvim-lspconfig" })            -- enable LSP
  use({ "williamboman/mason.nvim" })          -- simple to use language server installer
  use({ "williamboman/mason-lspconfig.nvim" }) -- convert lsp names to mason names
  use({ "WhoIsSethDaniel/mason-tool-installer.nvim" })
  use({ "nvimtools/none-ls.nvim" })           -- for formatters and linters, replaces null-ls

  use({ "RRethy/vim-illuminate", commit = "a2e8476af3f3e993bb0d6477438aad3096512e42" })

  -- Telescope
  use({ "nvim-telescope/telescope.nvim" })
  use({ "nvim-lua/popup.nvim" })
  use({ "nvim-telescope/telescope-media-files.nvim" })
  use({
    "nvim-telescope/telescope-file-browser.nvim",
    requires = { "nvim-telescope/telescope.nvim", "nvim-lua/plenary.nvim" },
  })

  -- Treesitter
  use("nvim-treesitter/nvim-treesitter")
  use("nvim-treesitter/nvim-treesitter-textobjects")
  -- use("p00f/nvim-ts-rainbow")

  -- Git
  use({ "lewis6991/gitsigns.nvim" })

  -- Go
  use("ray-x/go.nvim")
  use("ray-x/guihua.lua") -- for floating window support

  -- Markdown preview
  use({
    "iamcco/markdown-preview.nvim",
    run = "cd app && yarn install",
    setup = function()
      vim.g.mkdp_filetypes = { "markdown" }
    end,
    ft = { "markdown" },
  })

  -- scrolling
  use("karb94/neoscroll.nvim")

  -- openai stuff
  -- Avante
  -- copilot
  use("MunifTanjim/nui.nvim")
  use("Bryley/neoai.nvim")
  use 'stevearc/dressing.nvim'
  use 'MeanderingProgrammer/render-markdown.nvim'
  use 'nvim-tree/nvim-web-devicons'
  use 'HakonHarnes/img-clip.nvim'
  -- use("github/copilot.vim")
  use( "zbirenbaum/copilot.lua" )

  -- Avante.nvim with build process
  use {
    'yetone/avante.nvim',
    branch = 'main',
    run = 'make',
    config = function()
      require('avante').setup()
    end
  }

  -- helm
  use("towolf/vim-helm")

  -- handlebars
  use("mustache/vim-mustache-handlebars")

  -- terraform
  use("hashivim/vim-terraform")

  -- Automatically set up your configuration after cloning packer.nvim
  -- Put this at the end after all plugins
  if PACKER_BOOTSTRAP then
    require("packer").sync()
  end
end)
