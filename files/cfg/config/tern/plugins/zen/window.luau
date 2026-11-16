--!strict

-- Zen mode hides the tab bar and shrinks the outer padding to a thin gap: 2 px around the
-- panes plus 2 px inside each pane, so 4 px at the window edge and between split panes.
-- The terminal's own padding (padding_x, padding_y) stays.
--
-- Each window runs its own copy of this file and toggles its own zen mode. tern.kv is shared by
-- every window, so it only holds the last choice, which windows start with after a restart or
-- plugin reload. Toggling from tern.kv instead would flip the other window's choice.

local ZEN_CSS = [[
#tabbar { display: none !important; }
#panel { top: 0 !important; left: 0 !important; right: 0 !important; bottom: 0 !important; }
.tn-stage { top: 2px !important; left: 2px !important; right: 2px !important; bottom: 2px !important; }
.tn-pane { padding: 2px !important; }
]]

local on = tern.kv.get("zen") == true
tern.css("zen", if on then ZEN_CSS else "")

tern.command({
	id = "toggle",
	title = "Toggle zen mode",
	icon = "eye",
	run = function(_cx)
		on = not on
		tern.kv.set("zen", if on then true else nil)
		tern.css("zen", if on then ZEN_CSS else "")
	end,
})
