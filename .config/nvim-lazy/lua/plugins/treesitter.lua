-- Highlight, edit, and navigate code
return {
	{
		"nvim-treesitter/nvim-treesitter",
		build = function()
			pcall(require("nvim-treesitter.install").update({ with_sync = true }))
		end,
    event = { "BufReadPost", "BufNewFile" },
		dependencies = {
			"nvim-treesitter/nvim-treesitter-textobjects",
		},
		config = function()
			require("nvim-treesitter.configs").setup({

      -- Add languages to be installed here that you want installed for treesitter
      ensure_installed = {
        "awk",
        "bash",
        "c",
        "c_sharp",
        "go",
        "javascript",
        "hcl",
        "json",
        "lua",
        "python",
        "typescript",
        "tsx",
        "css",
        "rust",
        "java",
        "yaml",
        "markdown",
        "markdown_inline",
        "powershell",
      },
      ignore_install = { "phpdoc" },
      highlight = {
        enable = true,
        additional_vim_regex_highlighting = { "markdown", "yaml" },
      },
      autopairs = {
        enable = true,
      },
      auto_install = true,
      sync_install = false,
      -- indent = { enable = true },
      incremental_selection = {
        enable = true,
        keymaps = {
          init_selection = "gnn",
          node_incremental = "grn",
          scope_incremental = "grc",
          node_decremental = "grm",
        },
      },
      -- rainbow = {
      --   enable = true,
      --   extended_mode = true,
      --   max_file_lines = 1000,
      -- },
      textobjects = {
        select = {
          enable = true,
          lookahead = true,
          keymaps = {
            ["af"] = "@function.outer",
            ["if"] = "@function.inner",
            ["ac"] = "@class.outer",
            ["ic"] = "@class.inner",
          },
        },
        move = {
          enable = true,
          set_jumps = true,
          goto_next_start = {
            ["]f"] = "@function.outer",
            ["]c"] = "@class.outer",
          },
          goto_previous_start = {
            ["[f"] = "@function.outer",
            ["[c"] = "@class.outer",
          },
        },
      },
		})
		end,
	},
}
