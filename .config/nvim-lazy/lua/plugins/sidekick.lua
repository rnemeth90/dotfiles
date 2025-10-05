return {
  "folke/sidekick.nvim",
  lazy = false,
  opts = {
    cli = {
      tools = {
        {
          name = "cursor",
          cmd = { "cursor-agent", "prompt" },
          input = "stdin",
          context = true,
        },
      },
      mux = {
        backend = "tmux",
        enabled = true,
      },
    },
  },
  config = function(_, opts)
    assert(opts.cli and opts.cli.tools, "🛑 Missing cli.tools in sidekick config")

    for i, tool in ipairs(opts.cli.tools) do
      assert(type(tool.name) == "string", "🛑 Tool at index " .. i .. " has invalid 'name'")
      assert(type(tool.cmd) == "table", "🛑 Tool at index " .. i .. " must define `cmd` as a table")
    end

    require("sidekick").setup(opts)
  end,
  keys = {
    {
      "<tab>",
      function()
        if not require("sidekick").nes_jump_or_apply() then
          return "<Tab>"
        end
      end,
      expr = true,
      desc = "Goto/Apply Next Edit Suggestion",
    },
    {
      "<leader>aa",
      function() require("sidekick.cli").toggle() end,
      desc = "Sidekick Toggle CLI",
    },
    {
      "<leader>as",
      function() require("sidekick.cli").select() end,
      desc = "Select CLI",
    },
    {
      "<leader>at",
      function() require("sidekick.cli").send({ msg = "{this}" }) end,
      mode = { "x", "n" },
      desc = "Send This",
    },
    {
      "<leader>av",
      function() require("sidekick.cli").send({ msg = "{selection}" }) end,
      mode = { "x" },
      desc = "Send Visual Selection",
    },
    {
      "<leader>ap",
      function() require("sidekick.cli").prompt() end,
      mode = { "n", "x" },
      desc = "Sidekick Select Prompt",
    },
    {
      "<c-.>",
      function() require("sidekick.cli").focus() end,
      mode = { "n", "x", "i", "t" },
      desc = "Sidekick Switch Focus",
    },
    {
      "<leader>ac",
      function() require("sidekick.cli").toggle({ name = "claude", focus = true }) end,
      desc = "Sidekick Toggle Claude",
    },
  },
}

-- return {
--   "folke/sidekick.nvim",
--   lazy = false, -- for testing, you can revert later
--   opts = {
--     cli = {
--       tools = {
--         {
--           name = "cursor",
--           command = "cursor-agent",
--           args = {},
--           input = "stdin",
--           context = true,
--         },
--       },
--       mux = {
--         backend = "tmux",
--         enabled = true,
--       },
--     },
--   },
--   config = function(_, opts)
--     -- Validate tool shape to prevent crash
--     assert(opts.cli and opts.cli.tools, "🛑 Missing cli.tools in sidekick config")
--
--     for i, tool in ipairs(opts.cli.tools) do
--       assert(type(tool.name) == "string", "🛑 Tool at index " .. i .. " has invalid 'name'")
--       assert(type(tool.command) == "string", "🛑 Tool at index " .. i .. " has invalid 'command'")
--     end
--
--
--     for i, tool in ipairs(opts.cli.tools) do
--       if type(tool.name) ~= "string" then
--         vim.print("❌ Tool " .. i .. " has invalid name: " .. vim.inspect(tool.name))
--         error("Tool at index " .. i .. " has non-string `name`")
--       end
--     end
--
--     require("sidekick").setup(opts)
--
--   end,
--   keys = {
--     {
--       "<tab>",
--       function()
--         if not require("sidekick").nes_jump_or_apply() then
--           return "<Tab>"
--         end
--       end,
--       expr = true,
--       desc = "Goto/Apply Next Edit Suggestion",
--     },
--     {
--       "<leader>aa",
--       function() require("sidekick.cli").toggle() end,
--       desc = "Sidekick Toggle CLI",
--     },
--     {
--       "<leader>as",
--       function() require("sidekick.cli").select() end,
--       desc = "Select CLI",
--     },
--     {
--       "<leader>at",
--       function() require("sidekick.cli").send({ msg = "{this}" }) end,
--       mode = { "x", "n" },
--       desc = "Send This",
--     },
--     {
--       "<leader>av",
--       function() require("sidekick.cli").send({ msg = "{selection}" }) end,
--       mode = { "x" },
--       desc = "Send Visual Selection",
--     },
--     {
--       "<leader>ap",
--       function() require("sidekick.cli").prompt() end,
--       mode = { "n", "x" },
--       desc = "Sidekick Select Prompt",
--     },
--     {
--       "<c-.>",
--       function() require("sidekick.cli").focus() end,
--       mode = { "n", "x", "i", "t" },
--       desc = "Sidekick Switch Focus",
--     },
--     {
--       "<leader>ac",
--       function() require("sidekick.cli").toggle({ name = "claude", focus = true }) end,
--       desc = "Sidekick Toggle Claude",
--     },
--   },
-- }
--
