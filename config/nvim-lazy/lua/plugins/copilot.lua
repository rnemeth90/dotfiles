return {
  "zbirenbaum/copilot.lua",
  cmd = "Copilot",
  event = "InsertEnter",
  dependencies = {
    "zbirenbaum/copilot-cmp",
    "copilotlsp-nvim/copilot-lsp",
  },
  config = function()
    require("copilot").setup({
      suggestion = { enabled = false },
      panel     = { enabled = false },
      nes       = { enabled = true },
      filetypes = {
        yaml      = false,
        markdown  = false,
        help      = false,
        gitcommit = false,
        gitrebase = false,
        hgcommit  = false,
        svn       = false,
        cvs       = false,
        ["."]     = false,
      },
    })
    require("copilot_cmp").setup()
  end,
}
