return {
  "mfussenegger/nvim-dap",
  ft = { "go", "cs", "ps1" },
  dependencies = {
    {
      "leoluz/nvim-dap-go",
      config = function()
        require("dap-go").setup()
      end,
    },
    {
      "rcarriga/nvim-dap-ui",
      dependencies = { "nvim-neotest/nvim-nio" },
      config = function()
        require("dapui").setup()
      end,
    },
  },
  config = function()
    local dap = require("dap")
    local dapui = require("dapui")

    -- Automatically open/close the DAP UI alongside debug sessions
    dap.listeners.after.event_initialized["dapui_config"] = function()
      dapui.open()
    end
    dap.listeners.before.event_terminated["dapui_config"] = function()
      dapui.close()
    end
    dap.listeners.before.event_exited["dapui_config"] = function()
      dapui.close()
    end

    -- Buffer-local DAP keymaps, scoped to the filetypes this plugin
    -- lazy-loads for. Keeping these global would let <F5>/<leader>d*
    -- fire in unrelated buffers (e.g. Snacks picker windows), triggering
    -- "No configuration found for <filetype>" errors.
    vim.api.nvim_create_autocmd("FileType", {
      pattern = { "go", "cs", "ps1" },
      callback = function(args)
        local opts = { buffer = args.buf, silent = true, noremap = true }
        local function map(mode, lhs, rhs, desc)
          vim.keymap.set(mode, lhs, rhs, vim.tbl_extend("force", opts, { desc = desc }))
        end

        map("n", "<F5>", dap.continue, "Debug: Continue")
        map("n", "<F10>", dap.step_over, "Debug: Step over")
        map("n", "<F11>", dap.step_into, "Debug: Step into")
        map("n", "<F12>", dap.step_out, "Debug: Step out")
        map("n", "<leader>db", dap.toggle_breakpoint, "Debug: Toggle breakpoint")
        map("n", "<leader>dB", function()
          dap.set_breakpoint(vim.fn.input("Breakpoint condition: "))
        end, "Debug: Conditional breakpoint")
        map("n", "<leader>dr", dap.repl.toggle, "Debug: Toggle REPL")
        map("n", "<leader>dR", dap.run_last, "Debug: Run last")
        map("n", "<leader>dt", dap.terminate, "Debug: Terminate")
        map("n", "<leader>du", dapui.toggle, "Debug: Toggle UI")

        if args.match == "go" then
          map("n", "<leader>dgt", function()
            require("dap-go").debug_test()
          end, "Debug: Go test (nearest)")
        end
      end,
    })

    -- dap-go's setup() (in the dependency above) already registers a
    -- working dap.adapters.go using dlv. Defining our own here previously
    -- overwrote it with a broken vim.loop.spawn version (no stdio wiring),
    -- causing Delve to exit immediately on launch.
    dap.configurations.go = {
      {
        type = "go",
        name = "Debug (current file, must be package main)",
        request = "launch",
        program = "${file}",
      },
      {
        type = "go",
        name = "Debug Package (current file's directory, must be package main)",
        request = "launch",
        program = "${fileDirname}",
      },
      {
        -- Use this when editing a non-main file (e.g. a subpackage like
        -- cmd/root.go) but you want to debug the module's main package
        -- at the project root, found by walking up for the nearest go.mod.
        type = "go",
        name = "Debug Main Package (nearest go.mod dir)",
        request = "launch",
        program = function()
          local dir = vim.fs.dirname(vim.fs.find("go.mod", { upward = true, path = vim.fn.expand("%:p:h") })[1])
          return dir or vim.fn.getcwd()
        end,
      },
      {
        type = "go",
        name = "Attach",
        mode = "local",
        request = "attach",
        processId = require("dap.utils").pick_process,
      },
    }

    -- C# / .NET (netcoredbg)
    dap.adapters.coreclr = {
      type = "executable",
      command = vim.fn.stdpath("data") .. "/mason/bin/netcoredbg",
      args = { "--interpreter=vscode" },
    }

    dap.configurations.cs = {
      {
        type = "coreclr",
        name = "Launch",
        request = "launch",
        program = function()
          return vim.fn.input("Path to dll: ", vim.fn.getcwd() .. "/bin/Debug/", "file")
        end,
      },
      {
        type = "coreclr",
        name = "Attach",
        request = "attach",
        processId = require("dap.utils").pick_process,
      },
    }
  end,
}
