-- Pull in the wezterm API
local wezterm = require("wezterm")

-- This will hold the configuration.
local config = wezterm.config_builder()

-- This is where you actually apply your config choices

-- Change the color scheme
config.color_scheme = "nord"
config.window_background_opacity = 0.95

-- Change the font
config.font = wezterm.font("Hack Nerd Font Mono")
config.font_size = 13.0

-- Cmd+click opens a link on this machine, even inside tmux over SSH, where tmux has the
-- mouse and a plain click goes to it. mouse_reporting = true makes the binding apply while
-- the remote program is capturing the mouse; the Down binding keeps that click from reaching it.
config.mouse_bindings = {
  {
    event = { Up = { streak = 1, button = "Left" } },
    mods = "SUPER",
    action = wezterm.action.OpenLinkAtMouseCursor,
    mouse_reporting = true,
  },
  {
    event = { Down = { streak = 1, button = "Left" } },
    mods = "SUPER",
    action = wezterm.action.Nop,
    mouse_reporting = true,
  },
}

-- and finally, return the configuration to wezterm
return config
