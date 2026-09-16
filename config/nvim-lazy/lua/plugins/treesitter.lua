-- Highlight, edit, and navigate code
--
-- nvim-treesitter's `main` branch is a full, incompatible rewrite of the
-- old `master` branch: there is no more `nvim-treesitter.configs` module,
-- highlighting/indent are enabled via core `vim.treesitter` APIs instead of
-- a monolithic `setup()` table, and the plugin explicitly does not support
-- lazy-loading. See https://github.com/nvim-treesitter/nvim-treesitter
-- (main branch README) for details.
local ensure_installed = {
  "awk",
  "bash",
  "c",
  "c_sharp",
  "go",
  "javascript",
  "hcl",
  "terraform",
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
  "vim",
  "vimdoc",
  "helm",
}

return {
	{
		"nvim-treesitter/nvim-treesitter",
		branch = "main",
		lazy = false,
		build = ":TSUpdate",
		config = function()
			require("nvim-treesitter").setup()
			require("nvim-treesitter").install(ensure_installed)

			-- Enable treesitter highlighting, folding and indentation for any
			-- buffer whose filetype has an installed parser.
			vim.api.nvim_create_autocmd("FileType", {
				pattern = "*",
				callback = function(args)
					local ok = pcall(vim.treesitter.start, args.buf)
					if not ok then
						return
					end
					vim.wo[0][0].foldexpr = "v:lua.vim.treesitter.foldexpr()"
					vim.wo[0][0].foldmethod = "expr"
					vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
				end,
			})
		end,
	},
	{
		"nvim-treesitter/nvim-treesitter-textobjects",
		branch = "main",
		event = { "BufReadPost", "BufNewFile" },
		config = function()
			require("nvim-treesitter-textobjects").setup({
				select = { lookahead = true },
				move = { set_jumps = true },
			})

			local select = require("nvim-treesitter-textobjects.select")
			vim.keymap.set({ "x", "o" }, "af", function()
				select.select_textobject("@function.outer", "textobjects")
			end)
			vim.keymap.set({ "x", "o" }, "if", function()
				select.select_textobject("@function.inner", "textobjects")
			end)
			vim.keymap.set({ "x", "o" }, "ac", function()
				select.select_textobject("@class.outer", "textobjects")
			end)
			vim.keymap.set({ "x", "o" }, "ic", function()
				select.select_textobject("@class.inner", "textobjects")
			end)

			local move = require("nvim-treesitter-textobjects.move")
			vim.keymap.set({ "n", "x", "o" }, "]f", function()
				move.goto_next_start("@function.outer", "textobjects")
			end)
			vim.keymap.set({ "n", "x", "o" }, "]c", function()
				move.goto_next_start("@class.outer", "textobjects")
			end)
			vim.keymap.set({ "n", "x", "o" }, "[f", function()
				move.goto_previous_start("@function.outer", "textobjects")
			end)
			vim.keymap.set({ "n", "x", "o" }, "[c", function()
				move.goto_previous_start("@class.outer", "textobjects")
			end)
		end,
	},
}
