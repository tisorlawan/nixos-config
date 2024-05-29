local w = require("wezterm")

local cfg = {}

cfg.adjust_window_size_when_changing_font_size = false
cfg.font = w.font_with_fallback({
	-- "FiraCode Nerd Font Propo",
	-- "FantasqueSansM Nerd Font",
	-- "Ubuntu Mono",
	-- "Noto Sans Mono",
	-- "NotoMono Nerd Font",
	-- "Terminus",
	"JetBrainsMono Nerd Font",
})

cfg.font_size = 13
-- cfg.cell_width = 1.0
cfg.line_height = 1.05
cfg.allow_square_glyphs_to_overflow_width = "WhenFollowedBySpace"
cfg.harfbuzz_features = {
	"zero", -- Use a slashed zero '0' (instead of dotted)
	"kern", -- (default) kerning (todo check what is really is)
	"liga", -- (default) ligatures
	"clig", -- (default) contextual ligatures
}

return cfg
