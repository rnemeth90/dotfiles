return {
  "lewis6991/gitsigns.nvim",
  event = { "BufReadPre", "BufNewFile" },
  opts = {
    signs = {
      add          = { text = '▎' },
      change       = { text = '▎' },
      delete       = { text = '▁' },
      topdelete    = { text = '▔' },
      changedelete = { text = '▎' },
      untracked    = { text = '▎' },
    },
    signs_staged = {
      add          = { text = '▎' },
      change       = { text = '▎' },
      delete       = { text = '▁' },
      topdelete    = { text = '▔' },
      changedelete = { text = '▎' },
    },
    current_line_blame = false,
    current_line_blame_opts = {
      delay = 500,
    },
  },
  keys = {
    -- Hunk navigation
    { "]h", function() require("gitsigns").nav_hunk("next") end, desc = "Next hunk" },
    { "[h", function() require("gitsigns").nav_hunk("prev") end, desc = "Prev hunk" },

    -- Stage / reset hunks
    { "<leader>ghs", function() require("gitsigns").stage_hunk() end,                          desc = "Stage hunk",        mode = { "n", "v" } },
    { "<leader>ghr", function() require("gitsigns").reset_hunk() end,                          desc = "Reset hunk",        mode = { "n", "v" } },
    { "<leader>ghS", function() require("gitsigns").stage_buffer() end,                        desc = "Stage file" },
    { "<leader>ghR", function() require("gitsigns").reset_buffer() end,                        desc = "Reset file" },
    { "<leader>ghu", function() require("gitsigns").undo_stage_hunk() end,                     desc = "Undo stage hunk" },

    -- Inspect
    { "<leader>ghp", function() require("gitsigns").preview_hunk() end,                        desc = "Preview hunk" },
    { "<leader>ghb", function() require("gitsigns").blame_line({ full = true }) end,           desc = "Blame line" },

    -- Text object: select hunk with ih in visual/operator mode
    { "ih", "<cmd>Gitsigns select_hunk<CR>", mode = { "o", "x" }, desc = "Select hunk" },
  },
}
