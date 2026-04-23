vim.cmd.highlight 'clear'

if vim.fn.exists 'syntax_on' then
  vim.cmd.syntax 'reset'
end

vim.g.colors_name = 'kami-dark'
vim.o.background = 'dark'

local p = {
  ink = '#1a1a17',
  ink_soft = '#21211d',
  warm_sand = '#2a2925',
  brand = '#7ba7d9',
  brand_light = '#a3c4e8',
  near_white = '#ebe8dc',
  fg_warm = '#d6d2c2',
  charcoal = '#b8b5a8',
  olive = '#9a978c',
  stone = '#7a7770',
  border_dim = '#3a3833',
  border_warm = '#302e29',
  border_soft = '#262521',
  ring_warm = '#4a4842',
  tag = '#2c3a4d',
  tag_deep = '#3d5273',
  error = '#e07070',
  focus = '#5fb0ff',
  green = '#a4b87a',
  amber = '#d4a55c',
  comment_fg = '#ffb347',
  comment_bg = '#3a2a14',
}

local transparent = vim.g.kami_transparent
if transparent == nil then
  transparent = true
end

local bg_main = transparent and 'NONE' or p.ink

local function hi(group, spec)
  vim.api.nvim_set_hl(0, group, spec)
end

hi('Normal', { fg = p.near_white, bg = bg_main })
hi('NormalNC', { fg = p.fg_warm, bg = bg_main })
hi('NormalFloat', { fg = p.near_white, bg = bg_main })
hi('FloatBorder', { fg = p.border_dim, bg = bg_main })
hi('FloatTitle', { fg = p.brand, bg = bg_main })
hi('SignColumn', { fg = p.stone, bg = bg_main })
hi('EndOfBuffer', { fg = p.border_warm, bg = bg_main })
hi('FoldColumn', { fg = p.stone, bg = bg_main })
hi('Folded', { fg = p.olive, bg = p.warm_sand })
hi('ColorColumn', { bg = p.ink_soft })
hi('CursorLine', { bg = p.warm_sand })
hi('CursorColumn', { bg = p.warm_sand })
hi('LineNr', { fg = p.stone, bg = bg_main })
hi('CursorLineNr', { fg = p.brand, bg = p.warm_sand, bold = true })
hi('Cursor', { fg = p.ink, bg = p.brand })
hi('lCursor', { fg = p.ink, bg = p.brand })
hi('Visual', { bg = p.tag_deep })
hi('VisualNOS', { bg = p.tag })
hi('Search', { fg = p.near_white, bg = p.tag_deep })
hi('IncSearch', { fg = p.ink, bg = p.brand })
hi('CurSearch', { fg = p.ink, bg = p.brand })
hi('MatchParen', { fg = p.brand, underline = true })
hi('NonText', { fg = p.ring_warm })
hi('Whitespace', { fg = p.border_dim })
hi('SpecialKey', { fg = p.stone })
hi('Directory', { fg = p.brand })
hi('Title', { fg = p.brand })
hi('Question', { fg = p.brand })
hi('MoreMsg', { fg = p.brand })
hi('ModeMsg', { fg = p.olive })
hi('WarningMsg', { fg = p.amber })
hi('ErrorMsg', { fg = p.error })

hi('StatusLine', { fg = p.fg_warm, bg = p.warm_sand })
hi('StatusLineNC', { fg = p.stone, bg = p.border_warm })
hi('WinBar', { fg = p.fg_warm, bg = bg_main })
hi('WinBarNC', { fg = p.stone, bg = bg_main })
hi('WinSeparator', { fg = p.border_dim, bg = bg_main })
hi('TabLine', { fg = p.olive, bg = p.warm_sand })
hi('TabLineFill', { fg = p.stone, bg = p.border_warm })
hi('TabLineSel', { fg = p.brand, bg = p.ink_soft, bold = true })
hi('Pmenu', { fg = p.fg_warm, bg = bg_main })
hi('PmenuSel', { fg = p.ink, bg = p.brand })
hi('PmenuSbar', { bg = p.border_warm })
hi('PmenuThumb', { bg = p.ring_warm })
hi('WildMenu', { fg = p.ink, bg = p.brand })

hi('Comment', { fg = p.comment_fg, bg = p.comment_bg, bold = true, italic = true })
hi('Constant', { fg = p.brand })
hi('String', { fg = p.green })
hi('Character', { fg = p.green })
hi('Number', { fg = p.brand_light })
hi('Boolean', { fg = p.brand_light })
hi('Float', { fg = p.brand_light })
hi('Identifier', { fg = p.near_white })
hi('Function', { fg = p.brand })
hi('Statement', { fg = p.fg_warm, bold = true })
hi('Conditional', { fg = p.fg_warm, bold = true })
hi('Repeat', { fg = p.fg_warm, bold = true })
hi('Label', { fg = p.brand })
hi('Operator', { fg = p.charcoal })
hi('Keyword', { fg = p.fg_warm, bold = true })
hi('Exception', { fg = p.error })
hi('PreProc', { fg = p.brand_light })
hi('Include', { fg = p.brand_light })
hi('Define', { fg = p.brand_light })
hi('Macro', { fg = p.brand_light })
hi('PreCondit', { fg = p.brand_light })
hi('Type', { fg = p.brand })
hi('StorageClass', { fg = p.fg_warm, bold = true })
hi('Structure', { fg = p.brand })
hi('Typedef', { fg = p.brand })
hi('Special', { fg = p.amber })
hi('SpecialChar', { fg = p.amber })
hi('Tag', { fg = p.brand })
hi('Delimiter', { fg = p.stone })
hi('SpecialComment', { fg = p.olive, bold = true })
hi('Debug', { fg = p.error })
hi('Underlined', { fg = p.brand, underline = true })
hi('Ignore', { fg = p.stone })
hi('Error', { fg = p.error })
hi('Todo', { fg = p.brand, bg = p.tag, bold = true })

hi('DiffAdd', { fg = p.green, bg = '#2a3320' })
hi('DiffChange', { fg = p.amber, bg = '#332a1c' })
hi('DiffDelete', { fg = p.error, bg = '#33201e' })
hi('DiffText', { fg = p.near_white, bg = '#4a3a1f' })
hi('Added', { fg = p.green })
hi('Changed', { fg = p.amber })
hi('Removed', { fg = p.error })

hi('DiagnosticError', { fg = p.error })
hi('DiagnosticWarn', { fg = p.amber })
hi('DiagnosticInfo', { fg = p.brand_light })
hi('DiagnosticHint', { fg = p.olive })
hi('DiagnosticOk', { fg = p.green })
hi('DiagnosticUnderlineError', { sp = p.error, undercurl = true })
hi('DiagnosticUnderlineWarn', { sp = p.amber, undercurl = true })
hi('DiagnosticUnderlineInfo', { sp = p.brand_light, undercurl = true })
hi('DiagnosticUnderlineHint', { sp = p.olive, undercurl = true })
hi('DiagnosticVirtualTextError', { fg = p.error, bg = '#33201e' })
hi('DiagnosticVirtualTextWarn', { fg = p.amber, bg = '#332a1c' })
hi('DiagnosticVirtualTextInfo', { fg = p.brand_light, bg = p.tag })
hi('DiagnosticVirtualTextHint', { fg = p.olive, bg = p.ink_soft })

hi('@variable', { fg = p.near_white })
hi('@variable.builtin', { fg = p.fg_warm })
hi('@constant', { fg = p.brand })
hi('@constant.builtin', { fg = p.brand_light })
hi('@module', { fg = p.brand })
hi('@string', { fg = p.green })
hi('@character', { fg = p.green })
hi('@number', { fg = p.brand_light })
hi('@boolean', { fg = p.brand_light })
hi('@function', { fg = p.brand })
hi('@function.builtin', { fg = p.brand_light })
hi('@constructor', { fg = p.brand })
hi('@keyword', { fg = p.fg_warm, bold = true })
hi('@keyword.function', { fg = p.fg_warm, bold = true })
hi('@keyword.return', { fg = p.fg_warm, bold = true })
hi('@operator', { fg = p.charcoal })
hi('@type', { fg = p.brand })
hi('@type.builtin', { fg = p.brand_light })
hi('@property', { fg = p.charcoal })
hi('@field', { fg = p.charcoal })
hi('@punctuation', { fg = p.stone })
hi('@punctuation.bracket', { fg = p.stone })
hi('@punctuation.delimiter', { fg = p.stone })
hi('@comment', { fg = p.comment_fg, bg = p.comment_bg, bold = true, italic = true })
hi('@tag', { fg = p.brand })
hi('@tag.attribute', { fg = p.brand_light })
hi('@tag.delimiter', { fg = p.stone })
hi('@markup.heading', { fg = p.brand, bold = true })
hi('@markup.link', { fg = p.brand, underline = true })
hi('@markup.raw', { fg = p.green })

hi('GitSignsAdd', { fg = p.green, bg = bg_main })
hi('GitSignsChange', { fg = p.amber, bg = bg_main })
hi('GitSignsDelete', { fg = p.error, bg = bg_main })
hi('MiniIndentscopeSymbol', { fg = p.ring_warm })
hi('SnacksPicker', { fg = p.fg_warm, bg = bg_main })
hi('SnacksPickerBorder', { fg = p.border_dim, bg = bg_main })
hi('SnacksPickerMatch', { fg = p.brand, bold = true })
