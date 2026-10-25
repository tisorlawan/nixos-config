-- Run through tests/runner.sh. No plugins or user state are required.
vim.g.mapleader = " "
vim.opt.runtimepath:prepend(vim.fn.getcwd())
vim.o.shell = vim.fn.exepath("fish") ~= "" and vim.fn.exepath("fish") or "/bin/sh"
vim.o.shellcmdflag = "-c"
vim.o.columns = 120
vim.o.lines = 40
vim.wo.number = true
vim.wo.relativenumber = true
vim.wo.signcolumn = "yes"

local messages = {}
vim.notify = function(message, level)
	messages[#messages + 1] = { message = message, level = level }
end

-- Exercise the actual terminal integration, including the quit guard.
local init = table.concat(vim.fn.readfile("init.lua"), "\n")
local terminal_config = assert(init:match('(%-%- Fish as the `:terminal` shell.-)\nrequire%("which%-key"%)%.add'))
assert(loadstring(terminal_config))()
local runner = require("runner")
local state_dir = vim.fn.stdpath("state") .. "/runner"
local source = vim.api.nvim_get_current_buf()
local source_win = vim.api.nvim_get_current_win()
local prompts = 0
local answer
local expected_default
vim.ui.input = function(opts, callback)
	prompts = prompts + 1
	if expected_default then
		assert(opts.default == expected_default, vim.inspect(opts))
	end
	callback(answer)
end
local selection
vim.ui.select = function(items, _, callback)
	callback(selection and items[selection] or nil)
end

local function eq(expected, actual)
	assert(vim.deep_equal(expected, actual), "Expected " .. vim.inspect(expected) .. ", got " .. vim.inspect(actual))
end

local function mapped(key)
	local mapping = vim.fn.maparg(" " .. key, "n", false, true)
	assert(type(mapping.callback) == "function", "Missing mapping: " .. key)
	mapping.callback()
end

local function terminals()
	return vim.tbl_filter(function(buf)
		return vim.bo[buf].buftype == "terminal"
	end, vim.api.nvim_list_bufs())
end

local function terminal()
	local buffers = terminals()
	eq(1, #buffers)
	return buffers[1]
end

local function finished(code)
	assert(
		vim.wait(3000, function()
			return vim.b[terminal()].runner_exit_code ~= nil
		end, 10),
		"Command did not finish"
	)
	eq(code or 0, vim.b[terminal()].runner_exit_code)
	return table.concat(vim.api.nvim_buf_get_lines(terminal(), 0, -1, false), "\n")
end

local function hide()
	vim.cmd.stopinsert()
	local mapping = vim.fn.maparg("q", "n", false, true)
	assert(mapping.callback, "Missing q mapping")
	mapping.callback()
	eq(source_win, vim.api.nvim_get_current_win())
	eq(source, vim.api.nvim_get_current_buf())
	eq(1, #vim.api.nvim_list_wins())
	eq(true, vim.wo.number)
	eq(true, vim.wo.relativenumber)
	eq("yes", vim.wo.signcolumn)
end

local function read_state(name)
	return vim.json.decode(table.concat(vim.fn.readfile(state_dir .. "/" .. name .. ".json"), "\n"))
end

if vim.env.RUNNER_TEST_PHASE == "restart" then
	-- The first process saved these values. Repeat must not open a prompt.
	eq("printf runner-persisted", read_state("command"))
	eq("float", read_state("layout"))
	assert(math.abs(42 / 120 - read_state("right-ratio")) < 1e-12, "Exit did not save the visible split ratio")
	mapped("rr")
	eq(0, prompts)
	assert(vim.api.nvim_win_get_config(0).relative == "editor")
	assert(finished():find("runner%-persisted"))
	hide()

	-- Restore ratios, not fixed dimensions, in a larger editor after restart.
	vim.o.columns = 160
	vim.o.lines = 60
	vim.o.showtabline = 2
	vim.o.laststatus = 3
	for index, mode in ipairs({ "right", "below" }) do
		local ratio = read_state(mode .. "-ratio")
		local get_size = mode == "right" and vim.api.nvim_win_get_width or vim.api.nvim_win_get_height
		local extent = get_size(source_win)
		selection = index
		mapped("rf")
		mapped("rr")
		assert(finished():find("runner%-persisted"))
		eq(math.floor(extent * ratio + 0.5), get_size(vim.api.nvim_get_current_win()))
		hide()
	end
	print("runner: restart and proportional split checks passed")
	return
end

-- No saved command: cancellation and blank input do not create a terminal.
answer = nil
mapped("rr")
answer = "   "
mapped("rr")
eq(0, #terminals())
eq(1, #vim.api.nvim_list_wins())

-- Background repeat also prompts when there is no saved command.
answer = "printf runner-first-background"
mapped("rb")
eq(1, #vim.api.nvim_list_wins())
assert(finished():find("runner%-first%-background"))
-- An invalid saved value has the same behavior as no saved command.
vim.fn.writefile({ "null" }, state_dir .. "/command.json")

-- A first run prompts, saves, displays real shell output, and retains it.
answer = "printf runner-first"
mapped("rr")
eq(answer, read_state("command"))
assert(finished():find("runner%-first"))
eq(2, #vim.api.nvim_list_wins())
assert(vim.api.nvim_win_get_position(0)[2] > 0, "Expected a right split")
eq(false, vim.wo.number)
eq("no", vim.wo.signcolumn)
hide()

-- Edit changes only saved state, not the completed output.
expected_default = answer
answer = "printf runner-edited"
local old_buf = terminal()
mapped("re")
eq(old_buf, terminal())
eq(answer, read_state("command"))
expected_default = nil

-- Background repeat creates no window, preserves focus, and captures output.
local old_prompts = prompts
mapped("rb")
eq(old_prompts, prompts)
eq(source_win, vim.api.nvim_get_current_win())
eq(source, vim.api.nvim_get_current_buf())
eq(1, #vim.api.nvim_list_wins())
assert(finished():find("runner%-edited"))
mapped("ro")
eq(terminal(), vim.api.nvim_get_current_buf())
hide()

-- Every layout runs a real command; q preserves the editor buffer.
for index, mode in ipairs({ "right", "below", "float", "full" }) do
	selection = index
	mapped("rf")
	eq(mode, read_state("layout"))
	mapped("rr")
	assert(finished():find("runner%-edited"))
	local config = vim.api.nvim_win_get_config(0)
	if mode == "float" then
		eq("editor", config.relative)
	elseif mode == "full" then
		eq(1, #vim.api.nvim_list_wins())
		eq(source_win, vim.api.nvim_get_current_win())
	elseif mode == "below" then
		assert(vim.api.nvim_win_get_position(0)[1] > 0, "Expected a bottom split")
	else
		assert(vim.api.nvim_win_get_position(0)[2] > 0, "Expected a right split")
	end
	eq(false, vim.wo.number)
	hide()
end

-- The conditional layout keeps successful commands hidden and retains output.
selection = 5
mapped("rf")
eq("background", read_state("layout"))
answer = "sleep 0.1; printf runner-hidden-success"
mapped("rc")
eq(1, #vim.api.nvim_list_wins())
eq(source_win, vim.api.nvim_get_current_win())
assert(finished():find("runner%-hidden%-success"))
eq(1, #vim.api.nvim_list_wins())
eq(source_win, vim.api.nvim_get_current_win())
mapped("ro")
eq(terminal(), vim.api.nvim_get_current_buf())
assert(vim.api.nvim_win_get_position(0)[2] > 0, "Expected a right split for hidden output")
hide()

-- A failed repeat opens its captured output only after the command exits.
answer = "sleep 0.1; printf runner-hidden-error; exit 7"
mapped("re")
mapped("rr")
eq(1, #vim.api.nvim_list_wins())
eq(source_win, vim.api.nvim_get_current_win())
assert(finished(7):find("runner%-hidden%-error"))
eq(2, #vim.api.nvim_list_wins())
eq(terminal(), vim.api.nvim_get_current_buf())
assert(vim.api.nvim_win_get_position(0)[2] > 0, "Expected a right split after failure")
hide()

-- Explicit background execution stays hidden even when the command fails.
mapped("rb")
assert(finished(7):find("runner%-hidden%-error"))
eq(1, #vim.api.nvim_list_wins())
eq(source_win, vim.api.nvim_get_current_win())

-- A later layout selection cannot change an active run's split-on-error policy.
mapped("rr")
selection = 3
mapped("rf")
finished(7)
eq(2, #vim.api.nvim_list_wins())
assert(vim.api.nvim_win_get_position(0)[2] > 0, "Expected a right split after a layout change")
hide()
answer = "printf runner-edited"
mapped("re")

-- Each split remembers its own ratio after a manual resize and reopen.
selection = 1
mapped("rf")
mapped("rr")
finished()
vim.api.nvim_win_set_width(0, 38)
-- The resize event saves immediately, before the terminal closes.
vim.api.nvim_exec_autocmds("WinResized", {})
assert(math.abs(38 / vim.o.columns - read_state("right-ratio")) < 1e-12)
hide()
mapped("ro")
eq(38, vim.api.nvim_win_get_width(0))
hide()
selection = 2
mapped("rf")
mapped("rr")
finished()
vim.api.nvim_win_set_height(0, 10)
hide()
mapped("ro")
eq(10, vim.api.nvim_win_get_height(0))
-- Native :close must save the size too, not just the runner's q mapping.
vim.api.nvim_win_set_height(0, 12)
vim.cmd.close()
mapped("ro")
eq(12, vim.api.nvim_win_get_height(0))
hide()

-- A resize of the whole editor must not replace the saved split ratio.
local saved_ratio = read_state("below-ratio")
mapped("ro")
vim.o.lines = 50
vim.api.nvim_exec_autocmds("WinResized", {})
eq(saved_ratio, read_state("below-ratio"))
hide()
vim.o.lines = 40
selection = 4
mapped("rf")

-- Commands use the invocation directory, including paths with spaces.
local original_cwd = vim.fn.getcwd()
local working_dir = state_dir .. "/working directory"
vim.fn.mkdir(working_dir, "p")
vim.cmd.lcd(vim.fn.fnameescape(working_dir))
answer = "printf 'runner cwd: '; pwd"
mapped("rc")
local cwd_output = finished()
assert(cwd_output:gsub("\n", ""):find(working_dir, 1, true), vim.inspect(cwd_output))
hide()
vim.cmd.lcd(vim.fn.fnameescape(original_cwd))

-- Hiding a split must work even after the user closes the editor window.
selection = 1
mapped("rf")
mapped("rr")
finished()
vim.api.nvim_win_close(source_win, false)
vim.fn.maparg("q", "n", false, true).callback()
eq(source, vim.api.nvim_get_current_buf())
eq(1, #vim.api.nvim_list_wins())
source_win = vim.api.nvim_get_current_win()
selection = 4
mapped("rf")

-- An active job cannot be replaced or overlapped; the quit guard sees it.
answer = "sleep 0.2; printf runner-active"
mapped("rc")
local active_buf = terminal()
local confirm_calls = 0
vim.fn.confirm = function()
	confirm_calls = confirm_calls + 1
	return 2
end
-- With full-window mode, ZZ invokes the existing session-exit guard.
vim.fn.maparg("ZZ", "n", false, true).callback()
eq(1, confirm_calls)
mapped("rr")
eq(active_buf, terminal())
assert(messages[#messages].message:find("still active", 1, true))
assert(finished():find("runner%-active"))
hide()

-- Hidden live jobs also participate in the session-exit guard.
mapped("rb")
eq(1, #vim.api.nvim_list_wins())
vim.fn.maparg("ZZ", "n", false, true).callback()
eq(2, confirm_calls)
assert(finished():find("runner%-active"))
mapped("ro")
hide()

-- Nonzero exit status and output remain available.
answer = "printf runner-error; exit 7"
mapped("rc")
assert(finished(7):find("runner%-error"))
hide()

-- Corrupt persisted data falls back to a prompt/default layout.
vim.fn.writefile({ "{broken" }, state_dir .. "/command.json")
vim.fn.writefile({ '"unknown-layout"' }, state_dir .. "/layout.json")
vim.fn.writefile({ "0" }, state_dir .. "/right-ratio.json")
answer = "printf runner-recovered"
old_prompts = prompts
mapped("rr")
eq(old_prompts + 1, prompts)
assert(finished():find("runner%-recovered"))
assert(vim.api.nvim_win_get_position(0)[2] > 0)
eq(math.floor(vim.o.columns * 0.5 + 0.5), vim.api.nvim_win_get_width(0))
hide()

-- Prepare independent command and layout values for a real second process.
answer = "printf runner-persisted"
mapped("re")
selection = 3
mapped("rf")
eq(answer, read_state("command"))
eq("float", read_state("layout"))

-- Leave a resized terminal visible so the real VimLeavePre event saves it.
selection = 1
mapped("rf")
mapped("ro")
vim.api.nvim_win_set_width(0, 42)
selection = 3
mapped("rf")
print("runner: command, background, layout, lifecycle, and split ratio checks passed")
