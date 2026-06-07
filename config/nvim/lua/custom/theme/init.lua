------------------------------------------
--- Color Scheme
------------------------------------------
local p = require 'custom.theme.lftm-pallete'
local M = {}

local function hl(group, opts)
  vim.api.nvim_set_hl(0, group, opts)
end

function M.apply()
  vim.o.termguicolors = true
  vim.g.colors_name = 'custom-theme'
  local none = 'NONE'

  hl('Normal', { fg = p.fg, bg = none })
  hl('NormalNC', { fg = p.fg, bg = none })
  hl('NormalFloat', { fg = p.fg, bg = none })
  hl('FloatBorder', { fg = p.border, bg = none })
  hl('WinSeparator', { fg = p.border })

  hl('Comment', { fg = p.fg_dim, italic = true })
  hl('LineNr', { fg = p.fg_dark })
  hl('CursorLineNr', { fg = p.accent })
  hl('EndOfBuffer', { fg = p.fg_soft })
  hl('NonText', { fg = p.fg_soft })

  hl('CursorLine', { bg = p.bg_alt })
  hl('Visual', { bg = p.bg_alt })
  hl('SignColumn', { bg = none })

  -- UI elements
  hl('StatusLine', { fg = p.fg, bg = none })
  hl('StatusLineNC', { fg = p.fg_dark, bg = none })
  hl('TabLine', { fg = p.fg_soft, bg = none })
  hl('TabLineSel', { fg = p.accent, bg = p.bg_accent })
  hl('TabLineFill', { bg = none })

  hl('VertSplit', { fg = p.border })

  -- Search
  hl('Search', { fg = p.bg, bg = p.accent })
  hl('IncSearch', { fg = p.bg, bg = p.orange })

  -- Diagnostics
  hl('DiagnosticError', { fg = p.error })
  hl('DiagnosticWarn', { fg = p.warn })
  hl('DiagnosticInfo', { fg = p.info })
  hl('DiagnosticHint', { fg = p.hint })

  hl('DiagnosticVirtualTextError', { fg = p.error })
  hl('DiagnosticVirtualTextWarn', { fg = p.warn })
  hl('DiagnosticVirtualTextInfo', { fg = p.info })
  hl('DiagnosticVirtualTextHint', { fg = p.hint })

  hl('DiagnosticUnderlineError', { undercurl = true, sp = p.error })
  hl('DiagnosticUnderlineWarn', { undercurl = true, sp = p.warn })

  -- Syntax highlights
  hl('Keyword', { fg = p.keyword })
  hl('Conditional', { fg = p.keyword })
  hl('Repeat', { fg = p.keyword })

  hl('Function', { fg = p.func })
  hl('Identifier', { fg = p.fg })

  hl('String', { fg = p.string })
  hl('Character', { fg = p.string })

  hl('Number', { fg = p.number })
  hl('Boolean', { fg = p.number })

  hl('Type', { fg = p.type })
  hl('Constant', { fg = p.constant })

  hl('Operator', { fg = p.operator })

  -- Popup menu
  hl('Pmenu', { fg = p.fg, bg = p.bg_alt })
  hl('PmenuSel', { fg = p.bg, bg = p.accent })
end

return M
