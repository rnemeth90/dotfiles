-- using mason-lspconfig, so lsp server names are 'easier'
local servers = {
	"sumneko_lua",
  "lua_ls",
	"cssls",
	"html",
  --"golines",
	"gopls",
  "tsserver",
	"pyright",
	"bashls",
	"jsonls",
  "yamlls",
  "omnisharp",
  "dockerls",
  "bicep",
  "awk_ls",
  -- "csharp_ls",
  "golangci_lint_ls",
  "powershell_es",
  "tsserver"
  --"terraform-ls",
}

local settings = {
	ui = {
		border = "none",
    icons = {
        package_installed = "✓",
        package_pending = "➜",
        package_uninstalled = "✗"
    },
	},
	log_level = vim.log.levels.INFO,
	max_concurrent_installers = 4,
}

require("mason").setup(settings)
require("mason-lspconfig").setup({
	ensure_installed = servers, -- ensure servers are installed
	automatic_installation = true, -- auto install
})

local lspconfig_status_ok, lspconfig = pcall(require, "lspconfig")
if not lspconfig_status_ok then
	return
end

local opts = {}

for _, server in pairs(servers) do
	opts = {
		on_attach = require("user.lsp.handlers").on_attach,
		capabilities = require("user.lsp.handlers").capabilities,
	}

	server = vim.split(server, "@")[1]

  -- import all handler files in ./settings
	local require_ok, conf_opts = pcall(require, "user.lsp.settings." .. server)
	if require_ok then
		opts = vim.tbl_deep_extend("force", conf_opts, opts)
	end

	lspconfig[server].setup(opts)
end
