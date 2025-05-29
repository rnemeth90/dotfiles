return {
  "lukas-reineke/indent-blankline.nvim",
  main = "ibl", -- For v3, if you're using the new API (`require("ibl")`)
  event = { "BufReadPre", "BufNewFile" },
  config = function()
    -- Global settings
    vim.g.indent_blankline_buftype_exclude = { "terminal", "nofile" }
    vim.g.indent_blankline_filetype_exclude = {
      "help",
      "startify",
      "dashboard",
      "packer",
      "neogitstatus",
      "NvimTree",
      "Trouble",
    }
    vim.g.indentLine_enabled = 1
    vim.g.indent_blankline_char = "▏"
    vim.g.indent_blankline_show_trailing_blankline_indent = false
    vim.g.indent_blankline_show_first_indent_level = true
    vim.g.indent_blankline_use_treesitter = true
    vim.g.indent_blankline_show_current_context = true
    vim.g.indent_blankline_context_patterns = {
      "class",
      "return",
      "function",
      "method",
      "^if",
      "^while",
      "jsx_element",
      "^for",
      "^object",
      "^table",
      "block",
      "arguments",
      "if_statement",
      "else_clause",
      "jsx_element",
      "jsx_self_closing_element",
      "try_statement",
      "catch_clause",
      "import_statement",
      "operation_type",
    }

    -- HACK: Fix colorcolumn issue
    vim.wo.colorcolumn = "99999"

    -- Plugin setup
    require("indent_blankline").setup({
      show_current_context = true,
    })
  end,
}
