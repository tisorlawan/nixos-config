local wezterm = require("wezterm")
local cfg = {}

cfg.color_scheme = "Kanagawa (Gogh)"

cfg.window_background_opacity = 0.80
cfg.window_padding = { left = 0, right = 0, top = 0, bottom = 0 }
cfg.force_reverse_video_cursor = true
cfg.inactive_pane_hsb = {
  saturation = 0.88,
  brightness = 0.68,
}
cfg.colors = {
  background = "#171720",
  foreground = "#dcd7ba",
}

cfg.hide_tab_bar_if_only_one_tab = true
cfg.enable_tab_bar = true
-- cfg.tab_bar_at_bottom = true

local function tab_title(tab_info)
  local title = tab_info.tab_title
  if title and #title > 0 then
    title = title
  else
    title = tab_info.active_pane.title
  end

  local zoomed = ""
  if tab_info.active_pane.is_zoomed then
    zoomed = "[Z] "
  end

  return zoomed .. title
end

-- The filled in variant of the < symbol
local SOLID_LEFT_ARROW = wezterm.nerdfonts.pl_right_hard_divider

-- The filled in variant of the > symbol
local SOLID_RIGHT_ARROW = wezterm.nerdfonts.pl_left_hard_divider

---@diagnostic disable-next-line: unused-local
wezterm.on("format-tab-title", function(tab, tabs, panes, config, hover, max_width)
  local edge_background = "#0b0022"
  local background = ""
  local foreground = ""

  if tab.is_active then
    background = "#6c4cb0"
    foreground = "#c0c0c0"
  elseif hover then
    background = "#3b3052"
    foreground = "#909090"
  else
    edge_background = "#0a0002"
    background = "#0b0002"
  end

  local edge_foreground = background

  local title = tab_title(tab)

  -- ensure that the titles fit in the available space,
  -- and that we have room for the edges.
  title = wezterm.truncate_right(title, max_width - 2)

  return {
    { Background = { Color = edge_background } },
    { Foreground = { Color = edge_foreground } },
    { Text = SOLID_LEFT_ARROW },
    { Background = { Color = background } },
    { Foreground = { Color = foreground } },
    { Text = title },
    { Background = { Color = edge_background } },
    { Foreground = { Color = edge_foreground } },
    { Text = SOLID_RIGHT_ARROW },
  }
end)

return cfg
