local status_ok, telescope = pcall(require, "telescope")
if not status_ok then
  return
end

local actions = require("telescope.actions")

telescope.setup({
  defaults = {
    prompt_prefix = "🔍 ",
    selection_caret = " ",
    path_display = { "smart" },

    mappings = {
      i = {
        ["<C-n>"] = actions.move_selection_next,
        ["<C-p>"] = actions.move_selection_previous,
        ["<C-c>"] = actions.close,
      },
      n = {
        ["q"] = actions.close,
      },
    },
  },

  pickers = {
    find_files = {
      -- find_command = {
      --   "rg",        -- Use ripgrep
      --   "--files",   -- List files
      --   "--hidden",  -- Show hidden files
      --   "--glob",
      --   "!**/.git/*", -- Exclude `.git` directory
      -- },
      theme = "ivy", -- Apply ivy theme
      hidden = true, -- Show hidden files
      no_ignore = true, -- Include ignored files
    },
  },

  extensions = {
    media_files = {
      filetypes = { "png", "webp", "jpg", "jpeg" },
      find_cmd = "rg",
    },
    file_browser = {
      theme = "ivy",
      hijack_netrw = false,
    },
  },
})

-- Load extensions after setup
telescope.load_extension("media_files")
telescope.load_extension("file_browser")
