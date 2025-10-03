return {
  "nvim-telescope/telescope.nvim",
  tag = "0.1.8",
  dependencies = {  "nvim-telescope/telescope-file-browser.nvim", "nvim-telescope/telescope-media-files.nvim", "nvim-lua/plenary.nvim" },
  config = function()
    local actions = require("telescope.actions")

    require("telescope").setup({
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
          find_command = {
            "rg",
            "--files",
            "--hidden",
            "--glob",
            "!**/.git/*",
          },
          theme = "ivy",
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

    -- Load extensions
    require("telescope").load_extension("media_files")
    require("telescope").load_extension("file_browser")
  end,
}
