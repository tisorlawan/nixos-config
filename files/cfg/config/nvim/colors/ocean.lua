vim.cmd.highlight 'clear'

if vim.fn.exists 'syntax_on' then
  vim.cmd.syntax 'reset'
end

vim.g.colors_name = 'ocean'
vim.o.background = 'dark'

local p = {
  bg = '#3f45a4',
  bg_nc = '#393f92',
  surface = '#374087',
  surface_hi = '#343b82',
  visual = '#4d56bd',
  border = '#6675d9',
  fg = '#ffffff',
  dim = '#9aa9e8',
  muted = '#7486cf',
  faint = '#5f70bf',
  accent = '#ffe05f',
  accent_soft = '#d2d665',
  orange = '#f0a24b',
  purple = '#a48bc2',
  red = '#d7798b',
}

local function hi(group, spec)
  vim.api.nvim_set_hl(0, group, spec)
end

hi('Normal', { fg = p.fg, bg = p.bg })
hi('NormalNC', { fg = p.dim, bg = p.bg_nc })
hi('NormalFloat', { fg = p.fg, bg = p.surface })
hi('FloatBorder', { fg = p.border, bg = p.surface })
hi('FloatTitle', { fg = p.accent, bg = p.surface, bold = true })
hi('SignColumn', { fg = p.muted, bg = p.bg })
hi('EndOfBuffer', { fg = p.bg, bg = p.bg })
hi('FoldColumn', { fg = p.muted, bg = p.bg })
hi('Folded', { fg = p.dim, bg = p.surface })
hi('ColorColumn', { bg = p.surface })
hi('CursorLine', { bg = p.surface_hi })
hi('CursorColumn', { bg = p.surface_hi })
hi('LineNr', { fg = p.muted, bg = p.bg })
hi('CursorLineNr', { fg = p.accent, bg = p.surface_hi, bold = true })
hi('Cursor', { fg = p.bg, bg = p.accent })
hi('lCursor', { fg = p.bg, bg = p.accent })
hi('Visual', { bg = p.visual })
hi('VisualNOS', { bg = p.visual })
hi('Search', { fg = p.bg, bg = p.accent })
hi('IncSearch', { fg = p.bg, bg = p.fg, bold = true })
hi('CurSearch', { fg = p.bg, bg = p.fg, bold = true })
hi('MatchParen', { fg = p.accent, underline = true, bold = true })
hi('NonText', { fg = p.faint })
hi('Whitespace', { fg = p.faint })
hi('SpecialKey', { fg = p.muted })
hi('Directory', { fg = p.accent, bold = true })
hi('Title', { fg = p.muted, bold = true })
hi('Question', { fg = p.accent })
hi('MoreMsg', { fg = p.accent })
hi('ModeMsg', { fg = p.fg, bold = true })
hi('WarningMsg', { fg = p.orange, bold = true })
hi('ErrorMsg', { fg = p.fg, bg = p.red, bold = true })

hi('StatusLine', { fg = p.fg, bg = p.visual })
hi('StatusLineNC', { fg = p.dim, bg = p.surface })
hi('WinBar', { fg = p.fg, bg = p.bg })
hi('WinBarNC', { fg = p.dim, bg = p.bg_nc })
hi('WinSeparator', { fg = p.border, bg = p.bg })
hi('TabLine', { fg = p.dim, bg = p.surface })
hi('TabLineFill', { fg = p.muted, bg = p.surface_hi })
hi('TabLineSel', { fg = p.fg, bg = p.bg, bold = true })
hi('Pmenu', { fg = p.fg, bg = p.surface })
hi('PmenuSel', { fg = p.bg, bg = p.accent, bold = true })
hi('PmenuSbar', { bg = p.surface_hi })
hi('PmenuThumb', { bg = p.border })
hi('WildMenu', { fg = p.bg, bg = p.accent, bold = true })

hi('Comment', { fg = p.dim, bg = p.surface })
hi('Constant', { fg = p.fg })
hi('String', { fg = p.accent_soft })
hi('Character', { fg = p.accent_soft })
hi('Number', { fg = p.fg })
hi('Boolean', { fg = p.fg, bold = true })
hi('Float', { fg = p.fg })
hi('Identifier', { fg = p.fg })
hi('Function', { fg = p.accent, bold = true })
hi('Statement', { fg = p.fg, bold = true })
hi('Conditional', { fg = p.fg, bold = true })
hi('Repeat', { fg = p.fg, bold = true })
hi('Label', { fg = p.accent })
hi('Operator', { fg = p.dim })
hi('Keyword', { fg = p.fg, bold = true })
hi('Exception', { fg = p.red, bold = true })
hi('PreProc', { fg = p.dim })
hi('Include', { fg = p.dim, bold = true })
hi('Define', { fg = p.dim })
hi('Macro', { fg = p.dim })
hi('PreCondit', { fg = p.dim })
hi('Type', { fg = p.fg, bold = true })
hi('StorageClass', { fg = p.fg, bold = true })
hi('Structure', { fg = p.fg, bold = true })
hi('Typedef', { fg = p.fg, bold = true })
hi('Special', { fg = p.accent })
hi('SpecialChar', { fg = p.accent })
hi('Tag', { fg = p.accent, bold = true })
hi('Delimiter', { fg = p.dim })
hi('SpecialComment', { fg = p.dim, bg = p.surface, bold = true })
hi('Debug', { fg = p.red, bold = true })
hi('Underlined', { fg = p.accent, underline = true })
hi('Ignore', { fg = p.muted })
hi('Error', { fg = p.fg, bg = p.red, bold = true })
hi('Todo', { fg = p.accent, bg = p.surface, bold = true })

hi('DiffAdd', { fg = p.accent_soft, bg = p.surface })
hi('DiffChange', { fg = p.fg, bg = p.surface })
hi('DiffDelete', { fg = p.red, bg = p.surface })
hi('DiffText', { fg = p.fg, bg = p.visual, bold = true })
hi('Added', { fg = p.accent_soft })
hi('Changed', { fg = p.orange })
hi('Removed', { fg = p.red })

hi('DiagnosticError', { fg = p.red, bold = true })
hi('DiagnosticWarn', { fg = p.orange })
hi('DiagnosticInfo', { fg = p.dim })
hi('DiagnosticHint', { fg = p.muted })
hi('DiagnosticOk', { fg = p.accent_soft })
hi('DiagnosticUnderlineError', { sp = p.red, undercurl = true })
hi('DiagnosticUnderlineWarn', { sp = p.orange, undercurl = true })
hi('DiagnosticUnderlineInfo', { sp = p.dim, underline = true })
hi('DiagnosticUnderlineHint', { sp = p.muted, underline = true })
hi('DiagnosticVirtualTextError', { fg = p.red, bg = p.surface })
hi('DiagnosticVirtualTextWarn', { fg = p.orange, bg = p.surface })
hi('DiagnosticVirtualTextInfo', { fg = p.dim, bg = p.surface })
hi('DiagnosticVirtualTextHint', { fg = p.muted, bg = p.surface })

hi('@variable', { fg = p.fg })
hi('@variable.builtin', { fg = p.dim })
hi('@constant', { fg = p.fg })
hi('@constant.builtin', { fg = p.fg, bold = true })
hi('@module', { fg = p.fg, bold = true })
hi('@string', { fg = p.accent_soft })
hi('@character', { fg = p.accent_soft })
hi('@number', { fg = p.fg })
hi('@boolean', { fg = p.fg, bold = true })
hi('@function', { fg = p.accent, bold = true })
hi('@function.builtin', { fg = p.accent, bold = true })
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
hi('@comment', { fg = p.dim, bg = p.surface })
hi('@tag', { fg = p.accent, bold = true })
hi('@tag.attribute', { fg = p.fg })
hi('@tag.delimiter', { fg = p.dim })
hi('@markup.heading', { fg = p.muted, bold = true })
hi('@markup.link', { fg = p.accent, underline = true })
hi('@markup.raw', { fg = p.fg })

hi('GitSignsAdd', { fg = p.accent_soft, bg = p.bg })
hi('GitSignsChange', { fg = p.orange, bg = p.bg })
hi('GitSignsDelete', { fg = p.red, bg = p.bg })
hi('NeoTreeGitIgnored', { fg = p.dim })
hi('NeoTreeHiddenByName', { fg = p.dim })
hi('NeoTreeDotfile', { fg = p.dim })
hi('MiniIndentscopeSymbol', { fg = p.faint })
hi('SnacksPicker', { fg = p.fg, bg = p.surface })
hi('SnacksPickerBorder', { fg = p.border, bg = p.surface })
hi('SnacksPickerMatch', { fg = p.accent, bold = true })
