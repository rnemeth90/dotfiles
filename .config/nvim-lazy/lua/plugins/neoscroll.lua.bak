return {
  "karb94/neoscroll.nvim",
  event = "WinScrolled",
  config = function()
    require("neoscroll").setup({
      mappings = {},                -- No default mappings
      hide_cursor = true,           -- Hide cursor while scrolling
      stop_eof = true,              -- Stop at EOF
      respect_scrolloff = false,    -- Ignore scrolloff margin
      cursor_scrolls_alone = true,  -- Cursor keeps scrolling even if window can't
      easing_function = nil,
      pre_hook = nil,
      post_hook = nil,
      performance_mode = false,
    })
  end,
}
