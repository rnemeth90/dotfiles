local luasnip = require("luasnip")

-- Load friendly-snippets
require("luasnip.loaders.from_vscode").lazy_load()

-- Custom snippet directory (optional)
require("luasnip.loaders.from_lua").lazy_load({ paths = "~/.config/nvim/snippets" })

-- Options
luasnip.config.set_config({
  history = true,                           -- Allow jumping back into snippet history
  updateevents = "TextChanged,TextChangedI", -- Update snippets dynamically
  enable_autosnippets = true,               -- Enable automatic snippet triggering
})
