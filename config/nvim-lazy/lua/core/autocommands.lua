-- Helm filetype detection
vim.filetype.add({
  pattern = {
    [".*/templates/.*%.yaml"] = "helm",
    [".*/templates/.*%.yml"] = "helm",
    [".*/templates/.*%.tpl"] = "helm",
    ["helmfile.*%.yaml"] = "helm",
    ["helmfile.*%.yml"] = "helm",
  },
})

-- Re-trigger FileType for buffers opened before LSP was ready.
-- lazy.nvim loads plugins during VimEnter, but the initial file's FileType
-- event fires before that, so LSP servers miss it. VeryLazy fires after all
-- plugins are loaded, giving servers a second chance to attach.
--
-- NOTE: vim.lsp.enable registers pattern-based (not buffer-local) FileType
-- autocmds. nvim_exec_autocmds with `buffer=` only fires buffer-local ones,
-- so we must use `pattern=` inside nvim_buf_call so args.buf is correct.
vim.api.nvim_create_autocmd("User", {
  pattern = "VeryLazy",
  callback = function()
    for _, buf in ipairs(vim.api.nvim_list_bufs()) do
      if vim.api.nvim_buf_is_loaded(buf) and vim.api.nvim_buf_get_name(buf) ~= "" then
        local ft = vim.bo[buf].filetype
        if ft and ft ~= "" then
          vim.api.nvim_buf_call(buf, function()
            vim.api.nvim_exec_autocmds("FileType", { pattern = ft, modeline = false })
          end)
        end
      end
    end
  end,
})

-- General settings
local general_group = vim.api.nvim_create_augroup("autocmd_general", { clear = true })

-- Close some filetypes with <q>
vim.api.nvim_create_autocmd("FileType", {
  group = general_group,
  pattern = { "qf", "help", "man", "lspinfo" },
  callback = function()
    vim.keymap.set("n", "q", "<cmd>close<CR>", { buffer = true, silent = true })
  end,
})

-- Highlight yanked text
vim.api.nvim_create_autocmd("TextYankPost", {
  group = general_group,
  callback = function()
    vim.highlight.on_yank({ higroup = "Visual", timeout = 200 })
  end,
})

-- Remove auto-commenting on new lines
vim.api.nvim_create_autocmd("BufWinEnter", {
  group = general_group,
  callback = function()
    vim.opt.formatoptions:remove({ "c", "r", "o" })
  end,
})

-- Make non-modifiable buffers modifiable on read (e.g., when opening a file with `nvim -R`).
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

-- Don't list quickfix buffers
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

-- C / C++ man page lookup
-- K tries section 3 (C stdlib: printf, malloc, …) then section 2
-- (POSIX syscalls: open, read, …), falling back to LSP hover when
-- neither section has a page for the word under the cursor.
local c_group = vim.api.nvim_create_augroup("autocmd_c", { clear = true })

vim.api.nvim_create_autocmd("FileType", {
  group = c_group,
  pattern = { "c", "cpp" },
  callback = function()
    vim.keymap.set("n", "K", function()
      local word = vim.fn.expand("<cword>")
      local ok = pcall(vim.cmd, "Man 3 " .. word)
      if not ok then
        ok = pcall(vim.cmd, "Man 2 " .. word)
      end
      if not ok then
        vim.lsp.buf.hover()
      end
    end, { buffer = true, silent = true, desc = "Man page (3→2) / LSP hover" })
  end,
})

-- PowerShell indent settings
-- Matches codeFormatting.indentationSize (4) in plugins/powershell.lua
-- so manual typing/indenting matches what the LSP formatter produces on save.
local powershell_group = vim.api.nvim_create_augroup("autocmd_powershell", { clear = true })

vim.api.nvim_create_autocmd("FileType", {
  group = powershell_group,
  pattern = "ps1",
  callback = function()
    vim.opt_local.shiftwidth = 4
    vim.opt_local.tabstop = 4
    vim.opt_local.softtabstop = 4
  end,
})

-- LSP format-on-save for languages whose server handles formatting natively
-- (Go is handled by go.nvim; JS/TS/Python/Lua/C# by none-ls)
local lsp_fmt_group = vim.api.nvim_create_augroup("autocmd_lsp_format", { clear = true })

vim.api.nvim_create_autocmd("BufWritePre", {
  group = lsp_fmt_group,
  pattern = { "*.ps1", "*.psm1", "*.psd1" },
  callback = function(args)
    -- powershell_es (PowerShell Editor Services) can take several seconds to
    -- spin up/respond, especially on a cold start right after opening a
    -- file. The default vim.lsp.buf.format timeout (1000ms) is too short and
    -- surfaces as "LSP Timeout". Skip formatting entirely if the client
    -- isn't attached yet (nothing to format against), and use a generous
    -- timeout otherwise so a slow-but-alive server isn't cut off mid-save.
    local clients = vim.lsp.get_clients({ bufnr = args.buf, name = "powershell_es" })
    if #clients == 0 then return end

    vim.lsp.buf.format({
      async = false,
      timeout_ms = 10000,
      filter = function(client) return client.name == "powershell_es" end,
    })
  end,
})
