-- Pull in the wezterm API
local wezterm = require 'wezterm'

-- This will hold the configuration.
local config = wezterm.config_builder()

config.enable_tab_bar = false
config.font = wezterm.font('Terminess Nerd Font Mono')
config.font_size = 14
-- This is where you actually apply your config choices

-- For example, changing the color scheme:
config.color_scheme = 'nord'

-- and finally, return the configuration to wezterm
return config
