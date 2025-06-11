return {
  {
    "williamboman/mason.nvim",
    build = ":MasonUpdate",
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
        "pyright",
        "bashls",
        "jsonls",
        "yamlls",
        "omnisharp",
        "dockerls",
        "bicep",
        "awk_ls",
        "powershell_es",
      }

      require("mason-lspconfig").setup({
        ensure_installed = servers,
        automatic_installation = true,
      })

      local lspconfig = require("lspconfig")
      local handlers = require("helpers.handlers")

      for _, server in ipairs(servers) do
        local opts = {
          on_attach = handlers.on_attach,
          capabilities = handlers.capabilities,
        }

        -- load config for lsps from settings directory
        local has_custom_opts, server_opts = pcall(require, "lsp.settings." .. server)
        if has_custom_opts then
          opts = vim.tbl_deep_extend("force", opts, server_opts)
        end

        lspconfig[server].setup(opts)
      end
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
          { "golangci-lint", version = "v1.47.0" },
          { "bash-language-server", auto_update = true },
          "black",
          "debugpy",
          "flake8",
          "isort",
          "mypy",
          "pylint",
          "vim-language-server",
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
