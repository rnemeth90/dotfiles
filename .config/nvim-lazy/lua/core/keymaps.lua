-- Set leader key
vim.g.mapleader = " "
vim.g.maplocalleader = " "

local luasnip = require("luasnip")

-- Options
local opts = { noremap = true, silent = true }

-- Custom Keymap Function
local function keymap(mode, lhs, rhs, desc, opts)
  -- Ensure opts is always a table
  opts = opts or {}
  local options = vim.tbl_extend("force", { noremap = true, silent = true }, opts)

  -- Validate arguments for standard keymaps
  if type(mode) ~= "string" then
    error("Invalid 'mode' argument. Expected string, got: " .. type(mode))
  end
  if type(lhs) ~= "string" then
    error("Invalid 'lhs' argument. Expected string, got: " .. type(lhs))
  end
  if rhs == nil or (type(rhs) ~= "string" and type(rhs) ~= "function") then
    error("Invalid 'rhs' argument. Expected string or function, got: " .. type(rhs))
  end

  -- Define the keymap
  vim.api.nvim_set_keymap(mode, lhs, type(rhs) == "string" and rhs or "", options)

  -- Register with which-key if description is provided
  -- if desc and desc ~= "" then
  --   require("which-key").register({
  --     [lhs] = { desc },
  --   }, { mode = mode })
  -- end
end

--------------------
-- General Keymaps
--------------------

keymap("n", "<leader>w", ":w<CR>", "Save file", opts)   -- Save file
keymap("n", "<leader>q", ":q<CR>", "Quit Neovim", opts) -- Quit Neovim

-- Window Navigation
keymap("n", "<C-h>", "<C-w>h", "", opts) -- Move to left window
keymap("n", "<C-l>", "<C-w>l", "", opts) -- Move to right window
keymap("n", "<C-j>", "<C-w>j", "", opts) -- Move to bottom window
keymap("n", "<C-k>", "<C-w>k", "", opts) -- Move to top window

-- Resize Splits
keymap("n", "<C-Up>", ":resize -2<CR>", "", opts)             -- Resize up
keymap("n", "<C-Down>", ":resize +2<CR>", "", opts)           -- Resize down
keymap("n", "<C-Left>", ":vertical resize -2<CR>", "", opts)  -- Resize left
keymap("n", "<C-Right>", ":vertical resize +2<CR>", "", opts) -- Resize right

-- Buffer Navigation
keymap("n", "<S-l>", ":bnext<CR>", "", opts)     -- Next buffer
keymap("n", "<S-h>", ":bprevious<CR>", "", opts) -- Previous buffer

-- Visual Mode Keymaps
keymap("v", "<", "<gv", "", opts)  -- Indent left and reselect
keymap("v", ">", ">gv", "", opts)  -- Indent right and reselect
keymap("v", "p", '"_dP', "", opts) -- Paste without overwriting register

-- Move Text
keymap("v", "<A-j>", ":m .+1<CR>==", "", opts) -- Move text down
keymap("v", "<A-k>", ":m .-2<CR>==", "", opts) -- Move text up
-- keymap("n", "<A-j>", "<Esc>:m .+1<CR>==gi", opts)
-- keymap("n", "<A-k>", "<Esc>:m .-2<CR>==gi", opts)
keymap("v", "J", ":m '>+1<CR>gv=gv", "", opts) -- Shift visual selected line down
keymap("v", "K", ":m '<-2<CR>gv=gv", "", opts) -- Shift visual selected line up
-- keymap("x", "J", ":move '>+1<CR>gv-gv", opts)
-- keymap("x", "K", ":move '<-2<CR>gv-gv", opts)
-- keymap("x", "<A-j>", ":move '>+1<CR>gv-gv", opts)
-- keymap("x", "<A-k>", ":move '<-2<CR>gv-gv", opts)
-- keymap("v", "<A-j>", ":m .+1<CR>==", opts)
-- keymap("v", "<A-k>", ":m .-2<CR>==", opts)
-- keymap("v", "p", '"_dP', opts)

-- Press jk fast to exit insert mode
keymap("i", "jk", "<ESC>", "", opts)
keymap("i", "kj", "<ESC>", "", opts)
keymap("v", "jk", "<ESC>", "", opts)
keymap("v", "kj", "<ESC>", "", opts)

-- formatting --
keymap("n", "<leader>gf", "vim.lsp.buf.format", "", opts)

--------------------
-- Plugin Keymaps
--------------------

-- nvimtree
-- keymap("n", "<leader>e", ":NvimTreeToggle<CR>", "Toggle NvimTree")

-- Telescope
-- keymap("n", "<leader>g", ":Telescope file_browser<CR>", "", opts)                             -- open telescope file browser
-- keymap("n", "<leader>ff", "<cmd>lua require('telescope.builtin').find_files()<CR>", "", opts) -- Find files
-- keymap("n", "<leader>fg", "<cmd>lua require('telescope.builtin').live_grep()<CR>", "", opts)  -- Live grep
-- keymap("n", "<leader>fb", "<cmd>lua require('telescope.builtin').buffers()<CR>", "", opts)    -- List buffers
-- keymap("n", "<leader>fh", "<cmd>lua require('telescope.builtin').help_tags()<CR>", "", opts)  -- Help tags
--
-- -- Telescope Extensions Keymaps
-- keymap("n", "<leader>fm", "<cmd>lua require('telescope').extensions.media_files.media_files()<CR>", "", opts)   -- Media files
-- keymap("n", "<leader>fe", "<cmd>lua require('telescope').extensions.file_browser.file_browser()<CR>", "", opts) -- File browser
--
-- LSP Keymaps
keymap("n", "gd", "<cmd>lua vim.lsp.buf.definition()<CR>", "", opts)          -- Go to definition
keymap("n", "K", "<cmd>lua vim.lsp.buf.hover()<CR>", "", opts)                -- Hover documentation
keymap("n", "gi", "<cmd>lua vim.lsp.buf.implementation()<CR>", "", opts)      -- Go to implementation
keymap("n", "<leader>rn", "<cmd>lua vim.lsp.buf.rename()<CR>", "", opts)      -- Rename symbol
keymap("n", "<leader>ca", "<cmd>lua vim.lsp.buf.code_action()<CR>", "", opts) -- Code actions

-- Diagnostics
keymap("n", "[d", "<cmd>lua vim.diagnostic.goto_prev()<CR>", "", opts)         -- Previous diagnostic
keymap("n", "]d", "<cmd>lua vim.diagnostic.goto_next()<CR>", "", opts)         -- Next diagnostic
keymap("n", "<leader>d", "<cmd>lua vim.diagnostic.open_float()<CR>", "", opts) -- Show diagnostic
keymap("n", "<leader>q", "<cmd>lua vim.diagnostic.setloclist()<CR>", "", opts) -- Diagnostic list

-- terraform --
keymap("n", "<leader>ti", ":!terraform init<CR>", "", opts)
keymap("n", "<leader>tv", ":!terraform validate<CR>", "", opts)
keymap("n", "<leader>tp", ":!terraform plan<CR>", "", opts)
keymap("n", "<leader>taa", ":!terraform apply -auto-approve<CR>", "", opts)

-- Neoscroll Keymaps
keymap("n", "<C-u>", "<cmd>lua require('neoscroll').scroll(-vim.wo.scroll, true, 150)<CR>", "", opts)
keymap("n", "<C-d>", "<cmd>lua require('neoscroll').scroll(vim.wo.scroll, true, 150)<CR>", "", opts)
keymap("n", "<C-b>", "<cmd>lua require('neoscroll').scroll(-vim.api.nvim_win_get_height(0), true, 250)<CR>", "", opts)
keymap("n", "<C-f>", "<cmd>lua require('neoscroll').scroll(vim.api.nvim_win_get_height(0), true, 250)<CR>", "", opts)
keymap("n", "<C-y>", "<cmd>lua require('neoscroll').scroll(-1, true, 50)<CR>", "", opts)
keymap("n", "<C-e>", "<cmd>lua require('neoscroll').scroll(1, true, 50)<CR>", "", opts)
keymap("n", "zt", "<cmd>lua require('neoscroll').scroll(0, true, 250, 'zt')<CR>", "", opts)
keymap("n", "zz", "<cmd>lua require('neoscroll').scroll(0, true, 250, 'zz')<CR>", "", opts)
keymap("n", "zb", "<cmd>lua require('neoscroll').scroll(0, true, 250, 'zb')<CR>", "", opts)

-- ToggleTerm Keybindings
keymap(
  "n",
  "<leader>lg",
  "<cmd>lua require('toggleterm.terminal').Terminal:new({cmd='lazygit', hidden=true}):toggle()<CR>",
  "",
  opts
)
keymap(
  "n",
  "<leader>tn",
  "<cmd>lua require('toggleterm.terminal').Terminal:new({cmd='node', hidden=true}):toggle()<CR>",
  "",
  opts
)
keymap(
  "n",
  "<leader>td",
  "<cmd>lua require('toggleterm.terminal').Terminal:new({cmd='ncdu', hidden=true}):toggle()<CR>",
  "",
  opts
)
keymap(
  "n",
  "<leader>th",
  "<cmd>lua require('toggleterm.terminal').Terminal:new({cmd='htop', hidden=true}):toggle()<CR>",
  "",
  opts
)
keymap(
  "n",
  "<leader>tp",
  "<cmd>lua require('toggleterm.terminal').Terminal:new({cmd='python', hidden=true}):toggle()<CR>",
  "",
  opts
)

-- LSP Keymaps
local M = {}

-- Gitsigns Keymaps
keymap("n", "]c", function()
  if vim.wo.diff then
    return "]c"
  end
  vim.schedule(function()
    require("gitsigns").next_hunk()
  end)
  return "<Ignore>"
end, "Next hunk")

keymap("n", "[c", function()
  if vim.wo.diff then
    return "[c"
  end
  vim.schedule(function()
    require("gitsigns").prev_hunk()
  end)
  return "<Ignore>"
end, "Previous hunk")

keymap("n", "<leader>hs", ":lua require('gitsigns').stage_hunk()<CR>", "Stage hunk")
keymap("n", "<leader>hr", ":lua require('gitsigns').reset_hunk()<CR>", "Reset hunk")
keymap("n", "<leader>hS", ":lua require('gitsigns').stage_buffer()<CR>", "Stage buffer")
keymap("n", "<leader>hu", ":lua require('gitsigns').undo_stage_hunk()<CR>", "Undo stage hunk")
keymap("n", "<leader>hp", ":lua require('gitsigns').preview_hunk()<CR>", "Preview hunk")
keymap("n", "<leader>hb", ":lua require('gitsigns').toggle_current_line_blame()<CR>", "Toggle blame")
keymap("n", "<leader>hd", ":lua require('gitsigns').diffthis()<CR>", "View diff")
keymap("n", "<leader>hD", ":lua require('gitsigns').diffthis('~')<CR>", "View diff (HEAD~)")
keymap("n", "<leader>ht", ":lua require('gitsigns').toggle_deleted()<CR>", "Toggle deleted lines")

-- Function to set LSP-specific keymaps
M.lsp_keymaps = function(bufnr)
  local opts = { noremap = true, silent = true }
  local keymap = vim.api.nvim_buf_set_keymap

  keymap(bufnr, "n", "gD", "<cmd>lua vim.lsp.buf.declaration()<CR>", opts)
  keymap(bufnr, "n", "gd", "<cmd>lua vim.lsp.buf.definition()<CR>", opts)
  keymap(bufnr, "n", "K", "<cmd>lua vim.lsp.buf.hover()<CR>", opts)
  keymap(bufnr, "n", "gI", "<cmd>lua vim.lsp.buf.implementation()<CR>", opts)
  keymap(bufnr, "n", "gr", "<cmd>lua vim.lsp.buf.references()<CR>", opts)
  keymap(bufnr, "n", "gl", "<cmd>lua vim.diagnostic.open_float()<CR>", opts) -- Show line diagnostic
  keymap(bufnr, "n", "<leader>lf", "<cmd>lua vim.lsp.buf.format{ async = true }<CR>", opts)
  keymap(bufnr, "n", "<leader>li", "<cmd>LspInfo<CR>", opts)
  keymap(bufnr, "n", "<leader>lI", "<cmd>LspInstallInfo<CR>", opts)
  keymap(bufnr, "n", "<leader>la", "<cmd>lua vim.lsp.buf.code_action()<CR>", opts)
  keymap(bufnr, "n", "<leader>lj", "<cmd>lua vim.diagnostic.goto_next({buffer=0})<CR>", opts)
  keymap(bufnr, "n", "<leader>lk", "<cmd>lua vim.diagnostic.goto_prev({buffer=0})<CR>", opts)
  keymap(bufnr, "n", "<leader>lr", "<cmd>lua vim.lsp.buf.rename()<CR>", opts)
  keymap(bufnr, "n", "<leader>ls", "<cmd>lua vim.lsp.buf.signature_help()<CR>", opts)
  keymap(bufnr, "n", "<leader>lq", "<cmd>lua vim.diagnostic.setloclist()<CR>", opts)
end

return M
