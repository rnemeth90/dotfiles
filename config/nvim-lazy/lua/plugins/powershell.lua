return {
  "TheLeoP/powershell.nvim",
  -- NOT lazy-loaded on `ft = "ps1"`: powershell.nvim's own plugin/autocmds.lua
  -- registers a FileType(ps1) autocmd that auto-starts the LSP client. If this
  -- plugin were ft-lazy-loaded, that autostart autocmd would fire (as part of
  -- lazy sourcing the plugin's plugin/ dir) *during the same FileType event*
  -- that triggers the load - racing ahead of `require("powershell").setup(opts)`
  -- below and starting the client with empty settings (no OTBS/K&R formatting).
  -- Loading eagerly at startup guarantees setup() runs before any ps1 buffer
  -- opens.
  lazy = false,
  dependencies = { "mfussenegger/nvim-dap" },
  opts = {
    -- PowerShell Editor Services installed by mason-tool-installer
    -- (see lsp/mason.lua "powershell-editor-services" entry).
    bundle_path = vim.fn.stdpath("data") .. "/mason/packages/powershell-editor-services",
    capabilities = require("helpers.handlers").capabilities,
    settings = {
      powershell = {
        codeFormatting = {
          preset = "OTBS",
          indentationSize = 2,
          addWhitespaceAroundPipe = true,
          trimWhitespaceAroundPipe = true,
          useCorrectCasing = true,
        },
        scriptAnalysis = {
          enable = true,
        },
      },
    },
  },
  config = function(_, opts)
    require("powershell").setup(opts)

    -- powershell.nvim's own plugin/autocmds.lua registers a FileType(ps1)
    -- autocmd (augroup "powershell.nvim-filetype") that auto-starts the LSP
    -- client. In practice that autocmd can fire and call initialize_or_attach
    -- (which snapshots the settings table at that moment) before this setup()
    -- call above has finished applying our codeFormatting/OTBS settings,
    -- causing the client to start with empty settings (formatter falls back
    -- to Allman-style braces instead of K&R/OTBS). Clearing that augroup and
    -- re-registering our own FileType autocmd guarantees initialize_or_attach
    -- is only ever called after setup() has completed.
    vim.api.nvim_create_augroup("powershell.nvim-filetype", { clear = true })
    vim.api.nvim_create_autocmd("FileType", {
      pattern = "ps1",
      callback = function(args) require("powershell").initialize_or_attach(args.buf) end,
      desc = "Checks whether powershell_es should start a new instance or attach to an existing one.",
    })

    -- powershell.nvim manages its own "powershell_es" client outside of
    -- mason-lspconfig, so wire up the same on_attach behavior (keymaps,
    -- illuminate) that other LSP servers get via lsp/mason.lua.
    vim.api.nvim_create_autocmd("LspAttach", {
      callback = function(args)
        local client = vim.lsp.get_client_by_id(args.data.client_id)
        if client and client.name == "powershell_es" then
          require("helpers.handlers").on_attach(client, args.buf)
        end
      end,
    })

    -- Toggle PowerShell Extension Terminal / Debug Terminal, scoped to ps1 buffers.
    vim.api.nvim_create_autocmd("FileType", {
      pattern = "ps1",
      callback = function(args)
        vim.keymap.set("n", "<leader>lt", function()
          require("powershell").toggle_term()
        end, { buffer = args.buf, desc = "PowerShell: Toggle terminal" })
        vim.keymap.set("n", "<leader>ld", function()
          require("powershell").toggle_debug_term()
        end, { buffer = args.buf, desc = "PowerShell: Toggle debug terminal" })
      end,
    })
  end,
}
