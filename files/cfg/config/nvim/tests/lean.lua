-- Use the full config and a real Lean server through tests/lean.sh.
vim.o.columns = 120
vim.o.lines = 40
vim.cmd.edit("Proof.lean")
local buf = vim.api.nvim_get_current_buf()
local source_win = vim.api.nvim_get_current_win()
vim.api.nvim_buf_set_lines(buf, 0, -1, false, { "example : True := by", "  skip" })
vim.api.nvim_win_set_cursor(source_win, { 2, 2 })
vim.api.nvim_exec_autocmds("CursorMoved", { buffer = buf })

local function wait_for(description, predicate)
	assert(vim.wait(30000, predicate, 20), "Timed out: " .. description)
end

local client
wait_for("Lean LSP attachment", function()
	client = vim.lsp.get_clients({ bufnr = buf, name = "leanls" })[1]
	return client and client.initialized
end)
local ns = vim.lsp.diagnostic.get_namespace(client.id)
assert(not vim.diagnostic.config(nil, ns).update_in_insert, "Lean diagnostics must wait until insert mode ends")
assert(client.config.capabilities.textDocument.completion.completionItem.snippetSupport, "Blink capabilities are missing")
assert(vim.g.maplocalleader == "  ", "Expected two spaces for the local leader")
assert(vim.fn.maparg("  i", "n") == "<Plug>(LeanInfoviewToggle)", "Infoview mapping is missing")
assert(vim.fn.maparg("  s", "n") == "<Plug>(LeanInfoviewAcceptSuggestion)", "Suggestion mapping is missing")

wait_for("unsaved proof diagnostics", function()
	return vim.iter(vim.diagnostic.get(buf, { namespace = ns })):any(function(diagnostic)
		return diagnostic.message:find("unsolved goals", 1, true) ~= nil
	end)
end)
assert(vim.bo[buf].modified, "The proof must remain unsaved")
assert(not vim.diagnostic.is_enabled({ bufnr = buf }), "Unsaved Lean diagnostics must stay hidden")

local function infoview_text()
	for _, window in ipairs(vim.api.nvim_list_wins()) do
		local buffer = vim.api.nvim_win_get_buf(window)
		if vim.bo[buffer].filetype == "leaninfo" then
			return table.concat(vim.api.nvim_buf_get_lines(buffer, 0, -1, false), "\n")
		end
	end
	return ""
end

wait_for("True goal in the Infoview", function()
	return infoview_text():find("⊢ True", 1, true) ~= nil
end)

vim.api.nvim_set_current_win(source_win)
local diagnostic = vim.diagnostic.get(buf, { namespace = ns })[1]
vim.api.nvim_win_set_cursor(source_win, { diagnostic.lnum + 1, diagnostic.col })
local windows_before = vim.api.nvim_list_wins()
vim.cmd.normal({ "gl", bang = false })
assert(vim.deep_equal(windows_before, vim.api.nvim_list_wins()), "Unsaved Lean diagnostics opened a float")

local goals_ns = require("lean.lsp").goals_ns
assert(#vim.api.nvim_buf_get_extmarks(buf, goals_ns, 0, -1, {}) == 0, "Lean proof markers must stay hidden")
local function has_diagnostic_sign()
	for _, namespace in pairs(vim.api.nvim_get_namespaces()) do
		for _, mark in ipairs(vim.api.nvim_buf_get_extmarks(buf, namespace, 0, -1, { details = true })) do
			local group = mark[4].sign_hl_group
			if group and group:find("DiagnosticSign", 1, true) then
				return true
			end
		end
	end
	return false
end
assert(not has_diagnostic_sign(), "Unsaved Lean diagnostics left a sign in the source buffer")

vim.cmd.write()
assert(vim.diagnostic.is_enabled({ bufnr = buf }), "Lean diagnostics must appear after save")
assert(has_diagnostic_sign(), "Saved Lean diagnostics must show a native diagnostic sign")
vim.cmd.normal({ "gl", bang = false })
local float_win
for _, window in ipairs(vim.api.nvim_list_wins()) do
	if not vim.tbl_contains(windows_before, window) then
		float_win = window
	end
end
assert(float_win, "The diagnostic float did not open for a saved Lean proof")
vim.api.nvim_win_close(float_win, true)
vim.api.nvim_set_current_win(source_win)

local toggle = vim.fn.maparg(" td", "n", false, true).callback
toggle()
assert(not vim.diagnostic.is_enabled({ bufnr = buf }), "The diagnostics toggle did not disable Lean diagnostics")
toggle()
assert(vim.diagnostic.is_enabled({ bufnr = buf }), "The diagnostics toggle did not restore saved Lean diagnostics")

vim.api.nvim_buf_set_lines(buf, 1, 2, false, { "  trivial" })
vim.o.virtualedit = "onemore"
vim.api.nvim_win_set_cursor(source_win, { 2, 9 })
vim.api.nvim_exec_autocmds("TextChanged", { buffer = buf })
vim.api.nvim_exec_autocmds("CursorMoved", { buffer = buf })
assert(not vim.diagnostic.is_enabled({ bufnr = buf }), "Lean diagnostics must hide after the next edit")
toggle()
toggle()
assert(not vim.diagnostic.is_enabled({ bufnr = buf }), "The toggle must keep unsaved Lean diagnostics hidden")
wait_for("diagnostics clear after proof completion", function()
	return #vim.diagnostic.get(buf, { namespace = ns, severity = vim.diagnostic.severity.ERROR }) == 0
end)
wait_for("completed proof in the Infoview", function()
	return infoview_text():find("No goals.", 1, true) ~= nil
end)
assert(vim.bo[buf].modified, "Proof completion must work without save")
vim.cmd.write()
assert(vim.diagnostic.is_enabled({ bufnr = buf }), "Lean diagnostics must return after the next save")

vim.cmd("hide enew")
vim.bo.filetype = "text"
vim.api.nvim_buf_set_lines(0, 0, -1, false, { "unsaved text" })
vim.api.nvim_exec_autocmds("TextChanged", { buffer = 0 })
assert(not vim.diagnostic.is_enabled({ bufnr = 0 }), "Other filetypes must keep diagnostics hidden until save")
vim.bo.modified = false
vim.api.nvim_exec_autocmds("BufWritePost", { buffer = 0 })
assert(vim.diagnostic.is_enabled({ bufnr = 0 }), "Other filetypes must restore diagnostics after save")

print("Lean checks passed: LSP, Blink, mappings, diagnostics after save, live Infoview, proof completion, and other filetypes")
