-- Run through tests/colors.sh with the real configuration and installed plugins.
local function eq(expected, actual)
	assert(vim.deep_equal(expected, actual), "Expected " .. vim.inspect(expected) .. ", got " .. vim.inspect(actual))
end

local function background(group)
	return vim.api.nvim_get_hl(0, { name = group, link = false }).bg
end

local function toggle()
	vim.fn.maparg("<Space>tt", "n", false, true).callback()
end

local function expect_documentation_background()
	if background("Normal") == nil then
		eq(nil, background("NormalFloat"))
		eq(nil, background("FloatBorder"))
		eq(nil, background("FloatTitle"))
	end

	local buf, win = vim.lsp.util.open_floating_preview({
		"```python",
		"def classify(value: str) -> bool:",
		"    return bool(value)",
		"```",
		"",
		"Return whether the value is present.",
	}, "markdown", { title = "Documentation", max_width = 72 })
	local marks
	vim.cmd.redraw()
	assert(vim.wait(3000, function()
		marks = vim.api.nvim_buf_get_extmarks(buf, -1, 0, -1, { details = true })
		for _, mark in ipairs(marks) do
			for _, chunk in ipairs(mark[4].virt_text or {}) do
				if chunk[1]:find("python", 1, true) then
					return true
				end
			end
		end
		return false
	end, 20), "Markdown language header did not render")
	local function expect_background(group)
		if type(group) == "table" then
			for _, name in ipairs(group) do
				expect_background(name)
			end
		elseif group then
			local bg = background(group)
			assert(bg == nil or bg == background("NormalFloat"), "Hover background mismatch: " .. group)
		end
	end
	for _, mark in ipairs(marks) do
		expect_background(mark[4].hl_group)
		for _, chunk in ipairs(mark[4].virt_text or {}) do
			expect_background(chunk[2])
		end
	end
	vim.api.nvim_win_close(win, true)
end

local function luminance(color)
	local function linear(shift)
		local channel = bit.band(bit.rshift(color, shift), 255) / 255
		return channel <= 0.04045 and channel / 12.92 or ((channel + 0.055) / 1.055) ^ 2.4
	end
	return 0.2126 * linear(16) + 0.7152 * linear(8) + 0.0722 * linear(0)
end

local function expect_leap_colors()
	local previous = vim.api.nvim_get_current_buf()
	local buf = vim.api.nvim_create_buf(false, true)
	vim.api.nvim_set_current_buf(buf)
	vim.api.nvim_buf_set_lines(buf, 0, -1, false, {
		"# Leap color check",
		'target_one = "green"',
		'target_two = "blue"',
		'target_three = True',
	})
	vim.api.nvim_win_set_cursor(0, { 1, 0 })
	vim.cmd.redraw()
	local jump = require("leap").leap
	local observed, dimmed, labels = false, false, false
	local label_contrast = true
	local label_separation = true
	vim.defer_fn(function()
		observed = true
		for _, mark in ipairs(vim.api.nvim_buf_get_extmarks(buf, -1, 0, -1, { details = true })) do
			local detail = mark[4]
			if detail.hl_group == "LeapBackdrop" then
				local hl = vim.api.nvim_get_hl(0, { name = "LeapBackdrop", link = false })
				dimmed = dimmed or hl.fg ~= nil or hl.bg ~= nil
			end
			for _, chunk in ipairs(detail.virt_text or {}) do
				labels = labels or chunk[2] == "LeapLabel"
				if chunk[2] == "LeapLabel" then
					local hl = vim.api.nvim_get_hl(0, { name = chunk[2], link = false })
					if hl.bg and hl.fg then
						local fg, bg = luminance(hl.fg), luminance(hl.bg)
						local contrast = (math.max(fg, bg) + 0.05) / (math.min(fg, bg) + 0.05)
						label_contrast = label_contrast and contrast >= 10
						local editor_bg = background("Normal")
						if editor_bg then
							local editor = luminance(editor_bg)
							local separation = (math.max(bg, editor) + 0.05) / (math.min(bg, editor) + 0.05)
							label_separation = label_separation and separation >= 3
						end
					else
						label_contrast = false
					end
				end
			end
		end
		vim.fn.feedkeys(vim.keycode("<Esc>"), "t")
	end, 50)
	jump({ pattern = "target", inputlen = 0, opts = { safe_labels = "" } })
	assert(observed, "Leap exited before its labels appeared")
	assert(labels, "Leap target labels did not render")
	assert(not dimmed, "Leap recolored the text through its backdrop")
	assert(label_contrast, "Leap target labels need a solid background and at least 10:1 text contrast")
	assert(label_separation, "Leap target backgrounds need at least 3:1 contrast against the editor background")
	vim.api.nvim_set_current_buf(previous)
	vim.api.nvim_buf_delete(buf, { force = true })
end

local function expect(theme, mode, transparent)
	eq(theme, vim.g.colors_name)
	eq(mode, vim.o.background)
	eq(transparent, background("Normal") == nil)
	eq(transparent, background("NormalFloat") == nil)
	expect_documentation_background()
	if theme:match("^catppuccin%-") then
		expect_leap_colors()
	end
end

vim.cmd.colorscheme("catppuccin")
expect("catppuccin-mocha", "dark", true)
toggle()
expect("catppuccin-mocha", "dark", false)
toggle()
expect("catppuccin-mocha", "dark", true)

-- A mode change must keep the theme family and the other mode's state.
vim.env.COLOR = "light"
toggle()
expect("catppuccin-latte", "light", false)
toggle()
expect("catppuccin-latte", "light", true)
vim.env.COLOR = "dark"
toggle()
expect("catppuccin-mocha", "dark", false)
vim.env.COLOR = "light"
toggle()
expect("catppuccin-latte", "light", false)
toggle()
expect("catppuccin-latte", "light", true)
vim.env.COLOR = "dark"
toggle()
expect("catppuccin-mocha", "dark", true)

-- An explicit dark flavour must survive toggles and a light-mode round trip.
vim.cmd.colorscheme("catppuccin-frappe")
expect("catppuccin-frappe", "dark", true)
toggle()
expect("catppuccin-frappe", "dark", false)
toggle()
expect("catppuccin-frappe", "dark", true)
vim.env.COLOR = "light"
toggle()
expect("catppuccin-latte", "light", false)
vim.env.COLOR = "dark"
toggle()
expect("catppuccin-frappe", "dark", false)
toggle()
expect("catppuccin-frappe", "dark", true)

-- Tiso must retain its own mode variants after another theme was active.
vim.cmd.colorscheme("tiso-black")
toggle()
expect("tiso-black", "dark", false)
toggle()
expect("tiso-black", "dark", true)
vim.env.COLOR = "light"
toggle()
expect("tiso-light", "light", true)
toggle()
expect("tiso-light", "light", false)

-- The toggle must not replace an unrelated selected colorscheme with Tiso.
vim.cmd.colorscheme("default")
toggle()
eq("default", vim.g.colors_name)

-- Every theme in the Quickshell catalog loads through the set-theme state file
-- in both modes. The opaque editor background matches the bar's panel color.
local catalog = {}
local source = table.concat(vim.fn.readfile("../quickshell/Themes.js"), "\n")
for id, entry in source:gmatch('id: "([%w-]+)"(.-)\n  }') do
	local dark, light = entry:match('dark: {.-panelBg: "(#%x+)".-light: {.-panelBg: "(#%x+)"')
	table.insert(catalog, { id = id, dark = dark, light = light })
end
assert(#catalog >= 7, "Could not read the theme catalog")
eq("catppuccin", catalog[1].id)

local state = vim.fs.joinpath(vim.fs.dirname(vim.fn.stdpath("state")), "theme", "current")
local loads = 0
vim.api.nvim_create_autocmd("ColorScheme", {
	callback = function()
		loads = loads + 1
	end,
})

-- Replace the state file with a rename, as set-theme does.
local function select_theme(id)
	local before = loads
	vim.fn.writefile({ id }, state .. ".tmp")
	assert(vim.uv.fs_rename(state .. ".tmp", state))
	assert(vim.wait(3000, function()
		return loads > before
	end, 20), "No colorscheme load after selecting " .. id)
end

-- One transparency state clears the background; the other shows `expected`.
local function expect_transparency_toggle(id, mode, expected)
	local first = background("Normal")
	expect_documentation_background()
	toggle()
	local second = background("Normal")
	expect_documentation_background()
	local opaque = first or second
	assert((first == nil) ~= (second == nil), id .. " " .. mode .. ": transparency toggle had no effect")
	eq(expected, string.format("#%06x", opaque))
end

for _, theme in ipairs(catalog) do
	vim.env.COLOR = "dark"
	select_theme(theme.id)
	eq("dark", vim.o.background)
	expect_transparency_toggle(theme.id, "dark", theme.dark)
	vim.env.COLOR = "light"
	toggle()
	eq("light", vim.o.background)
	expect_transparency_toggle(theme.id, "light", theme.light)
end

-- A hand-picked colorscheme keeps its family across a mode change until the
-- next theme selection.
vim.env.COLOR = "dark"
vim.cmd.colorscheme("tiso-black")
vim.env.COLOR = "light"
toggle()
eq("tiso-light", vim.g.colors_name)
select_theme("gruvbox")
eq("gruvbox", vim.g.colors_name)

-- An unknown ID selects Catppuccin.
select_theme("no-such-theme")
eq("catppuccin-latte", vim.g.colors_name)
print("Colors: Catppuccin and Tiso transparency, theme selection, mode state, dark flavour, and set-theme catalog checks passed")
