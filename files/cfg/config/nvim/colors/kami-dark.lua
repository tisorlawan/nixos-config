vim.cmd.highlight 'clear'

if vim.fn.exists 'syntax_on' then
  vim.cmd.syntax 'reset'
end

vim.g.colors_name = 'kami-dark'
vim.o.background = 'dark'

local p = {
  -- bg       = '#0d120a',
  bg = '#051005',
  fg = '#e0efe0',
  dim = '#a8c898',
  subtle = '#7fa86a',
  faint = '#6f9a50',
  surface = '#141f0e',
  border = '#2f501c',
  comment_bg = '#1f3a14',
  accent = '#4acc5a',
  sel = '#1f3012',
  sel_hi = '#2f4020',
}

local transparent = vim.g.kami_transparent
if transparent == nil then
  transparent = true
end

local bg_main = transparent and 'NONE' or p.bg
local bg_float = transparent and 'NONE' or p.surface

local function hi(group, spec)
  vim.api.nvim_set_hl(0, group, spec)
end

hi('Normal', { fg = p.fg, bg = bg_main })
hi('NormalNC', { fg = p.dim, bg = bg_main })
hi('NormalFloat', { fg = p.fg, bg = bg_float })
hi('FloatBorder', { fg = p.border, bg = bg_float })
hi('FloatTitle', { fg = p.fg, bg = bg_float, bold = true })
hi('SignColumn', { fg = p.dim, bg = bg_main })
hi('EndOfBuffer', { fg = p.bg, bg = bg_main })
hi('FoldColumn', { fg = p.dim, bg = bg_main })
hi('Folded', { fg = p.dim, bg = p.surface })
hi('ColorColumn', { bg = p.surface })
hi('CursorLine', { bg = p.surface })
hi('CursorColumn', { bg = p.surface })
hi('LineNr', { fg = p.subtle, bg = bg_main })
hi('CursorLineNr', { fg = p.fg, bg = p.surface, bold = true })
hi('Cursor', { fg = p.bg, bg = p.fg })
hi('lCursor', { fg = p.bg, bg = p.fg })
hi('Visual', { bg = p.sel })
hi('VisualNOS', { bg = p.sel })
hi('Search', { fg = p.fg, bg = p.sel_hi })
hi('IncSearch', { fg = p.bg, bg = p.fg, bold = true })
hi('CurSearch', { fg = p.bg, bg = p.fg, bold = true })
hi('MatchParen', { fg = p.accent, underline = true, bold = true })
hi('NonText', { fg = p.faint })
hi('Whitespace', { fg = p.faint })
hi('SpecialKey', { fg = p.subtle })
hi('Directory', { fg = p.accent, bold = true })
hi('Title', { fg = p.fg, bold = true })
hi('Question', { fg = p.accent })
hi('MoreMsg', { fg = p.accent })
hi('ModeMsg', { fg = p.fg, bold = true })
hi('WarningMsg', { fg = p.fg, bold = true })
hi('ErrorMsg', { fg = p.bg, bg = p.fg, bold = true })

hi('StatusLine', { fg = p.fg, bg = p.surface })
hi('StatusLineNC', { fg = p.dim, bg = p.border })
hi('WinBar', { fg = p.fg, bg = bg_main })
hi('WinBarNC', { fg = p.dim, bg = bg_main })
hi('WinSeparator', { fg = p.border, bg = bg_main })
hi('TabLine', { fg = p.fg, bg = p.surface })
hi('TabLineFill', { fg = p.subtle, bg = p.border })
hi('TabLineSel', { fg = p.fg, bg = p.bg, bold = true })
hi('Pmenu', { fg = p.fg, bg = bg_float })
hi('PmenuSel', { fg = p.bg, bg = p.fg, bold = true })
hi('PmenuSbar', { bg = p.border })
hi('PmenuThumb', { bg = p.dim })
hi('WildMenu', { fg = p.bg, bg = p.fg, bold = true })

hi('Comment', { fg = p.dim, bg = p.comment_bg })
hi('Constant', { fg = p.fg })
hi('String', { fg = p.accent })
hi('Character', { fg = p.accent })
hi('Number', { fg = p.fg })
hi('Boolean', { fg = p.fg, bold = true })
hi('Float', { fg = p.fg })
hi('Identifier', { fg = p.fg })
hi('Function', { fg = p.fg, bold = true })
hi('Statement', { fg = p.fg, bold = true })
hi('Conditional', { fg = p.fg, bold = true })
hi('Repeat', { fg = p.fg, bold = true })
hi('Label', { fg = p.fg })
hi('Operator', { fg = p.dim })
hi('Keyword', { fg = p.fg, bold = true })
hi('Exception', { fg = p.fg, bold = true })
hi('PreProc', { fg = p.fg })
hi('Include', { fg = p.fg, bold = true })
hi('Define', { fg = p.fg })
hi('Macro', { fg = p.fg })
hi('PreCondit', { fg = p.fg })
hi('Type', { fg = p.fg, bold = true })
hi('StorageClass', { fg = p.fg, bold = true })
hi('Structure', { fg = p.fg, bold = true })
hi('Typedef', { fg = p.fg, bold = true })
hi('Special', { fg = p.fg })
hi('SpecialChar', { fg = p.accent })
hi('Tag', { fg = p.fg, bold = true })
hi('Delimiter', { fg = p.dim })
hi('SpecialComment', { fg = p.dim, bg = p.comment_bg })
hi('Debug', { fg = p.fg, bold = true })
hi('Underlined', { fg = p.accent, underline = true })
hi('Ignore', { fg = p.subtle })
hi('Error', { fg = p.bg, bg = p.fg, bold = true })
hi('Todo', { fg = p.accent, bg = p.surface, bold = true })

hi('DiffAdd', { fg = p.accent, bg = p.surface })
hi('DiffChange', { fg = p.fg, bg = p.surface })
hi('DiffDelete', { fg = p.dim, bg = p.surface })
hi('DiffText', { fg = p.fg, bg = p.sel_hi, bold = true })
hi('Added', { fg = p.accent })
hi('Changed', { fg = p.fg })
hi('Removed', { fg = p.dim })

hi('DiagnosticError', { fg = p.fg, bold = true })
hi('DiagnosticWarn', { fg = p.fg })
hi('DiagnosticInfo', { fg = p.dim })
hi('DiagnosticHint', { fg = p.subtle })
hi('DiagnosticOk', { fg = p.accent })
hi('DiagnosticUnderlineError', { sp = p.fg, undercurl = true })
hi('DiagnosticUnderlineWarn', { sp = p.dim, underline = true })
hi('DiagnosticUnderlineInfo', { sp = p.subtle, underline = true })
hi('DiagnosticUnderlineHint', { sp = p.faint, underline = true })
hi('DiagnosticVirtualTextError', { fg = p.fg, bg = p.surface })
hi('DiagnosticVirtualTextWarn', { fg = p.dim, bg = p.surface })
hi('DiagnosticVirtualTextInfo', { fg = p.subtle, bg = p.surface })
hi('DiagnosticVirtualTextHint', { fg = p.faint, bg = p.surface })

hi('@variable', { fg = p.fg })
hi('@variable.builtin', { fg = p.fg })
hi('@constant', { fg = p.fg })
hi('@constant.builtin', { fg = p.fg, bold = true })
hi('@module', { fg = p.fg, bold = true })
hi('@string', { fg = p.accent })
hi('@character', { fg = p.accent })
hi('@number', { fg = p.fg })
hi('@boolean', { fg = p.fg, bold = true })
hi('@function', { fg = p.fg, bold = true })
hi('@function.builtin', { fg = p.fg, bold = true })
hi('@constructor', { fg = p.fg, bold = true })
hi('@keyword', { fg = p.fg, bold = true })
hi('@keyword.function', { fg = p.fg, bold = true })
hi('@keyword.return', { fg = p.fg, bold = true })
hi('@operator', { fg = p.dim })
hi('@type', { fg = p.fg, bold = true })
hi('@type.builtin', { fg = p.fg, bold = true })
hi('@property', { fg = p.fg })
hi('@field', { fg = p.fg })
hi('@punctuation', { fg = p.dim })
hi('@punctuation.bracket', { fg = p.dim })
hi('@punctuation.delimiter', { fg = p.dim })
hi('@comment', { fg = p.dim, bg = p.comment_bg })
hi('@tag', { fg = p.fg, bold = true })
hi('@tag.attribute', { fg = p.fg })
hi('@tag.delimiter', { fg = p.dim })
hi('@markup.heading', { fg = p.fg, bold = true })
hi('@markup.link', { fg = p.accent, underline = true })
hi('@markup.raw', { fg = p.accent })

hi('GitSignsAdd', { fg = p.accent, bg = bg_main })
hi('GitSignsChange', { fg = p.fg, bg = bg_main })
hi('GitSignsDelete', { fg = p.dim, bg = bg_main })
hi('MiniIndentscopeSymbol', { fg = p.faint })
hi('SnacksPicker', { fg = p.fg, bg = bg_float })
hi('SnacksPickerBorder', { fg = p.border, bg = bg_float })
hi('SnacksPickerMatch', { fg = p.accent, bold = true })
