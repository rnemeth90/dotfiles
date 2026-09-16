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
        "ansiblels",
        "azure_pipelines_ls",
        "docker_compose_language_service",
        "helm_ls",
        "jqls",
        "terraformls",
        "ts_ls",
        "vimls",
      }

      require("mason-lspconfig").setup({
        ensure_installed = servers,
        automatic_installation = true,
        -- Disabled: mason-lspconfig's default `automatic_enable = true` will
        -- silently `vim.lsp.enable()` its own *built-in* default config for
        -- ANY mason-installed package it recognizes (e.g. it did this for
        -- "powershell_es" the moment "powershell-editor-services" was added
        -- to mason-tool-installer below), bypassing our custom settings and
        -- competing with powershell.nvim's own client of the same name. We
        -- explicitly `vim.lsp.enable(servers)` ourselves below instead.
        automatic_enable = false,
      })

      local handlers = require("helpers.handlers")

      handlers.setup()

      for _, server in ipairs(servers) do
        local opts = {
          on_attach = handlers.on_attach,
          capabilities = handlers.capabilities,
          -- Fallback root_dir so rootUri is never sent as null.
          -- vim.lsp.enable calls root_dir(bufnr, on_dir) — the function
          -- must invoke on_dir(path) to trigger server start.  Returning
          -- a value alone does nothing because the caller ignores it.
          root_dir = function(bufnr, on_dir)
            local fname = vim.api.nvim_buf_get_name(bufnr)
            if not fname or fname == "" then return end
            local root = vim.fs.root(fname, {
              ".git", "package.json", "go.mod", "Cargo.toml", "Makefile",
              "*.sln", "*.csproj", "*.tfvars", "main.tf",
            })
              or vim.fn.fnamemodify(fname, ":h")
            on_dir(root)
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
          { "powershell-editor-services", auto_update = true },
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
          "tflint",
          "netcoredbg",
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
