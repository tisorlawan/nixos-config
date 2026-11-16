--!strict

-- Tern's `copy` (Ctrl+Shift+C) copies the selection; with nothing selected,
-- copy the focused pane's absolute working directory instead.
tern.override("copy", function(cx)
	if cx.session:selection() then
		return false
	end
	local id = cx.session:focused()
	if id == nil then
		return false
	end
	local pane = cx.session:pane(id)
	if pane == nil or pane.cwd == nil or pane.cwd == "" then
		return false
	end
	cx:copy(pane.cwd)
	cx:toast("success", "Copied working directory", pane.cwd)
	return true
end)
