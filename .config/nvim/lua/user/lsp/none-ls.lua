-- none-ls wraps cli tools into a generalized lsp. Commonly used for linters, formatters, etc.
-- these directives still work with none-ls.nvim

local none_ls_status_ok, none_ls = pcall(require, "none-ls")
if not none_ls_status_ok then
  return
end

local augroup = vim.api.nvim_create_augroup("LspFormatting", {})

-- Built-in none-ls sources
local formatting = none_ls.builtins.formatting
local diagnostics = none_ls.builtins.diagnostics
local completions = none_ls.builtins.completion

local sources = {
  -- Formatting
  formatting.prettier.with({
    filetypes = { "c", "js", "ts", "javascript", "typescript", "css", "html", "scss", "json", "yaml", "markdown", "md" },
    extra_args = { "--no-semi", "--single-quote", "--jsx-single-quote" },
  }),
  formatting.black.with({
    filetypes = { "py", "python"},
    extra_args = { "--fast" },
  }),
  formatting.stylua.with({
    filetypes = { "lua" },
  }),
  formatting.gofmt.with({
    filetypes = { "go" },
  }),
  -- Diagnostics
  diagnostics.flake8.with({
    extra_args = { "--max-line-length=88" },
  }),
  diagnostics.eslint.with({
    condition = function(utils)
      return utils.root_has_file(".eslintrc.js")
    end,
  }),

  -- Completion
  completions.spell,
}

none_ls.setup({
  debug = false,
  sources = sources,
  on_attach = function(client, bufnr)
    if client.supports_method("textDocument/formatting") then
      vim.api.nvim_clear_autocmds({ group = augroup, buffer = bufnr })
      vim.api.nvim_create_autocmd("BufWritePre", {
        group = augroup,
        buffer = bufnr,
        callback = function()
          vim.lsp.buf.format({
            async = false,
            bufnr = bufnr,
            filter = function(format_client)
              return format_client.name == "none-ls" -- Use only none-ls for formatting
            end,
          })
        end,
      })
    end
  end,
})
