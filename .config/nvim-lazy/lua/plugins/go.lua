return {
  "ray-x/go.nvim",
  ft = { "go", "gomod" },
  dependencies = { "ray-x/guihua.lua" }, -- required for go.nvim
  config = function()
    require("go").setup()

    -- Run goimport (gofmt + import fix) on save
    local format_sync_grp = vim.api.nvim_create_augroup("GoImport", {})
    vim.api.nvim_create_autocmd("BufWritePre", {
      pattern = "*.go",
      callback = function()
        require("go.format").goimport()
      end,
      group = format_sync_grp,
    })

    -- Optional: run once on load
    -- require("go.format").goimport()
  end,
  build = ':lua require("go.install").update_all_sync()', -- install/update binaries when installing the plugin
}
