-- Pull in the wezterm API
local wezterm = require 'wezterm'

-- This table will hold the configuration.
local config = {}

-- In newer versions of wezterm, use the config_builder which will
-- help provide clearer error messages
if wezterm.config_builder then
  config = wezterm.config_builder()
end

config.front_end = "OpenGL" -- I have no idea, wezterm is just slow on any CPU and on any GPU
config.font = wezterm.font('JetBrainsMono NF')
config.font_size = 12
config.use_fancy_tab_bar = false
config.default_cursor_style = 'SteadyBar'
config.hide_tab_bar_if_only_one_tab = true
config.window_background_opacity = 0.8
config.colors = require 'colors'
config.window_padding = {
  left = 0,
  right = 0,
  top = 0,
  bottom = 0,
}


return config
