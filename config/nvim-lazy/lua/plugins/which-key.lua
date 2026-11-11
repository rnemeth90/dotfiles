return {
  "folke/which-key.nvim",
  event = "VeryLazy",
  init = function()
    vim.o.timeout = true
    vim.o.timeoutlen = 300
  end,
  opts = {
    -- Group labels: <leader><tool><action>
    spec = {
      { "<leader>a", group = "ai", mode = { "n", "v" } },
      { "<leader>b", group = "buffers" },
      { "<leader>d", group = "debug" },
      { "<leader>dg", group = "go" },
      { "<leader>f", group = "files" },
      { "<leader>g", group = "git", mode = { "n", "v" } },
      { "<leader>gh", group = "hunks", mode = { "n", "v" } },
      { "<leader>l", group = "lsp" },
      { "<leader>s", group = "search" },
      { "<leader>t", group = "terraform" },
      { "<leader>u", group = "ui" },
      { "<leader>w", group = "windows" },
      { "<leader>x", group = "diagnostics" },
    },
  },
}