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

-- and finally, return the configuration to wezterm
return config
