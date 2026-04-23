-- General settings
local general_group = vim.api.nvim_create_augroup("autocmd_general", { clear = true })

vim.api.nvim_create_autocmd("FileType", {
  group = general_group,
  pattern = { "qf", "help", "man", "lspinfo" },
  callback = function()
    vim.keymap.set("n", "q", "<cmd>close<CR>", { buffer = true, silent = true })
  end,
})

vim.api.nvim_create_autocmd("TextYankPost", {
  group = general_group,
  callback = function()
    vim.highlight.on_yank({ higroup = "Visual", timeout = 200 })
  end,
})

vim.api.nvim_create_autocmd("BufWinEnter", {
  group = general_group,
  callback = function()
    vim.opt.formatoptions:remove({ "c", "r", "o" })
  end,
})

vim.api.nvim_create_autocmd("BufReadPost", {
  group = general_group,
  callback = function()
    local buf = vim.api.nvim_get_current_buf()
    local name = vim.api.nvim_buf_get_name(buf)
    if name ~= "" and vim.bo[buf].buftype == "" and not vim.bo[buf].modifiable then
      vim.bo[buf].modifiable = true
      vim.bo[buf].readonly = false
    end
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  group = general_group,
  pattern = "qf",
  callback = function()
    vim.opt_local.buflisted = false
  end,
})

-- Git commit settings
local git_group = vim.api.nvim_create_augroup("autocmd_git", { clear = true })

vim.api.nvim_create_autocmd("FileType", {
  group = git_group,
  pattern = "gitcommit",
  callback = function()
    vim.opt_local.wrap = true
    vim.opt_local.spell = true
  end,
})

-- Markdown settings
local markdown_group = vim.api.nvim_create_augroup("autocmd_markdown", { clear = true })

vim.api.nvim_create_autocmd("FileType", {
  group = markdown_group,
  pattern = "markdown",
  callback = function()
    vim.opt_local.wrap = true
    vim.opt_local.spell = true
  end,
})

-- Auto resize splits
local resize_group = vim.api.nvim_create_augroup("autocmd_resize", { clear = true })

vim.api.nvim_create_autocmd("VimResized", {
  group = resize_group,
  callback = function()
    vim.cmd("tabdo wincmd =")
  end,
})

-- Alpha dashboard tabline hide/show
local alpha_group = vim.api.nvim_create_augroup("autocmd_alpha", { clear = true })

vim.api.nvim_create_autocmd("User", {
  group = alpha_group,
  pattern = "AlphaReady",
  callback = function()
    vim.opt.showtabline = 0
    vim.api.nvim_create_autocmd("BufUnload", {
      buffer = 0,
      callback = function()
        vim.opt.showtabline = 2
      end,
    })
  end,
})

-- Optional: Autoformat (commented out)
-- local lsp_group = vim.api.nvim_create_augroup("autocmd_lsp", { clear = true })
-- vim.api.nvim_create_autocmd("BufWritePre", {
--   group = lsp_group,
--   pattern = "*",
--   callback = function()
--     vim.lsp.buf.format({ async = false })
--   end,
-- })
