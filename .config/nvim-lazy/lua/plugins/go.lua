return {
  "ray-x/go.nvim",
  ft = { "go", "gomod" },
  dependencies = { "ray-x/guihua.lua" }, -- required for go.nvim
  config = function()
    require("go").setup({
      lsp_codelens = false, -- vim.lsp.codelens.enable() doesn't exist in Neovim 0.11
    })

    -- Format + organize imports synchronously on save via gopls
    local format_sync_grp = vim.api.nvim_create_augroup("GoFormat", { clear = true })
    vim.api.nvim_create_autocmd("BufWritePre", {
      pattern = "*.go",
      group = format_sync_grp,
      callback = function()
        local clients = vim.lsp.get_clients({ bufnr = 0 })
        if #clients == 0 then return end

        -- organise imports via gopls if it supports codeAction
        local supports_code_action = false
        for _, c in ipairs(clients) do
          if c.supports_method("textDocument/codeAction") then
            supports_code_action = true
            break
          end
        end

        if supports_code_action then
          local params = vim.lsp.util.make_range_params()
          params.context = { only = { "source.organizeImports" } }
          local result = vim.lsp.buf_request_sync(0, "textDocument/codeAction", params, 3000)
          for cid, res in pairs(result or {}) do
            for _, r in pairs(res.result or {}) do
              if r.edit then
                local enc = (vim.lsp.get_client_by_id(cid) or {}).offset_encoding or "utf-16"
                vim.lsp.util.apply_workspace_edit(r.edit, enc)
              end
            end
          end
        end

        vim.lsp.buf.format({ async = false })
      end,
    })

    -- Optional: run once on load
    -- require("go.format").goimport()
  end,
  build = ':lua require("go.install").update_all_sync()', -- install/update binaries when installing the plugin
}
