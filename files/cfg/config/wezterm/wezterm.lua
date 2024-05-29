local w = require("wezterm")
local utils = require("utils")

local cfg = {}
if w.config_builder then
  cfg = w.config_builder()
end

w.on("update-right-status", function(window, _pane)
  window:set_right_status(window:active_workspace())
end)

cfg.disable_default_key_bindings = true
cfg.automatically_reload_config = false
cfg.audible_bell = "Disabled"
cfg.window_close_confirmation = "NeverPrompt"
-- cfg.enable_wayland = true

local full_cfg = utils.tbl_merge_all(cfg, require("cfg_appearance"), require("cfg_fonts"), require("cfg_keys"), {})
return full_cfg
