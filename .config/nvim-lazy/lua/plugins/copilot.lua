return {
  "zbirenbaum/copilot.lua",
  cmd = "Copilot",
  event = "InsertEnter",
  config = function()
    require("copilot").setup({
      suggestion = {
        enabled = true,
        auto_trigger = true,
        debounce = 75,
        keymap = {
          accept = "<M-l>",
          accept_word = false,
          accept_line = false,
          next = "<M-]>",
          prev = "<M-[>",
          dismiss = "<C-]>",
        },
      },
      panel = {
        enabled = true,
        auto_refresh = false,
        keymap = {
          jump_prev = "[[",
          jump_next = "]]",
          accept = "<CR>",
          refresh = "gr",
          open = "<M-CR>",
        },
        layout = {
          position = "bottom",
          ratio = 0.4,
        },
      },
      filetypes = {
        yaml = false,
        markdown = false,
        help = false,
        gitcommit = false,
        gitrebase = false,
        hgcommit = false,
        svn = false,
        cvs = false,
        ["."] = false,
      },
    })
  end,
}
--   "zbirenbaum/copilot.lua",
--   event = "InsertEnter",
--   dependencies = {
--     {
--       "zbirenbaum/copilot-cmp",
--       config = function()
--         require("copilot_cmp").setup()
--       end,
--     },
--   },
--   config = function()
--     local handlers = require("helpers.handlers")
--     require("copilot").setup({
--       lsp = {
-- 		    enabled = true, -- ← THIS MUST BE TRUE
--         setup = {
--           on_attach = handlers.on_attach, -- or your existing on_attach
--           capabilities = handlers.capabilities,
--         },
-- 		    -- cmd = "copilot-node-server", -- optional
-- 		    -- settings = {
-- 			    -- advanced = {
-- 				    -- listCount = 10,
-- 				    -- inlineSuggestCount = 3,
-- 			    -- },
-- 		    -- },
-- 	    },
--       panel = {
--         enabled = true,
--         auto_refresh = false,
--         keymap = {
--           jump_prev = "[[",
--           jump_next = "]]",
--           accept = "<CR>",
--           refresh = "gr",
--           open = "<M-CR>",
--         },
--         layout = {
--           position = "bottom",
--           ratio = 0.4,
--         },
--       },
--       suggestion = {
--         enabled = false,
--         auto_trigger = true,
--         hide_during_completion = true,
--         debounce = 75,
--         trigger_on_accept = true,
--         keymap = {
--           accept = "<M-l>",
--           accept_word = false,
--           accept_line = false,
--           next = "<M-]>",
--           prev = "<M-[>",
--           dismiss = "<C-]>",
--         },
--       },
--       filetypes = {
--         yaml = false,
--         markdown = false,
--         help = false,
--         gitcommit = false,
--         gitrebase = false,
--         hgcommit = false,
--         svn = false,
--         cvs = false,
--         ["."] = false,
--       },
--       auth_provider_url = nil,
--       logger = {
--         file = vim.fn.stdpath("log") .. "/copilot-lua.log",
--         file_log_level = vim.log.levels.OFF,
--         print_log_level = vim.log.levels.WARN,
--         trace_lsp = "off",
--         trace_lsp_progress = false,
--         log_lsp_messages = false,
--       },
--       copilot_node_command = "node",
--       workspace_folders = {},
--       copilot_model = "",
--       root_dir = function()
--         return vim.fs.dirname(vim.fs.find(".git", { upward = true })[1])
--       end,
--       should_attach = function(_, _)
--         return vim.bo.buflisted and vim.bo.buftype == ""
--       end,
--
--       server = {
--         type = "nodejs",
--         custom_server_filepath = nil,
--       },
--       server_opts_overrides = {},
--     })
--   end,
-- }
