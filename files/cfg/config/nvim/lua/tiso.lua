local M = {}

local palettes = {
	dark = {
		name = "tiso-black",
		transparent = "tiso_black_transparent",
		background = "#101010",
		contrast = "#000000",
		text = "#dedede",
		muted = "#808080",
		border = "#484848",
		surface = "#181818",
		selection = "#303030",
		green = "#b5e890",
		red = "#ff5f5f",
		orange = "#ffad42",
		magenta = "#ee66ff",
		cursor_selection = "#24351d",
	},
	light = {
		name = "tiso-light",
		transparent = "tiso_light_transparent",
		background = "#fafafa",
		contrast = "#ffffff",
		text = "#242424",
		muted = "#6a6a6a",
		border = "#a0a0a0",
		surface = "#f0f0f0",
		selection = "#dedede",
		green = "#326b26",
		red = "#b42318",
		orange = "#995700",
		magenta = "#9c239e",
		cursor_selection = "#e0ecd9",
	},
}

function M.load(mode)
	local palette = palettes[mode]
	vim.o.background = mode
	vim.cmd.highlight("clear")
	vim.g.colors_name = palette.name

	local contrast = palette.contrast
	local text = palette.text
	local muted = palette.muted
	local border = palette.border
	local surface = palette.surface
	local selection = palette.selection
	local green = palette.green
	local red = palette.red
	local orange = palette.orange
	local magenta = palette.magenta
	local background = vim.g[palette.transparent] == false and palette.background or "NONE"

	-- Keep default plugin groups monochrome, but preserve their highlight links.
	for name, highlight in pairs(vim.api.nvim_get_hl(0, { link = true })) do
		if not highlight.link then
			vim.api.nvim_set_hl(0, name, { fg = text })
		end
	end

	local highlights = {
		Normal = { fg = text, bg = background },
		NormalNC = { link = "Normal" },
		NormalFloat = { fg = text, bg = background },
		Cursor = { fg = contrast, bg = text },
		lCursor = { link = "Cursor" },
		CursorIM = { link = "Cursor" },
		TermCursor = { link = "Cursor" },
		MCursor = { fg = contrast, bg = green, bold = true },
		MCursorVisual = { fg = text, bg = palette.cursor_selection },
		FloatBorder = { fg = border, bg = background },
		FloatTitle = { fg = text, bold = true },
		Comment = { fg = magenta },
		Keyword = { fg = text, bold = true },
		Statement = { link = "Keyword" },
		Conditional = { link = "Keyword" },
		Repeat = { link = "Keyword" },
		Label = { link = "Keyword" },
		Exception = { link = "Keyword" },
		PreProc = { link = "Keyword" },
		Include = { link = "Keyword" },
		Define = { link = "Keyword" },
		Macro = { link = "Keyword" },
		PreCondit = { link = "Keyword" },
		StorageClass = { link = "Keyword" },
		Typedef = { link = "Keyword" },
		String = { fg = green },
		Character = { link = "String" },
		Number = { fg = text },
		Boolean = { fg = text },
		Constant = { fg = text },
		Identifier = { fg = text },
		Function = { fg = text },
		Type = { fg = text },
		Structure = { fg = text },
		Operator = { fg = text },
		Special = { fg = text },
		Delimiter = { fg = text },
		Todo = { fg = text, bold = true },
		Error = { fg = red, underline = true },
		Underlined = { fg = text, underline = true },
		Title = { fg = text, bold = true },
		Directory = { fg = text },
		LineNr = { fg = muted, bg = background },
		CursorLineNr = { fg = text, bg = background, bold = true },
		SignColumn = { fg = muted, bg = background },
		FoldColumn = { link = "SignColumn" },
		Folded = { fg = muted, bg = surface },
		NonText = { fg = border },
		EndOfBuffer = { link = "NonText" },
		Whitespace = { link = "NonText" },
		SpecialKey = { link = "NonText" },
		WinSeparator = { fg = border },
		CursorLine = { bg = surface },
		CursorColumn = { link = "CursorLine" },
		ColorColumn = { link = "CursorLine" },
		Visual = { bg = selection },
		VisualNOS = { link = "Visual" },
		Search = { fg = text, bg = selection },
		IncSearch = { fg = contrast, bg = text },
		CurSearch = { link = "IncSearch" },
		Substitute = { link = "IncSearch" },
		MatchParen = { fg = text, bg = selection, bold = true },
		Pmenu = { fg = text, bg = background },
		PmenuSel = { fg = text, bg = selection, bold = true },
		PmenuSbar = { bg = background },
		PmenuThumb = { bg = border },
		StatusLine = { fg = text, bg = background },
		StatusLineNC = { fg = muted, bg = background },
		WinBar = { link = "StatusLine" },
		WinBarNC = { link = "StatusLineNC" },
		TabLine = { fg = muted, bg = background },
		TabLineSel = { fg = text, bg = surface, bold = true },
		TabLineFill = { bg = background },
		DiffAdd = { bg = surface },
		DiffChange = { bg = surface },
		DiffDelete = { fg = muted, bg = surface },
		DiffText = { bg = selection, underline = true },
		ErrorMsg = { fg = red, bold = true },
		WarningMsg = { fg = orange },
		MoreMsg = { fg = text },
		Question = { fg = text },
		DiagnosticError = { fg = red },
		DiagnosticWarn = { fg = orange },
		DiagnosticInfo = { fg = muted },
		DiagnosticHint = { fg = muted },
		DiagnosticOk = { fg = muted },
		DiagnosticUnderlineError = { sp = red, underline = true },
		DiagnosticUnderlineWarn = { sp = orange, underline = true },
		DiagnosticUnderlineInfo = { sp = muted, underline = true },
		DiagnosticUnderlineHint = { sp = muted, underline = true },
		SpellBad = { sp = text, underline = true },
		SpellCap = { sp = muted, underline = true },
		SpellLocal = { sp = muted, underline = true },
		SpellRare = { sp = muted, underline = true },
		["@variable"] = { fg = text },
		["@keyword"] = { link = "Keyword" },
		["@string"] = { link = "String" },
		["@string.escape"] = { link = "String" },
		["@string.special"] = { link = "String" },
		["@character"] = { link = "String" },
		["@comment"] = { link = "Comment" },
		["@string.documentation"] = { link = "String" },
		["@lsp.type.keyword"] = { link = "Keyword" },
		["@lsp.type.string"] = { link = "String" },
		["@lsp.type.comment"] = { link = "Comment" },
		BlinkCmpMenu = { link = "Pmenu" },
		BlinkCmpMenuBorder = { link = "FloatBorder" },
		BlinkCmpMenuSelection = { link = "PmenuSel" },
		["@org.keyword.todo"] = { link = "Keyword" },
		["@org.keyword.done"] = { fg = muted },
		["@org.checkbox.halfchecked"] = { link = "Keyword" },
		BlinkCmpLabelMatch = { fg = text, bold = true },
		BlinkCmpLabelDetail = { fg = muted },
		BlinkCmpLabelDescription = { fg = muted },
		BlinkCmpDoc = { link = "NormalFloat" },
		BlinkCmpDocBorder = { link = "FloatBorder" },
		FFFBorder = { link = "FloatBorder" },
		FFFTitle = { link = "Title" },
		FFFPreviewMatch = { fg = text, bold = true },
	}

	for name, highlight in pairs(highlights) do
		vim.api.nvim_set_hl(0, name, highlight)
	end

	-- These plugins rebuild their palettes after the colorscheme loads.
	local plugin_highlights = {
		NeogitGraphGreen = { fg = text },
		NeogitGraphBoldGreen = { fg = text, bold = true },
		NeogitDiffAdditions = { fg = text },
		NeogitDiffAdd = { link = "DiffAdd" },
		NeogitDiffAddHighlight = { fg = text, bg = surface },
		NeogitDiffAddCursor = { fg = text, bg = selection },
		NeogitDiffAddInline = { fg = text, bg = selection, bold = true },
		NeogitDiffDeleteInline = { fg = text, bg = selection, bold = true },
		NeogitRemote = { fg = text, bold = true },
		NeogitPopupBranchName = { fg = text },
		NeogitChangeAdded = { fg = text },
		NeogitChangeNewFile = { fg = text },
		FFFGitSignStaged = { fg = muted },
		FFFGitSignModified = { fg = muted },
		FFFGitSignDeleted = { fg = muted },
		FFFGitSignUntracked = { fg = muted },
	}
	vim.api.nvim_create_autocmd("ColorScheme", {
		group = vim.api.nvim_create_augroup("tiso_highlights", { clear = true }),
		pattern = palette.name,
		callback = function()
			for name, highlight in pairs(plugin_highlights) do
				vim.api.nvim_set_hl(0, name, highlight)
			end
		end,
	})
end

return M
