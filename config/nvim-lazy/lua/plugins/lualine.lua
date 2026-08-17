return {
  "nvim-lualine/lualine.nvim",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  event = "VeryLazy",
  config = function()
    local colors = {
      bg       = '#202328',
      fg       = '#bbc2cf',
      yellow   = '#ECBE7B',
      cyan     = '#008080',
      darkblue = '#081633',
      green    = '#98be65',
      orange   = '#FF8800',
      violet   = '#a9a1e1',
      magenta  = '#c678dd',
      blue     = '#51afef',
      red      = '#ec5f67',
    }

    local mode_colors = {
      n  = colors.red,    i  = colors.green,  v  = colors.blue,
      V  = colors.blue,   ['\22'] = colors.blue,
      c  = colors.magenta, no = colors.red,
      s  = colors.orange, S  = colors.orange, ['\19'] = colors.orange,
      ic = colors.yellow, R  = colors.violet, Rv = colors.violet,
      cv = colors.red,    ce = colors.red,    r  = colors.cyan,
      rm = colors.cyan,   ['r?'] = colors.cyan,
      ['!'] = colors.red, t  = colors.red,
    }

    local mode_names = {
      n  = 'NORMAL',   i  = 'INSERT',   v  = 'VISUAL',
      V  = 'V-LINE',   ['\22'] = 'V-BLOCK',
      c  = 'COMMAND',  no = 'OP-PEND',
      s  = 'SELECT',   S  = 'S-LINE',   ['\19'] = 'S-BLOCK',
      ic = 'INS-CMP',  R  = 'REPLACE',  Rv = 'V-REPL',
      cv = 'EX',       ce = 'EX',       r  = 'PROMPT',
      rm = 'MORE',     ['r?'] = 'CONFIRM',
      ['!'] = 'SHELL', t  = 'TERMINAL',
    }

    local conditions = {
      buffer_not_empty = function()
        return vim.fn.empty(vim.fn.expand('%:t')) ~= 1
      end,
      hide_in_width = function()
        return vim.fn.winwidth(0) > 80
      end,
    }

    local config = {
      options = {
        component_separators = '',
        section_separators = '',
        theme = {
          normal   = { c = { fg = colors.fg, bg = colors.bg } },
          inactive = { c = { fg = colors.fg, bg = colors.bg } },
        },
      },
      sections = {
        lualine_a = {}, lualine_b = {}, lualine_y = {}, lualine_z = {},
        lualine_c = {}, lualine_x = {},
      },
      inactive_sections = {
        lualine_a = {}, lualine_b = {}, lualine_y = {}, lualine_z = {},
        lualine_c = {}, lualine_x = {},
      },
    }

    local function ins_left(component)
      table.insert(config.sections.lualine_c, component)
    end

    local function ins_right(component)
      table.insert(config.sections.lualine_x, component)
    end

    -- Left edge accent
    ins_left {
      function() return '▊' end,
      color = { fg = colors.blue },
      padding = { left = 0, right = 1 },
    }

    -- Mode text (colored per mode)
    ins_left {
      function()
        local mode = vim.fn.mode()
        return mode_names[mode] or mode:upper()
      end,
      color = function()
        return { fg = mode_colors[vim.fn.mode()] or colors.fg, gui = 'bold' }
      end,
      padding = { right = 1 },
    }

    -- Macro recording indicator
    ins_left {
      function()
        return '● @' .. vim.fn.reg_recording()
      end,
      color = { fg = colors.orange, gui = 'bold' },
      cond = function() return vim.fn.reg_recording() ~= '' end,
    }

    -- Filename
    ins_left {
      'filename',
      cond = conditions.buffer_not_empty,
      color = { fg = colors.magenta, gui = 'bold' },
    }

    ins_left { 'location' }

    ins_left { 'progress', color = { fg = colors.fg, gui = 'bold' } }

    -- Diagnostics
    ins_left {
      'diagnostics',
      sources = { 'nvim_diagnostic' },
      symbols = { error = ' ', warn = ' ', info = ' ' },
      diagnostics_color = {
        error = { fg = colors.red },
        warn  = { fg = colors.yellow },
        info  = { fg = colors.cyan },
      },
    }

    -- Spacer
    ins_left { function() return '%=' end }

    -- LSP clients attached to current buffer (excludes null-ls / copilot noise)
    ins_left {
      function()
        local clients = vim.lsp.get_clients({ bufnr = 0 })
        local names = {}
        for _, c in ipairs(clients) do
          if c.name ~= 'null-ls' and c.name ~= 'copilot' then
            table.insert(names, c.name)
          end
        end
        return table.concat(names, ', ')
      end,
      icon = ' LSP:',
      color = { fg = '#ffffff', gui = 'bold' },
      cond = function()
        local clients = vim.lsp.get_clients({ bufnr = 0 })
        for _, c in ipairs(clients) do
          if c.name ~= 'null-ls' and c.name ~= 'copilot' then
            return true
          end
        end
        return false
      end,
    }

    -- Branch
    ins_right {
      'branch',
      icon = '',
      color = { fg = colors.violet, gui = 'bold' },
    }

    -- Diff stats
    ins_right {
      'diff',
      symbols = { added = ' ', modified = '󰝤 ', removed = ' ' },
      diff_color = {
        added    = { fg = colors.green },
        modified = { fg = colors.orange },
        removed  = { fg = colors.red },
      },
      cond = conditions.hide_in_width,
    }

    -- Encoding — only shown when non-UTF-8
    ins_right {
      'o:encoding',
      fmt = string.upper,
      cond = function()
        return conditions.hide_in_width()
          and vim.opt.fileencoding:get() ~= 'utf-8'
      end,
      color = { fg = colors.green, gui = 'bold' },
    }

    -- Fileformat — only shown when non-unix
    ins_right {
      'fileformat',
      fmt = string.upper,
      icons_enabled = false,
      cond = function() return vim.bo.fileformat ~= 'unix' end,
      color = { fg = colors.green, gui = 'bold' },
    }

    -- Date / time
    ins_right {
      function() return os.date(' %a %b %d   %H:%M') end,
      color = { fg = colors.cyan, gui = 'bold' },
      cond = conditions.hide_in_width,
    }

    -- Right edge accent
    ins_right {
      function() return '▊' end,
      color = { fg = colors.blue },
      padding = { left = 1 },
    }

    require('lualine').setup(config)
  end,
}
