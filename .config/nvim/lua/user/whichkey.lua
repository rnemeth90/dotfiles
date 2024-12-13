local status_ok, which_key = pcall(require, "which-key")
if not status_ok then
  return
end

which_key.setup({
  plugins = {
    marks = true,
    registers = true,
    spelling = {
      enabled = true,
      suggestions = 20,
    },
    presets = {
      operators = true,
      motions = true,
      text_objects = true,
      windows = true,
      nav = true,
      z = true,
      g = true,
    },
  },
  icons = {
    breadcrumb = "»", -- Separator for key combo breadcrumbs
    separator = "➜", -- Separator between key and its label
    group = "+", -- Symbol prepended to groups
  },
  layout = {
    height = { min = 4, max = 25 }, -- Min and max height of the popup
    width = { min = 20, max = 50 }, -- Min and max width of columns
    spacing = 3,                  -- Spacing between columns
    align = "center",             -- Alignment of columns
  },
  show_help = true,               -- Show help message in the command line
})
