local function get_color_config()
  local raw = vim.env.COLOR or vim.env.LC_COLOR

  if not raw or raw == '' then
    local color_file = io.open(vim.fn.expand '~/.color', 'r')
    if color_file then
      raw = (color_file:read '*a' or '')
      color_file:close()
    end
  end

  raw = vim.trim(raw or '')

  local bg = raw:find 'light' and 'light' or 'dark'
  local mono = raw:find 'monochrome' ~= nil

  return bg, mono
end

local color_mode, is_monochrome = get_color_config()
vim.g.monochrome = is_monochrome

local plugins = {
  { 'EdenEast/nightfox.nvim' },
}

local dark_colors = { 'nightfox' }
local light_colors = { 'dayfox' }

local pool
if color_mode == 'light' then
  pool = light_colors
else
  pool = dark_colors
end
math.randomseed(os.time())
local chosen = pool[math.random(#pool)]

local function get_monochrome_palette(mode)
  local dark = mode ~= 'light'
  local bg = dark and 0x151715 or 0xf0f3f0
  local fg = dark and 0xeeeeee or 0x131313

  local function blend(c1, c2, t)
    local r1, g1, b1 = math.floor(c1 / 65536), math.floor(c1 / 256) % 256, c1 % 256
    local r2, g2, b2 = math.floor(c2 / 65536), math.floor(c2 / 256) % 256, c2 % 256
    return math.floor(r1 + (r2 - r1) * t) * 65536 + math.floor(g1 + (g2 - g1) * t) * 256 + math.floor(b1 + (b2 - b1) * t)
  end

  return {
    bg = bg,
    fg = fg,
    bg_alt = blend(bg, fg, dark and 0.08 or 0.04),
    bg_edge = blend(bg, fg, dark and 0.14 or 0.1),
    muted = blend(fg, bg, 0.55),
    subtle = blend(fg, bg, 0.3),
    faint = blend(fg, bg, 0.7),
    string = blend(dark and 0x97b67c or 0x5f7a49, fg, dark and 0.22 or 0.18),
    selection = blend(fg, bg, dark and 0.78 or 0.82),
    search = blend(fg, bg, dark and 0.7 or 0.74),
    search_current = blend(fg, bg, dark and 0.10 or 0.1),
  }
end

local function apply_monochrome()
  local p = get_monochrome_palette(color_mode)
  local fg = p.fg
  local bg = p.bg

  vim.o.background = color_mode
  vim.cmd 'highlight clear'
  vim.cmd 'syntax reset'
  vim.g.colors_name = 'monochrome'

  local hl = vim.api.nvim_set_hl
  local groups = {
    dim = {
      'Comment',
      'SpecialComment',
      '@comment',
      '@lsp.type.comment',
    },
    str = {
      'String',
      'Character',
      '@string',
      '@character',
      '@lsp.type.string',
    },
    bold = {
      'Function',
      'Statement',
      'Conditional',
      'Repeat',
      'Keyword',
      'Exception',
      'Include',
      'Type',
      'Structure',
      'Boolean',
      'Title',
      '@function',
      '@function.builtin',
      '@function.call',
      '@method',
      '@method.call',
      '@keyword',
      '@keyword.function',
      '@keyword.return',
      '@constant.builtin',
      '@type',
      '@type.builtin',
      '@tag',
      '@boolean',
      '@lsp.type.function',
      '@lsp.type.method',
      '@lsp.type.keyword',
      '@lsp.type.type',
      '@lsp.type.class',
      '@lsp.type.interface',
      '@lsp.type.enum',
      '@lsp.type.struct',
    },
    subtle = {
      'Delimiter',
      '@punctuation',
      '@punctuation.bracket',
      '@punctuation.delimiter',
      '@punctuation.special',
      '@tag.delimiter',
    },
    normal = {
      'Constant',
      'Number',
      'Float',
      'Identifier',
      'Label',
      'Operator',
      'PreProc',
      'Define',
      'Macro',
      'PreCondit',
      'StorageClass',
      'Typedef',
      'Special',
      'SpecialChar',
      'Tag',
      '@variable',
      '@constant',
      '@property',
      '@parameter',
      '@field',
      '@constructor',
      '@attribute',
      '@namespace',
      '@module',
      '@number',
      '@operator',
      '@string.escape',
      '@string.special',
      '@tag.attribute',
      '@keyword.operator',
      '@lsp.type.variable',
      '@lsp.type.parameter',
      '@lsp.type.property',
      '@lsp.type.enumMember',
      '@lsp.type.namespace',
      '@lsp.type.typeParameter',
      '@lsp.type.decorator',
      '@lsp.type.macro',
    },
  }

  hl(0, 'Normal', { fg = fg, bg = bg })
  hl(0, 'NormalNC', { fg = fg, bg = bg })
  hl(0, 'NormalFloat', { fg = fg, bg = p.bg_alt })
  hl(0, 'FloatBorder', { fg = p.muted, bg = p.bg_alt })
  hl(0, 'FloatTitle', { fg = fg, bg = p.bg_alt, bold = true })
  hl(0, 'ColorColumn', { bg = p.bg_alt })
  hl(0, 'CursorColumn', { bg = p.bg_alt })
  hl(0, 'CursorLine', { bg = p.bg_alt })
  hl(0, 'CursorLineFold', { fg = p.muted, bg = p.bg_alt })
  hl(0, 'CursorLineSign', { fg = p.muted, bg = p.bg_alt })
  hl(0, 'FoldColumn', { fg = p.muted, bg = bg })
  hl(0, 'Folded', { fg = p.muted, bg = p.bg_alt })
  hl(0, 'StatusLine', { fg = fg, bg = p.bg_edge })
  hl(0, 'StatusLineNC', { fg = p.muted, bg = p.bg_alt })
  hl(0, 'StatusLineTerm', { fg = fg, bg = p.bg_edge })
  hl(0, 'StatusLineTermNC', { fg = p.muted, bg = p.bg_alt })
  hl(0, 'TabLine', { fg = p.muted, bg = p.bg_alt })
  hl(0, 'TabLineFill', { bg = p.bg_alt })
  hl(0, 'TabLineSel', { fg = fg, bg = p.bg_edge, bold = true })
  hl(0, 'WinBar', { fg = p.muted, bg = bg })
  hl(0, 'WinBarNC', { fg = p.faint, bg = bg })
  hl(0, 'VertSplit', { fg = p.bg_edge, bg = bg })
  hl(0, 'WinSeparator', { fg = p.bg_edge, bg = bg })
  hl(0, 'Pmenu', { fg = fg, bg = p.bg_alt })
  hl(0, 'PmenuSel', { fg = bg, bg = fg, bold = true })
  hl(0, 'PmenuSbar', { bg = p.bg_edge })
  hl(0, 'PmenuThumb', { bg = p.muted })
  hl(0, 'Visual', { bg = p.selection })
  hl(0, 'Search', { fg = fg, bg = p.search, underline = false })
  hl(0, 'IncSearch', { fg = bg, bg = p.search_current, bold = true, underline = false })
  hl(0, 'CurSearch', { fg = bg, bg = p.search_current, bold = true, underline = true })
  hl(0, 'Substitute', { fg = bg, bg = fg, bold = true })
  hl(0, 'MatchParen', { fg = fg, bg = p.bg_edge, bold = true, underline = true })
  hl(0, 'DiagnosticError', { fg = fg, bold = true })
  hl(0, 'DiagnosticWarn', { fg = fg })
  hl(0, 'DiagnosticInfo', { fg = p.muted })
  hl(0, 'DiagnosticHint', { fg = p.subtle })
  hl(0, 'DiagnosticOk', { fg = fg })
  hl(0, 'DiagnosticUnderlineError', { undercurl = true, sp = fg })
  hl(0, 'DiagnosticUnderlineWarn', { underline = true, sp = p.muted })
  hl(0, 'DiagnosticUnderlineInfo', { underline = true, sp = p.subtle })
  hl(0, 'DiagnosticUnderlineHint', { underline = true, sp = p.faint })
  hl(0, 'DiffAdd', { fg = fg, bg = p.bg_alt })
  hl(0, 'DiffChange', { fg = fg, bg = p.bg_edge })
  hl(0, 'DiffDelete', { fg = p.muted, bg = bg })
  hl(0, 'DiffText', { fg = bg, bg = fg, bold = true })
  hl(0, 'ErrorMsg', { fg = bg, bg = fg, bold = true })
  hl(0, 'WarningMsg', { fg = fg, bold = true })
  hl(0, 'ModeMsg', { fg = fg, bold = true })
  hl(0, 'MoreMsg', { fg = fg, bold = true })
  hl(0, 'Question', { fg = fg, bold = true })
  hl(0, 'MsgArea', { fg = fg, bg = bg })
  hl(0, 'MsgSeparator', { fg = p.bg_edge, bg = bg })
  hl(0, 'Todo', { fg = bg, bg = fg, bold = true })
  hl(0, 'QuickFixLine', { bg = p.bg_edge, bold = true })
  hl(0, 'Sneak', { fg = bg, bg = fg, bold = true })
  hl(0, 'MiniCursorword', { underline = true })
  hl(0, 'MiniCursorwordCurrent', { underline = true })

  for _, name in ipairs(groups.dim) do
    hl(0, name, { fg = p.muted, italic = true })
  end
  for _, name in ipairs(groups.str) do
    hl(0, name, { fg = p.string })
  end
  for _, name in ipairs(groups.bold) do
    hl(0, name, { fg = fg, bold = true })
  end
  for _, name in ipairs(groups.subtle) do
    hl(0, name, { fg = p.subtle })
  end
  for _, name in ipairs(groups.normal) do
    hl(0, name, { fg = fg })
  end

  -- UI elements
  hl(0, 'LineNr', { fg = p.muted })
  hl(0, 'CursorLineNr', { fg = fg, bold = true })
  hl(0, 'SignColumn', { fg = p.muted, bg = bg })
  hl(0, 'NonText', { fg = p.faint })
  hl(0, 'SpecialKey', { fg = p.faint })
  hl(0, 'Underlined', { fg = fg, underline = true })
  hl(0, 'Directory', { fg = fg, bold = true })
  hl(0, 'Whitespace', { fg = p.faint })
  hl(0, 'Conceal', { fg = p.muted, bg = bg })
  hl(0, 'EndOfBuffer', { fg = bg, bg = bg })

  vim.g.terminal_color_0 = string.format('#%06x', bg)
  vim.g.terminal_color_1 = string.format('#%06x', p.muted)
  vim.g.terminal_color_2 = string.format('#%06x', p.subtle)
  vim.g.terminal_color_3 = string.format('#%06x', p.muted)
  vim.g.terminal_color_4 = string.format('#%06x', fg)
  vim.g.terminal_color_5 = string.format('#%06x', fg)
  vim.g.terminal_color_6 = string.format('#%06x', p.subtle)
  vim.g.terminal_color_7 = string.format('#%06x', fg)
  vim.g.terminal_color_8 = string.format('#%06x', p.bg_edge)
  vim.g.terminal_color_9 = string.format('#%06x', fg)
  vim.g.terminal_color_10 = string.format('#%06x', fg)
  vim.g.terminal_color_11 = string.format('#%06x', p.muted)
  vim.g.terminal_color_12 = string.format('#%06x', fg)
  vim.g.terminal_color_13 = string.format('#%06x', fg)
  vim.g.terminal_color_14 = string.format('#%06x', p.subtle)
  vim.g.terminal_color_15 = string.format('#%06x', fg)
end

local function activate_colors()
  if vim.g.monochrome then
    apply_monochrome()
    vim.cmd 'redraw!'
  else
    vim.cmd.colorscheme(chosen)
  end
end

if vim.g.monochrome then
  vim.o.background = color_mode
  vim.api.nvim_create_autocmd({ 'VimEnter', 'User' }, {
    pattern = { 'VimEnter', 'LazyDone' },
    callback = function()
      vim.schedule(activate_colors)
    end,
  })
else
  vim.api.nvim_create_autocmd('User', {
    pattern = 'LazyDone',
    once = true,
    callback = function()
      vim.schedule(activate_colors)
    end,
  })
end

return plugins
