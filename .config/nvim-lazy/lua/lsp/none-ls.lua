return {
  "nvimtools/none-ls.nvim",
  dependencies = { "nvimtools/none-ls-extras.nvim" },
  event = { "BufReadPre", "BufNewFile" }, -- lazy load for performance
  config = function()
    local none_ls_status_ok, none_ls = pcall(require, "null-ls") -- none-ls still uses the old name in the codebase for backwards compatibility
    if not none_ls_status_ok then
      return
    end

    local formatting = none_ls.builtins.formatting
    local completions = none_ls.builtins.completion

    local augroup = vim.api.nvim_create_augroup("LspFormatting", {})

    local sources = {
      formatting.prettier.with({
        filetypes = { "javascript", "typescript", "css", "html", "scss", "json", "yaml", "markdown" },
        extra_args = { "--no-semi", "--single-quote", "--jsx-single-quote" },
      }),
      formatting.black.with({
        filetypes = { "python" },
        extra_args = { "--fast" },
      }),
      formatting.stylua.with({
        filetypes = { "lua" },
      }),
      formatting.gofmt.with({
        filetypes = { "go" },
      }),
      require("none-ls.diagnostics.flake8").with({
        extra_args = { "--max-line-length=88" },
      }),
      require("none-ls.diagnostics.eslint").with({
        condition = function(utils)
          return utils.root_has_file({
            ".eslintrc",
            ".eslintrc.js",
            ".eslintrc.cjs",
            ".eslintrc.json",
            ".eslintrc.yaml",
            ".eslintrc.yml",
            "eslint.config.js",
            "eslint.config.mjs",
            "eslint.config.cjs",
          })
        end,
      }),
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
                  return format_client.name == "none-ls"
                end,
              })
            end,
          })
        end
      end,
    })
  end,
}

