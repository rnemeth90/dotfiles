local status_ok, gitsigns = pcall(require, "gitsigns")
if not status_ok then
  return
end

gitsigns.setup({
  signs = {
    add = { text = "┃" },
    change = { text = "┃" },
    delete = { text = "_" },
    topdelete = { text = "‾" },
    changedelete = { text = "~" },
    untracked = { text = "┆" },
  },
  signcolumn = true,
  numhl = false,
  linehl = false,
  word_diff = false,
  watch_gitdir = {
    follow_files = false,
  },
  auto_attach = true,
  attach_to_untracked = false,
  current_line_blame = false,
  current_line_blame_opts = {
    virt_text = true,
    virt_text_pos = "eol",
    delay = 1000,
    ignore_whitespace = true,
    virt_text_priority = 100,
  },
  current_line_blame_formatter = "<author> • <author_time:%Y-%m-%d> • <summary>",
  sign_priority = 6,
  update_debounce = 100,
  status_formatter = function(status)
    local added = status.added and ("+" .. status.added) or ""
    local changed = status.changed and ("~" .. status.changed) or ""
    local removed = status.removed and ("-" .. status.removed) or ""
    return added .. " " .. changed .. " " .. removed
  end,
  max_file_length = 40000,
  preview_config = {
    border = "single",
    style = "minimal",
    relative = "cursor",
    row = 0,
    col = 1,
  },
})
