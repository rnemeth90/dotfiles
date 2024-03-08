require("mason-null-ls").setup({
	ensure_installed = {
	-- "stylua"
	--	"jq"
  --  "goimports",
  --  "black",
   "clang-format"
  --  "gofumpt",
  --  "golines",
  --  "markdownlint",
  --  "prettier",
  --  "sql-formatter",
  --  "xmlformatter",
  --  "spell",
  --  "yamlfmt"
	},
	automatic_installation = true,
	handlers = {},
})
