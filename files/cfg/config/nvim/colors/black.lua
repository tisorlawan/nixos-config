local o = vim.o
local g = vim.g
local api = vim.api

vim.cmd 'hi clear'

if g.syntax_on == 1 then
  vim.cmd 'syntax reset'
end

o.background = 'dark'
g.colors_name = 'black'

local background = '#18202a'
local surface = '#202936'
local surface_light = '#2a3544'
local selection = '#303040'
local comment_bg = '#404070'
local foreground = '#d4dae3'
local muted = '#8f99a8'
local dim = '#667080'
local border = '#3a4656'
local black = '#000000'
local white = '#ffffff'
local blue = '#8aa0c2'
local green = '#9ab18f'
local red = '#c98f86'
local yellow = '#c0aa78'
local orange = '#c79a72'
local purple = '#a99abe'
local cyan = '#8fb7b3'
local transparent = vim.g.transparent
if transparent == nil then
  transparent = true
end

local bg_main = transparent and 'NONE' or background
local bg_surface = transparent and 'NONE' or surface
local bg_surface_light = transparent and 'NONE' or surface_light

g.terminal_color_0 = black
g.terminal_color_1 = red
g.terminal_color_2 = green
g.terminal_color_3 = yellow
g.terminal_color_4 = blue
g.terminal_color_5 = purple
g.terminal_color_6 = cyan
g.terminal_color_7 = foreground
g.terminal_color_8 = dim
g.terminal_color_9 = red
g.terminal_color_10 = green
g.terminal_color_11 = yellow
g.terminal_color_12 = blue
g.terminal_color_13 = purple
g.terminal_color_14 = cyan
g.terminal_color_15 = white

local highlights = {
  Disabled = {},

  BlackOnLightYellow = { fg = black, bg = yellow },
  LightRedBackground = { bg = '#3a1815' },
  WhiteOnBlue = { fg = black, bg = blue },
  WhiteOnOrange = { fg = black, bg = orange },
  WhiteOnRed = { fg = black, bg = red },
  WhiteOnYellow = { fg = black, bg = yellow },
  Yellow = { fg = yellow, bold = true },
  Bold = { fg = foreground, bold = true },

  Normal = { fg = foreground, bg = bg_main },
  NormalFloat = { fg = foreground, bg = bg_surface },
  FloatTitle = { fg = foreground, bg = bg_surface, bold = true },
  FloatBorder = { fg = border, bg = bg_surface },
  ColorColumn = { bg = bg_surface },
  Conceal = { fg = muted },
  Cursor = { fg = background, bg = foreground },
  CursorLine = { bg = bg_surface },
  CursorLineNr = { fg = foreground, bold = true },
  Directory = { fg = purple, bold = true },
  EndOfBuffer = { fg = background, bg = bg_main },
  ErrorMsg = { fg = red, bold = true },
  FoldColumn = { fg = muted, bg = bg_main },
  Folded = { fg = muted, bg = bg_surface },
  LineNr = { fg = dim },
  MatchParen = { fg = black, bg = yellow, bold = true },
  MsgSeparator = { fg = border },
  NonText = { fg = dim },
  Pmenu = { fg = foreground, bg = bg_surface_light },
  PmenuSbar = { bg = bg_surface_light },
  PmenuSel = { fg = white, bg = selection, bold = true },
  PmenuThumb = { bg = border },
  PmenuMatch = { fg = yellow, bold = true },
  QuickFixLine = { bg = selection, bold = true },
  Search = { fg = black, bg = yellow },
  CurSearch = { link = 'Search' },
  IncSearch = { link = 'Search' },
  SignColumn = { fg = muted, bg = bg_main },
  StatusLine = { fg = foreground, bg = bg_surface },
  StatusLineNC = { fg = muted, bg = bg_surface },
  StatusLineTab = { fg = foreground, bg = bg_main, bold = true },
  TabLine = { fg = muted, bg = bg_surface_light },
  TabLineFill = { fg = muted, bg = bg_surface_light },
  TabLineSel = { fg = foreground, bg = bg_main, bold = true },
  Title = { fg = foreground, bold = true },
  Todo = { fg = yellow, bg = bg_surface, bold = true },
  VertSplit = { fg = border },
  Visual = { bg = selection },
  WarningMsg = { fg = yellow, bold = true },
  Whitespace = { fg = border },
  WildMenu = { link = 'PmenuSel' },
  WinBar = { fg = foreground, bold = true },
  WinBarNc = { fg = muted, bold = true },
  WinBarFill = { fg = border },
  WinSeparator = { fg = border },

  Comment = { fg = muted },
  Constant = { fg = foreground },
  String = { fg = green },
  Character = { link = 'String' },
  Number = { fg = blue },
  Boolean = { fg = foreground, bold = true },
  Identifier = { fg = foreground },
  Function = { fg = foreground, bold = true },
  Statement = { fg = foreground, bold = true },
  Keyword = { fg = foreground, bold = true },
  Include = { fg = foreground, bold = true },
  PreProc = { fg = foreground },
  Type = { fg = foreground, bold = true },
  Special = { fg = foreground },
  SpecialKey = { fg = blue },
  Operator = { fg = muted },
  Label = { link = 'Keyword' },
  Macro = { fg = orange },
  Regexp = { fg = orange },
  Symbol = { fg = orange },
  Underlined = { fg = blue, underline = true },

  DiffAdd = { bg = '#163018' },
  DiffChange = { bg = bg_surface_light },
  DiffDelete = { fg = red },
  DiffText = { bg = '#3a300f' },
  diffAdded = { link = 'DiffAdd' },
  diffChanged = { link = 'DiffChange' },
  diffFile = { fg = foreground, bold = true },
  diffLine = { fg = blue },
  diffRemoved = { link = 'DiffDelete' },

  GitSignsAdd = { fg = green },
  GitSignsDelete = { fg = red },
  GitSignsChange = { fg = yellow },
  GitSignsStagedAdd = { fg = muted },
  GitSignsStagedDelete = { fg = muted },
  GitSignsStagedChange = { fg = muted },

  DiagnosticUnderlineError = { underline = true, sp = red },
  DiagnosticUnderlineWarn = { underline = true, sp = yellow },
  DiagnosticFloatingError = { fg = red, bold = true },
  DiagnosticFloatingHint = { fg = muted, bold = true },
  DiagnosticFloatingInfo = { fg = blue, bold = true },
  DiagnosticFloatingWarn = { fg = yellow, bold = true },
  DiagnosticError = { fg = red, bold = true },
  DiagnosticHint = { fg = muted, bold = true },
  DiagnosticInfo = { fg = blue, bold = true },
  DiagnosticWarn = { fg = yellow, bold = true },
  DiagnosticDeprecated = {},

  MiniDiffSignAdd = { fg = green },
  MiniDiffSignDelete = { fg = red },
  MiniDiffSignChange = { fg = yellow },
  MiniIconsAzure = { fg = blue },
  MiniIconsBlue = { fg = blue },
  MiniIconsCyan = { fg = cyan },
  MiniIconsGreen = { fg = green },
  MiniIconsGrey = { fg = muted },
  MiniIconsOrange = { fg = orange },
  MiniIconsPurple = { fg = purple },
  MiniIconsRed = { fg = red },
  MiniIconsYellow = { fg = yellow },
  MiniPickBorder = { fg = border, bg = bg_surface },
  MiniPickBorderBusy = { link = 'MiniPickBorder' },
  MiniPickBorderText = { fg = muted, bg = bg_surface },
  MiniPickHeader = { fg = foreground, bold = true },
  MiniPickMatchCurrent = { bg = selection, bold = true },
  MiniPickMatchRanges = { fg = yellow, bold = true },
  MiniPickNormal = { fg = foreground, bg = bg_surface },
  MiniPickPrompt = { fg = foreground, bg = bg_surface, bold = true },
  MiniPickMatchMarked = { bold = true },

  NeoTreeNormal = { fg = foreground, bg = bg_main },
  NeoTreeNormalNC = { fg = foreground, bg = bg_main },
  NeoTreeCursorLine = { bg = bg_surface_light, bold = true },
  NeoTreeDirectoryIcon = { fg = purple, bold = true },
  NeoTreeDirectoryName = { fg = purple, bold = true },
  NeoTreeFileName = { fg = foreground },
  NeoTreeFileIcon = { fg = blue },
  NeoTreeIndentMarker = { fg = border },
  NeoTreeExpander = { fg = muted },
  NeoTreeRootName = { fg = foreground, bold = true, italic = true },
  NeoTreeDotfile = { fg = muted },
  NeoTreeHiddenByName = { fg = muted },
  NeoTreeGitIgnored = { fg = muted },
  NeoTreeIgnored = { fg = muted },
  NeoTreeGitAdded = { fg = green, bold = true },
  NeoTreeGitModified = { fg = yellow, bold = true },
  NeoTreeGitDeleted = { fg = red, bold = true },
  NeoTreeGitConflict = { fg = orange, bold = true },
  NeoTreeGitRenamed = { fg = purple, bold = true },
  NeoTreeGitStaged = { fg = green, bold = true },
  NeoTreeGitUnstaged = { fg = yellow, bold = true },
  NeoTreeGitUntracked = { fg = blue, bold = true },
  NeoTreeFloatBorder = { link = 'FloatBorder' },
  NeoTreeFloatNormal = { link = 'NormalFloat' },

  NeogitBranch = { fg = green, bold = true },
  NeogitFilePath = { fg = purple },
  NeogitHunkHeader = { fg = blue },
  NeogitDiffAdd = { link = 'DiffAdd' },
  NeogitDiffDelete = { link = 'DiffDelete' },
  NeogitDiffContext = { link = 'Normal' },
  NeogitDiffHeader = { fg = foreground, bold = true },

  SnacksPicker = { fg = foreground, bg = bg_surface },
  SnacksPickerBorder = { fg = border, bg = bg_surface },
  SnacksPickerMatch = { fg = yellow, bold = true },
  SnacksPickerDir = { fg = muted },
  SnacksPickerPrompt = { fg = foreground, bg = bg_surface, bold = true },
  SnacksInputBorder = { link = 'FloatBorder' },
  SnacksInputTitle = { link = 'Title' },
  SnacksPickerRow = { link = 'Number' },
  SnacksPickerCol = { link = 'Number' },
  SnacksPickerListCursorLine = { bg = selection, bold = true },

  TelescopeBorder = { fg = border, bg = bg_surface },
  TelescopeMatching = { fg = yellow, bold = true },
  TelescopePromptNormal = { fg = foreground, bg = bg_surface },
  TelescopePromptBorder = { fg = border, bg = bg_surface },
  TelescopePromptPrefix = { fg = foreground, bold = true },
  TelescopeSelection = { bg = selection, bold = true },
  TelescopeTitle = { fg = foreground, bold = true },
  TelescopeNormal = { fg = foreground, bg = bg_surface },

  FFFBorder = { fg = border, bg = bg_surface },
  FFFTitle = { fg = foreground, bg = bg_surface, bold = true },
  FFFGitStaged = { fg = green, bold = true },
  FFFGitModified = { fg = yellow, bold = true },
  FFFGitDeleted = { fg = red, bold = true },
  FFFGitRenamed = { fg = purple, bold = true },
  FFFGitUntracked = { fg = blue, bold = true },
  FFFGitIgnored = { fg = muted },
  FFFGitSignStaged = { fg = green },
  FFFGitSignModified = { fg = yellow },
  FFFGitSignDeleted = { fg = red },
  FFFGitSignRenamed = { fg = purple },
  FFFGitSignUntracked = { fg = blue },
  FFFGitSignIgnored = { fg = muted },
  FFFSelected = { bg = selection },
  FFFSelectedActive = { bg = selection, bold = true },
  FFFFileInfoSection = { fg = foreground, bold = true },
  FFFFileInfoSeparator = { fg = border },
  FFFFileInfoLabel = { fg = muted },
  FFFFileInfoValue = { fg = foreground },
  FFFFileInfoValueDim = { fg = dim },
  FFFFileInfoSize = { fg = blue },
  FFFFileInfoType = { fg = purple },
  FFFFileInfoPath = { fg = muted },
  FFFFileInfoTotalScore = { fg = yellow, bold = true },
  FFFFileInfoMatchType = { fg = cyan, bold = true },
  FFFFileInfoScorePos = { fg = green },
  FFFFileInfoScoreNeg = { fg = red },

  NotifyDEBUGBorder = { fg = border },
  NotifyDEBUGIcon = { fg = muted },
  NotifyDEBUGTitle = { fg = muted },
  NotifyERRORBorder = { fg = border },
  NotifyERRORIcon = { fg = red },
  NotifyERRORTitle = { fg = red },
  NotifyINFOBorder = { fg = border },
  NotifyINFOIcon = { fg = green },
  NotifyINFOTitle = { fg = green },
  NotifyTRACEBorder = { fg = border },
  NotifyTRACEIcon = { fg = purple },
  NotifyTRACETitle = { fg = purple },
  NotifyWARNBorder = { fg = border },
  NotifyWARNIcon = { fg = orange },
  NotifyWARNTitle = { fg = orange },

  pythonComment = { fg = foreground, bg = comment_bg, bold = true },
  rustCommentBlock = { fg = foreground, bg = comment_bg, bold = true },
  rustCommentBlockDoc = { fg = foreground, bg = comment_bg, bold = true },
  rustCommentLine = { fg = foreground, bg = comment_bg, bold = true },
  rustCommentLineDoc = { fg = foreground, bg = comment_bg, bold = true },
  cCommentL = { fg = foreground, bg = comment_bg, bold = true },
  lispComment = { fg = foreground, bg = comment_bg, bold = true },

  ['@comment'] = { fg = foreground, bg = comment_bg, bold = true },
  ['@comment.documentation'] = { fg = foreground, bg = comment_bg, bold = true },
  ['@comment.error'] = { fg = foreground, bg = comment_bg, bold = true },
  ['@comment.hint'] = { fg = foreground, bg = comment_bg, bold = true },
  ['@comment.info'] = { fg = foreground, bg = comment_bg, bold = true },
  ['@comment.line'] = { fg = foreground, bg = comment_bg, bold = true },
  ['@comment.note'] = { fg = foreground, bg = comment_bg, bold = true },
  ['@comment.todo'] = { fg = foreground, bg = comment_bg, bold = true },
  ['@comment.warning'] = { fg = foreground, bg = comment_bg, bold = true },
  ['@markup.link'] = { fg = blue, underline = true },
  ['@markup.raw'] = { fg = foreground },
  ['@markup.heading'] = { fg = foreground, bold = true },
  ['@property.json'] = { bold = true },
  ['@text.emphasis'] = { italic = true },
  ['@text.reference'] = { fg = purple },
  ['@text.strong'] = { bold = true },
  ['@text.uri'] = { fg = blue },
  ['@variable.builtin'] = { bold = true },
  ['@string.regexp'] = { link = 'Regexp' },
  ['@variable.parameter.reference'] = { fg = orange },
}

for group, opts in pairs(highlights) do
  api.nvim_set_hl(0, group, opts)
end
