-- Pull in the wezterm API
local wezterm = require("wezterm")

-- This will hold the configuration.
local config = wezterm.config_builder()

-- This is where you actually apply your config choices

-- For example, changing the color scheme:
config.color_scheme = "nord"

config.window_background_opacity = 0.95

config.font = wezterm.font("Hack Nerd Font Mono")

-- and finally, return the configuration to wezterm
return config
