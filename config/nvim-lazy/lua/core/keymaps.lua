-- Set leader key
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Custom Keymap Function
local function keymap(mode, lhs, rhs, desc, extra_opts)
  extra_opts = extra_opts or {}
  local options = vim.tbl_extend("force", { noremap = true, silent = true }, extra_opts)
  if desc and desc ~= "" then
    options.desc = desc
  end
  vim.keymap.set(mode, lhs, rhs, options)
end

--------------------
-- General Keymaps
--------------------

keymap("n", "<leader>w", ":w<CR>", "Save file")
keymap("n", "<leader>q", ":q<CR>", "Quit Neovim")

-- Window Navigation
keymap("n", "<C-h>", "<C-w>h", "Move to left window")
keymap("n", "<C-l>", "<C-w>l", "Move to right window")
keymap("n", "<C-j>", "<C-w>j", "Move to bottom window")
keymap("n", "<C-k>", "<C-w>k", "Move to top window")

-- Resize Splits
keymap("n", "<leader>wk", ":resize -2<CR>",          "Resize split up")
keymap("n", "<leader>wj", ":resize +2<CR>",          "Resize split down")
keymap("n", "<leader>wh", ":vertical resize -2<CR>", "Resize split left")
keymap("n", "<leader>wl", ":vertical resize +2<CR>", "Resize split right")
keymap("n", "<leader>we", "<C-w>=",                  "Equalize splits")

-- Buffer Navigation
keymap("n", "<S-l>", ":bnext<CR>", "Next buffer")
keymap("n", "<S-h>", ":bprevious<CR>", "Previous buffer")

-- Visual Mode
keymap("v", "<", "<gv", "Indent left")
keymap("v", ">", ">gv", "Indent right")
keymap("v", "p", '"_dP', "Paste without overwriting register")

-- Move Text
keymap("v", "<A-j>", ":m .+1<CR>==", "Move text down")
keymap("v", "<A-k>", ":m .-2<CR>==", "Move text up")

-- Press jk fast to exit insert mode
keymap("i", "jk", "<ESC>", "Exit insert mode")
keymap("v", "jk", "<ESC>", "Exit visual mode")

-- Formatting
keymap("n", "<leader>lf", "<cmd>lua vim.lsp.buf.format({ async = true })<CR>", "Format buffer")

--------------------
-- Plugin Keymaps
--------------------

-- LSP (gd, gD, gr, gI handled by Snacks pickers)
keymap("n", "<leader>lr", "<cmd>lua vim.lsp.buf.rename()<CR>", "Rename symbol")
keymap("n", "<leader>la", "<cmd>lua vim.lsp.buf.code_action()<CR>", "Code actions")

-- Diagnostics
keymap("n", "[d", "<cmd>lua vim.diagnostic.goto_prev()<CR>", "Previous diagnostic")
keymap("n", "]d", "<cmd>lua vim.diagnostic.goto_next()<CR>", "Next diagnostic")
keymap("n", "<leader>dd", "<cmd>lua vim.diagnostic.open_float()<CR>", "Show diagnostic")
keymap("n", "<leader>dl", "<cmd>lua vim.diagnostic.setloclist()<CR>", "Diagnostic list")

-- Terraform
keymap("n", "<leader>ti", ":!terraform init<CR>", "Terraform init")
keymap("n", "<leader>tv", ":!terraform validate<CR>", "Terraform validate")
keymap("n", "<leader>tp", ":!terraform plan<CR>", "Terraform plan")
keymap("n", "<leader>taa", ":!terraform apply -auto-approve<CR>", "Terraform apply")

-- DAP (Debugger) keymaps are buffer-local; see plugins/nvim-dap.lua

--------------------
-- LSP Buffer Keymaps (set on_attach)
--------------------

local M = {}

M.lsp_keymaps = function(bufnr)
  local bufopts = { buffer = bufnr }
  local ft = vim.bo[bufnr].filetype

  -- C/C++: K is handled by the FileType autocmd in autocommands.lua
  -- (man page lookup with LSP hover fallback). Setting it here would
  -- overwrite that mapping since on_attach fires after FileType.
  if ft ~= "c" and ft ~= "cpp" then
    keymap("n", "K", "<cmd>lua vim.lsp.buf.hover()<CR>", "Hover documentation", bufopts)
  end

  keymap("n", "gl",          "<cmd>lua vim.diagnostic.open_float()<CR>",  "Show line diagnostic", bufopts)
  keymap("n", "<leader>li",  "<cmd>LspInfo<CR>",                          "LSP info",             bufopts)
  keymap("n", "<leader>ls",  "<cmd>lua vim.lsp.buf.signature_help()<CR>", "Signature help",       bufopts)
end

return M
