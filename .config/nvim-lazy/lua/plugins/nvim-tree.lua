return {
  "nvim-tree/nvim-tree.lua",
  version = "*",
  lazy = false,
  dependencies = {
    "nvim-tree/nvim-web-devicons",
  },
  config = function()
    local api = require("nvim-tree.api")


    local function my_on_attach(bufnr)
      require("helpers.keys").set_leader(" ")
      local map_utils = require("helpers.keys")

      -- Add buffer-local mapping support
      local function buf_map(mode, lhs, rhs, desc)
        map_utils.map(mode, lhs, rhs, desc, { buffer = bufnr })
      end

      buf_map("n", "<CR>", api.node.open.edit, "Open")
      buf_map("n", "l", api.node.open.edit, "Open")
      buf_map("n", "h", api.node.navigate.parent_close, "Close Directory")
      buf_map("n", "v", api.node.open.vertical, "Open: Vertical Split")
      buf_map("n", "<leader>e", ":NvimTreeToggle<CR>", "Toggle NvimTree")
      buf_map("n", "<leader>r", ":NvimTreeRefresh<CR>", "Refresh NvimTree")
    end

    -- local function my_on_attach()
    --   require("helpers.keys").set_leader(" ")
    --   local map_utils = require("helpers.keys")
    --
    --   map_utils.map("n", "<CR>", api.node.open.edit, "Open")
    --   -- map_utils.map("n", "o", api.node.open.edit, "Open")
    --   map_utils.map("n", "l", api.node.open.edit, "Open")
    --   map_utils.map("n", "h", api.node.navigate.parent_close, "Close Directory")
    --   map_utils.map("n", "v", api.node.open.vertical, "Open: Vertical Split")
    --   map_utils.map("n", "<leader>e", ":NvimTreeToggle<CR>", "Toggle NvimTree")
    --   map_utils.map("n", "<leader>r", ":NvimTreeRefresh<CR>", "Refresh NvimTree")
    -- end

    require("nvim-tree").setup({
      disable_netrw = true,
      hijack_netrw = true,
      update_cwd = true,
      open_on_tab = false,
      filters = {
        dotfiles = false,
      },
      update_focused_file = {
        enable = true,
        update_cwd = true,
      },
      renderer = {
        root_folder_modifier = ":t",
        icons = {
          glyphs = {
            default = "",
            symlink = "",
            folder = {
              arrow_open = "",
              arrow_closed = "",
              default = "",
              open = "",
              empty = "",
              empty_open = "",
              symlink = "",
              symlink_open = "",
            },
            git = {
              unstaged = "",
              staged = "S",
              unmerged = "",
              renamed = ">",
              untracked = "U",
              deleted = "",
              ignored = "◌",
            },
          },
        },
      },
      diagnostics = {
        enable = true,
        show_on_dirs = true,
        icons = {
          hint = "",
          info = "",
          warning = "",
          error = "",
        },
      },
      view = {
        width = 25,
        side = "left",
      },
      on_attach = my_on_attach,
    })
  end,
}
