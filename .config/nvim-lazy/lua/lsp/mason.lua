return {
  {
    "williamboman/mason.nvim",
    config = function()
      require("mason").setup({
        ui = {
          border = "none",
          icons = {
            package_installed = "✓",
            package_pending = "➜",
            package_uninstalled = "✗",
          },
        },
        log_level = vim.log.levels.INFO,
        max_concurrent_installers = 4,
      })
    end,
  },

  {
    "williamboman/mason-lspconfig.nvim",
    dependencies = {
      "williamboman/mason.nvim",
      "neovim/nvim-lspconfig",
    },
    config = function()
      local servers = {
        "lua_ls",
        "cssls",
        "html",
        "clangd",
        "gopls",
        "basedpyright",
        "bashls",
        "jsonls",
        "yamlls",
        "omnisharp",
        "dockerls",
        "powershell_es",
        "ansiblels",
        "azure_pipelines_ls",
        "docker_compose_language_service",
        "helm_ls",
        "jqls",
        "nginx_language_server",
        "terraformls",
        "ts_ls",
        "vimls",
      }

      require("mason-lspconfig").setup({
        ensure_installed = servers,
        automatic_installation = true,
      })

      local handlers = require("helpers.handlers")

      handlers.setup()

      for _, server in ipairs(servers) do
        local opts = {
          on_attach = handlers.on_attach,
          capabilities = handlers.capabilities,
          -- Fallback root_dir so rootUri is never sent as null.
          -- Node.js servers (ts_ls, jsonls, yamlls, html, cssls, etc.) crash
          -- when rootUri is null because they call String(null) -> "null" and
          -- then try to parse it as a URI.  If no workspace marker is found,
          -- use the file's own directory so the URI is always valid.
          root_dir = function(bufnr)
            local fname = vim.api.nvim_buf_get_name(bufnr)
            if fname == "" then return nil end
            return vim.fs.root(bufnr, { ".git", "package.json", "go.mod", "Cargo.toml", "Makefile" })
              or vim.fn.fnamemodify(fname, ":h")
          end,
        }

        local has_custom_opts, server_opts = pcall(require, "lsp.settings." .. server)
        if has_custom_opts then
          -- server_opts takes precedence, so a custom root_dir there wins
          opts = vim.tbl_deep_extend("force", opts, server_opts)
        end

        vim.lsp.config(server, opts)
      end

      vim.lsp.enable(servers)
    end,
  },

  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    dependencies = {
      "williamboman/mason.nvim",
    },
    cmd = { "Mason", "MasonInstall", "MasonToolsUpdate" },
    config = function()
      require("mason-tool-installer").setup({
        ensure_installed = {
          "golangci-lint",
          { "bash-language-server", auto_update = true },
          "copilot-language-server",
          "black",
          "debugpy",
          "flake8",
          "autoflake",
          "autopep8",
          "asmfmt",
          "isort",
          "mypy",
          "pylint",
          "gopls",
          "stylua",
          "shellcheck",
          "editorconfig-checker",
          "gofumpt",
          "prettier",
          "golines",
          "gomodifytags",
          "gotests",
          "impl",
          "json-to-struct",
          "misspell",
          "revive",
          "shfmt",
          "staticcheck",
          "vint",
          "ansible-lint",
          "beautysh",
          "csharpier",
          "delve",
          "fixjson",
          "gitui",
          "glow",
          "goimports",
          "gospel",
          "jq",
          "htmlbeautifier",
          "luaformatter",
          "markdownlint",
          "terraform",
          "trivy",
          "yamlfix",
          "yamlfmt",
          "yamllint",
        },
        auto_update = true,
        run_on_start = true,
        start_delay = 3000,
        debounce_hours = 5,
        integrations = {
          ["mason-lspconfig"] = true,
          ["mason-null-ls"] = true,
          ["mason-nvim-dap"] = true,
        },
      })
    end,
  },
}
