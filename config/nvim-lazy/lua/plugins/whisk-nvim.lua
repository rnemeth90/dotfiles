return {
  "josstei/whisk.nvim",
  event = "VeryLazy",
  init = function() vim.g.whisk_auto_setup = 0 end,
  opts = {
    -- cursor animation delays every j/k; keep scroll animation short
    cursor = { enabled = false, duration = 30 },
    scroll = { duration = 60 },
    keymaps = { cursor = false, scroll = true },
  },
}
