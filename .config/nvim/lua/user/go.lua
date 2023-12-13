--local status_ok, goplugin = pcall(require, "go.nvim")
--if not status_ok then
 -- print("unable to load golang config")
--  return
--end

-- Run gofmt + goimport on save
local format_sync_grp = vim.api.nvim_create_augroup("GoImport", {})
vim.api.nvim_create_autocmd("BufWritePre", {
  pattern = "*.go",
  callback = function()
   require('go.format').goimport()
  end,
  group = format_sync_grp,
})

require('go').setup()
--require("go.format").gofmt()  -- gofmt only
require("go.format").goimport()  -- goimport + gofmt

