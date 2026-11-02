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
	local buf, win = vim.lsp.util.open_floating_preview({
		"```python",
		"def classify(value: str) -> bool:",
		"    return bool(value)",
		"```",
		"",
		"Return whether the value is present.",
	}, "markdown", { title = "Documentation", max_width = 72 })
	local code_marks
	vim.cmd.redraw()
	assert(vim.wait(3000, function()
		code_marks = vim.tbl_filter(function(mark)
			return mark[4].hl_group == "RenderMarkdownCode"
		end, vim.api.nvim_buf_get_extmarks(buf, -1, 0, -1, { details = true }))
		return #code_marks > 0
	end, 20), "Markdown code background did not render")
	for _, mark in ipairs(code_marks) do
		eq(background("NormalFloat"), background(mark[4].hl_group))
	end
	vim.api.nvim_win_close(win, true)
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
					label_contrast = label_contrast and hl.bg ~= nil and hl.fg ~= nil and hl.fg ~= hl.bg
				end
			end
		end
		vim.fn.feedkeys(vim.keycode("<Esc>"), "t")
	end, 50)
	jump({ pattern = "target", inputlen = 0, opts = { safe_labels = "" } })
	assert(observed, "Leap exited before its labels appeared")
	assert(labels, "Leap target labels did not render")
	assert(not dimmed, "Leap recolored the text through its backdrop")
	assert(label_contrast, "Leap target labels need a solid background and a contrasting foreground")
	vim.api.nvim_set_current_buf(previous)
	vim.api.nvim_buf_delete(buf, { force = true })
end

local function expect(theme, mode, transparent)
	eq(theme, vim.g.colors_name)
	eq(mode, vim.o.background)
	eq(transparent, background("Normal") == nil)
	eq(transparent, background("NormalFloat") == nil)
	if theme:match("^tiso%-") then
		expect_documentation_background()
	elseif theme:match("^catppuccin%-") then
		expect_leap_colors()
	end
end

expect("tiso-black", "dark", true)
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
print("Colors: Catppuccin and Tiso transparency, theme selection, mode state, and dark flavour checks passed")
