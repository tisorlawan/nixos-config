local w = require("wezterm")
local act = w.action
local utils = require("utils")
local mods = require("utils").mods
local keybind = require("utils").keybind

local cfg = {}
local full_setup = false

local function is_vim(pane)
  return pane:get_user_vars().IS_NVIM == "true"
end

local direction_keys = {
  Left = "h",
  Down = "j",
  Up = "k",
  Right = "l",

  -- reverse lookup
  h = "Left",
  j = "Down",
  k = "Up",
  l = "Right",
}

local function split_nav(resize_or_move, key)
  return {
    key = key,
    mods = resize_or_move == "resize" and "META" or "CTRL",
    action = w.action_callback(function(win, pane)
      if is_vim(pane) then
        -- pass the keys through to vim/nvim
        win:perform_action({
          SendKey = { key = key, mods = resize_or_move == "resize" and "META" or "CTRL" },
        }, pane)
      else
        if resize_or_move == "resize" then
          win:perform_action({ AdjustPaneSize = { direction_keys[key], 3 } }, pane)
        else
          win:perform_action({ ActivatePaneDirection = direction_keys[key] }, pane)
        end
      end
    end),
  }
end

local optional_keys = {
  keybind(mods.L, "l", act.SplitHorizontal({ domain = "CurrentPaneDomain" })),
  keybind(mods.L, "j", act.SplitVertical({ domain = "CurrentPaneDomain" })),
  keybind(mods.LC, "j", act.SplitVertical({ domain = "CurrentPaneDomain" })),

  keybind(mods.S, "UpArrow", act.ScrollByLine(-1)),
  keybind(mods.S, "DownArrow", act.ScrollByLine(1)),

  keybind(mods.CS, "K", act.ClearScrollback("ScrollbackAndViewport")),
  keybind(mods.CS, " ", act.QuickSelect),
  keybind(mods.CS, "d", act.ShowDebugOverlay),
  keybind(mods.CS, "f", act.Search({ CaseInSensitiveString = "" })),
  keybind(mods.CS, "y", act.ActivateCopyMode),

  keybind(mods.L, "r", act.ActivateKeyTable({ name = "resize_pane", one_shot = false })),
  keybind(mods.CS, "s", act.PaneSelect({ mode = "SwapWithActive" })),
  keybind(mods.CS, "z", act.TogglePaneZoomState),

  -- Tabs
  keybind(mods.CS, "t", act.SpawnTab("DefaultDomain")),
  keybind(mods.LC, "c", act.SpawnTab("DefaultDomain")),
  keybind(mods.LC, "n", act.ActivateTabRelative(1)),
  keybind(mods.LC, "p", act.ActivateTabRelative(-1)),
  keybind(mods.C, "Tab", act.ActivateTabRelative(1)),
  keybind(mods.CS, "Tab", act.ActivateTabRelative(-1)),
  keybind(mods.CS, "w", act.CloseCurrentTab({ confirm = true })),

  keybind(mods.CS, "x", act.ShowLauncher),
  keybind(mods.CS, "p", act.ActivateCommandPalette),
  keybind(mods.CA, "c", act.CharSelect),

  {
    key = ",",
    mods = mods.L,
    action = act.PromptInputLine({
      description = "Enter new name for tab",
      action = w.action_callback(function(window, pane, line)
        if line then
          window:active_tab():set_title(line)
        end
      end),
    }),
  },
  split_nav("move", "h"),
  split_nav("move", "j"),
  split_nav("move", "k"),
  split_nav("move", "l"),

  split_nav("resize", "h"),
  split_nav("resize", "j"),
  split_nav("resize", "k"),
  split_nav("resize", "l"),
}

local keys = {
  keybind(mods.CS, "r", act.EmitEvent("my-reload-config-with-notif")),

  -- Font size
  keybind(mods.C, "0", act.ResetFontSize),
  keybind(mods.C, "=", act.IncreaseFontSize),
  keybind(mods.C, "-", act.DecreaseFontSize),

  keybind(mods.LC, "l", act.SendKey({ key = "L", mods = "CTRL" })),

  -- Copy/Paste to/from Clipboard
  keybind(mods.CS, "c", act.CopyTo("ClipboardAndPrimarySelection")),
  keybind(mods.CS, "v", act.PasteFrom("Clipboard")),

  keybind(mods.CS, "h", w.action.ToggleFullScreen),

  keybind(mods.CS, "m", act.SwitchToWorkspace({ name = "monitoring" })),
  keybind(mods.CA, "n", act.SwitchWorkspaceRelative(1)),
  keybind(mods.CA, "p", act.SwitchWorkspaceRelative(-1)),
  keybind(mods.CS, "o", act.ShowLauncherArgs({ flags = "FUZZY|WORKSPACES" })),

  keybind(mods.CS, "u", act.SwitchToWorkspace({ name = "default" })),
  {
    key = "N",
    mods = mods.CS,
    action = act.PromptInputLine({
      description = "Enter name for new workspace",
      action = w.action_callback(function(window, pane, line)
        if line then
          window:perform_action(
            act.SwitchToWorkspace({
              name = line,
            }),
            pane
          )
        end
      end),
    }),
  },
}

if full_setup then
  cfg.leader = { key = "a", mods = "CTRL", timeout_milliseconds = 1001 }
  table.insert(keys, optional_keys)
end
cfg.keys = utils.tbl_flatten_list(keys)

cfg.key_tables = {
  resize_pane = {
    { key = "LeftArrow",  action = act.AdjustPaneSize({ "Left", 1 }) },
    { key = "h",          action = act.AdjustPaneSize({ "Left", 1 }) },

    { key = "RightArrow", action = act.AdjustPaneSize({ "Right", 1 }) },
    { key = "l",          action = act.AdjustPaneSize({ "Right", 1 }) },

    { key = "UpArrow",    action = act.AdjustPaneSize({ "Up", 1 }) },
    { key = "k",          action = act.AdjustPaneSize({ "Up", 1 }) },

    { key = "DownArrow",  action = act.AdjustPaneSize({ "Down", 1 }) },
    { key = "j",          action = act.AdjustPaneSize({ "Down", 1 }) },

    -- Cancel the mode by pressing escape
    { key = "Escape",     action = "PopKeyTable" },
  },

  activate_pane = {
    { key = "LeftArrow",  action = act.ActivatePaneDirection("Left") },
    { key = "h",          action = act.ActivatePaneDirection("Left") },

    { key = "RightArrow", action = act.ActivatePaneDirection("Right") },
    { key = "l",          action = act.ActivatePaneDirection("Right") },

    { key = "UpArrow",    action = act.ActivatePaneDirection("Up") },
    { key = "k",          action = act.ActivatePaneDirection("Up") },

    { key = "DownArrow",  action = act.ActivatePaneDirection("Down") },
    { key = "j",          action = act.ActivatePaneDirection("Down") },
  },
}

cfg.keys = utils.tbl_flatten_list(cfg.keys)

w.on("my-reload-config-with-notif", function(win, pane)
  w.GLOBAL.want_reload_notification = true
  win:perform_action(act.ReloadConfiguration, pane)
  -- Will trigger the builtin `window-config-reloaded` event, the notification is wired on
  -- that event, to make sure only a _valid_ config reload will display it.
end)

w.on("window-config-reloaded", function(win, _)
  if w.GLOBAL.want_reload_notification then
    win:toast_notification("wezterm", "Config successfully reloaded!", nil, 1000)
    w.GLOBAL.want_reload_notification = false
  end
end)

return cfg
