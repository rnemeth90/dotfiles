return {
  "mfussenegger/nvim-dap",
  ft = "go",
  dependencies = {
    {
      "leoluz/nvim-dap-go",
      config = function()
        require("dap-go").setup()
      end,
    },
  },
  config = function()
    local dap = require("dap")

    -- You don't have to manually configure dlv if you use `nvim-dap-go`,
    -- but here's how you could do it manually:
    dap.adapters.go = function(callback, config)
      local handle
      local pid_or_err
      local port = 38697
      handle, pid_or_err = vim.loop.spawn("dlv", {
        args = { "dap", "-l", "127.0.0.1:" .. port },
        detached = true,
      }, function(code)
        handle:close()
        print("Delve exited with exit code: " .. code)
      end)
      -- Wait 100ms for delve to start
      vim.defer_fn(function()
        callback({ type = "server", host = "127.0.0.1", port = port })
      end, 100)
    end

    dap.configurations.go = {
      {
        type = "go",
        name = "Debug",
        request = "launch",
        program = "${file}",
      },
      {
        type = "go",
        name = "Debug Package",
        request = "launch",
        program = "${fileDirname}",
      },
      {
        type = "go",
        name = "Attach",
        mode = "local",
        request = "attach",
        processId = require("dap.utils").pick_process,
      },
    }
  end,
}
