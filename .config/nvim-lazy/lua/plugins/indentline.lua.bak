return {
  "lukas-reineke/indent-blankline.nvim",
  main = "ibl",
  event = { "BufReadPre", "BufNewFile" },
  opts = {
    indent = {
      char = "│",
      tab_char = "│",
    },
    scope = {
      enabled = true,
      show_start = true,
      show_end = false,
      highlight = { "Function", "Label" },
    },
    exclude = {
      filetypes = {
        "help",
        "terminal",
        "dashboard",
        "lazy",
        "lspinfo",
        "packer",
        "NvimTree",
        "neo-tree",
        "Trouble",
      },
      buftypes = {
        "terminal",
        "nofile",
      },
    },
  },
}

