-- Lazy.nvim configuration

-- Ensure lazy.nvim is installed
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- Configure lazy.nvim
require("lazy").setup({
  -- Core plugins
  { "wbthomason/packer.nvim" }, -- For packer migration or legacy needs
  { "nvim-lua/plenary.nvim" },
  { "windwp/nvim-autopairs" },
  { "numToStr/Comment.nvim" },
  { "JoosepAlviste/nvim-ts-context-commentstring" },
  { "kyazdani42/nvim-web-devicons" },
  { "kyazdani42/nvim-tree.lua" },
  { "akinsho/bufferline.nvim" },
  { "moll/vim-bbye" },
  { "nvim-lualine/lualine.nvim" },
  { "lukas-reineke/indent-blankline.nvim", version = "v2.*" },
  { "goolord/alpha-nvim" },
  { "folke/which-key.nvim" },

  -- Debugger
  { "mfussenegger/nvim-dap" },
  { "theHamsta/nvim-dap-virtual-text" },
  { "rcarriga/nvim-dap-ui" },

  -- Colorschemes
  { "folke/tokyonight.nvim" },
  { "lunarvim/darkplus.nvim" },
  { "lunarvim/colorschemes" },
  { "catppuccin/nvim", name = "catppuccin" },

  -- Completions
  { "hrsh7th/nvim-cmp" },
  { "hrsh7th/cmp-buffer" },
  { "hrsh7th/cmp-path" },
  { "hrsh7th/cmp-nvim-lsp" },
  { "hrsh7th/cmp-nvim-lua" },
  { "saadparwaiz1/cmp_luasnip" },

  -- Snippets
  {
    "L3MON4D3/LuaSnip",
    build = "make install_jsregexp",
    dependencies = { "rafamadriz/friendly-snippets" },
  },
  { "rafamadriz/friendly-snippets" },

  -- LSP
  { "neovim/nvim-lspconfig" },
  { "williamboman/mason.nvim" },
  { "williamboman/mason-lspconfig.nvim" },
  { "WhoIsSethDaniel/mason-tool-installer.nvim" },
  { "nvimtools/none-ls.nvim" },

  -- { "RRethy/vim-illuminate" },

  -- Telescope
  { "nvim-telescope/telescope.nvim" },
  { "nvim-lua/popup.nvim" },
  { "nvim-telescope/telescope-media-files.nvim" },
  { "nvim-telescope/telescope-file-browser.nvim" },

  -- Treesitter
  { "nvim-treesitter/nvim-treesitter", build = ":TSUpdate" },
  { "nvim-treesitter/nvim-treesitter-textobjects" },

  -- Git
  { "lewis6991/gitsigns.nvim" },

  -- Go
  { "ray-x/go.nvim" },
  { "ray-x/guihua.lua" },

  -- Markdown preview
  {
    "iamcco/markdown-preview.nvim",
    build = "cd app && yarn install",
    ft = { "markdown" },
    config = function()
      vim.g.mkdp_filetypes = { "markdown" }
    end,
  },

  -- Scrolling
  { "karb94/neoscroll.nvim" },

  -- OpenAI integrations
  { "MunifTanjim/nui.nvim" },
  { "Bryley/neoai.nvim" },

  -- Copilot
  { "github/copilot.vim" },

  -- Helm
  { "towolf/vim-helm" },

  -- Handlebars
  { "mustache/vim-mustache-handlebars" },

  -- Terraform
  { "hashivim/vim-terraform" },
}, {
  ui = {
    border = "rounded", -- Optional UI tweaks
  },
})
