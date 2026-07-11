local wezterm = require("wezterm")
local config = wezterm.config_builder()

-- ui
config.color_scheme = "rose-pine-moon"
config.max_fps = 120
config.font = wezterm.font("Hack Nerd Font", { weight = "Regular" })

config.enable_tab_bar = true
config.hide_tab_bar_if_only_one_tab = true
config.window_decorations = "RESIZE"
config.window_frame = {
	font = wezterm.font("Hack Nerd Font", { weight = "Bold" }),
}

config.inactive_pane_hsb = {
	saturation = 0.0,
	brightness = 0.5,
}

-- mac-specific
config.window_background_opacity = 0.8
config.macos_window_background_blur = 50
config.font_size = 15.0
config.window_frame.font_size = 13.0
config.native_macos_fullscreen_mode = true

-- keys
local maximize_window = wezterm.action_callback(function(window, _pane)
	window:maximize()
end)

-- smart pane navigation:
-- 1. if focused pane is running nvim, forward the keystroke to nvim so its
--    own smart-splits plugin can handle it (and bounce back out at nvim's edges)
-- 2. otherwise, if there's a wezterm pane in that direction, move to it
-- 3. otherwise (no pane there, e.g. a single plain shell), let the raw
--    ctrl+key fall through to the shell -- so ctrl+l still clears, etc.
local function is_nvim(pane)
	local process_name = pane:get_foreground_process_name() or ""
	return process_name:find("nvim") ~= nil
end

local function nav_pane(key, direction)
	return wezterm.action_callback(function(window, pane)
		if is_nvim(pane) then
			window:perform_action(wezterm.action.SendKey({ key = key, mods = "CTRL" }), pane)
			return
		end

		local tab = pane:tab()
		local target = tab and tab:get_pane_direction(direction)
		if target then
			target:activate()
		else
			window:perform_action(wezterm.action.SendKey({ key = key, mods = "CTRL" }), pane)
		end
	end)
end

config.disable_default_key_bindings = true
config.leader = { key = "Space", mods = "CTRL" }

local resize_amount = 3

local function start_resize_pane(direction)
	return wezterm.action.Multiple({
		wezterm.action.ActivateKeyTable({
			name = "resize_pane",
			one_shot = false,
			timeout_milliseconds = 5000,
		}),
		wezterm.action.AdjustPaneSize({ direction, resize_amount }),
	})
end

-- stay in this mode after leader+shift+h/j/k/l so you can keep tapping
-- (with shift held) without re-pressing leader
config.key_tables = {
	resize_pane = {
		{ key = "h", action = wezterm.action.AdjustPaneSize({ "Left", resize_amount }) },
		{ key = "H", action = wezterm.action.AdjustPaneSize({ "Left", resize_amount }) },
		{ key = "j", action = wezterm.action.AdjustPaneSize({ "Down", resize_amount }) },
		{ key = "J", action = wezterm.action.AdjustPaneSize({ "Down", resize_amount }) },
		{ key = "k", action = wezterm.action.AdjustPaneSize({ "Up", resize_amount }) },
		{ key = "K", action = wezterm.action.AdjustPaneSize({ "Up", resize_amount }) },
		{ key = "l", action = wezterm.action.AdjustPaneSize({ "Right", resize_amount }) },
		{ key = "L", action = wezterm.action.AdjustPaneSize({ "Right", resize_amount }) },
		{ key = "Escape", action = "PopKeyTable" },
		{ key = "Enter", action = "PopKeyTable" },
	},
}

config.keys = {
	-- clipboard
	{
		key = "v",
		mods = "CMD",
		action = wezterm.action({ PasteFrom = "Clipboard" }),
	},
	{
		key = "c",
		mods = "CMD",
		action = wezterm.action({ CopyTo = "Clipboard" }),
	},

	-- window
	{
		key = "m",
		mods = "LEADER",
		action = maximize_window,
	},
	{
		key = "f",
		mods = "CMD",
		action = wezterm.action.ToggleFullScreen,
	},
	{
		key = "f",
		mods = "CTRL|CMD",
		action = wezterm.action.ToggleFullScreen,
	},
	{
		key = "w",
		mods = "CMD",
		action = wezterm.action.CloseCurrentTab({ confirm = false }),
	},
	{
		key = "q",
		mods = "CMD",
		action = wezterm.action.QuitApplication,
	},
	{
		key = "h",
		mods = "CMD",
		action = wezterm.action.HideApplication,
	},
	{
		key = "m",
		mods = "CMD",
		action = wezterm.action.Hide,
	},

	-- tabs
	{
		key = "t",
		mods = "CMD",
		action = wezterm.action.SpawnTab("CurrentPaneDomain"),
	},
	{
		key = "]",
		mods = "CMD",
		action = wezterm.action.ActivateTabRelative(1),
	},
	{
		key = "[",
		mods = "CMD",
		action = wezterm.action.ActivateTabRelative(-1),
	},
	{
		key = "Tab",
		mods = "CTRL",
		action = wezterm.action.ActivateTabRelative(1),
	},
	{
		key = "Tab",
		mods = "CTRL|SHIFT",
		action = wezterm.action.ActivateTabRelative(-1),
	},
	{
		key = "1",
		mods = "CMD",
		action = wezterm.action.ActivateTab(0),
	},
	{
		key = "2",
		mods = "CMD",
		action = wezterm.action.ActivateTab(1),
	},
	{
		key = "3",
		mods = "CMD",
		action = wezterm.action.ActivateTab(2),
	},
	{
		key = "4",
		mods = "CMD",
		action = wezterm.action.ActivateTab(3),
	},
	{
		key = "5",
		mods = "CMD",
		action = wezterm.action.ActivateTab(4),
	},
	{
		key = "1",
		mods = "LEADER",
		action = wezterm.action.ActivateTab(0),
	},
	{
		key = "2",
		mods = "LEADER",
		action = wezterm.action.ActivateTab(1),
	},
	{
		key = "3",
		mods = "LEADER",
		action = wezterm.action.ActivateTab(2),
	},
	{
		key = "4",
		mods = "LEADER",
		action = wezterm.action.ActivateTab(3),
	},
	{
		key = "5",
		mods = "LEADER",
		action = wezterm.action.ActivateTab(4),
	},

	-- panes: split
	{
		key = "h",
		mods = "LEADER",
		action = wezterm.action.SplitVertical({ domain = "CurrentPaneDomain" }),
	},
	{
		key = "v",
		mods = "LEADER",
		action = wezterm.action.SplitHorizontal({ domain = "CurrentPaneDomain" }),
	},
	{
		key = "x",
		mods = "CMD",
		action = wezterm.action.CloseCurrentPane({ confirm = false }),
	},
	{
		key = "z",
		mods = "LEADER",
		action = wezterm.action.TogglePaneZoomState,
	},

	-- panes: seamless navigation (also moves between nvim splits, and lets
	-- ctrl+l etc. fall through to the shell when there's no pane to move to)
	{
		key = "h",
		mods = "CTRL",
		action = nav_pane("h", "Left"),
	},
	{
		key = "l",
		mods = "CTRL",
		action = nav_pane("l", "Right"),
	},
	{
		key = "k",
		mods = "CTRL",
		action = nav_pane("k", "Up"),
	},
	{
		key = "j",
		mods = "CTRL",
		action = nav_pane("j", "Down"),
	},
	{
		key = "l",
		mods = "CTRL|SHIFT",
		action = wezterm.action.SendKey({ key = "l", mods = "CTRL" }),
	},

	-- panes: resize (single tap via arrow keys)
	{
		key = "LeftArrow",
		mods = "CMD|SHIFT",
		action = wezterm.action.AdjustPaneSize({ "Left", 5 }),
	},
	{
		key = "RightArrow",
		mods = "CMD|SHIFT",
		action = wezterm.action.AdjustPaneSize({ "Right", 5 }),
	},
	{
		key = "UpArrow",
		mods = "CMD|SHIFT",
		action = wezterm.action.AdjustPaneSize({ "Up", 5 }),
	},
	{
		key = "DownArrow",
		mods = "CMD|SHIFT",
		action = wezterm.action.AdjustPaneSize({ "Down", 5 }),
	},

	-- panes: resize (leader+shift+h/j/k/l enters resize mode and resizes once;
	-- keep holding shift and tap h/j/k/l repeatedly to keep resizing)
	{
		key = "h",
		mods = "LEADER|SHIFT",
		action = start_resize_pane("Left"),
	},
	{
		key = "j",
		mods = "LEADER|SHIFT",
		action = start_resize_pane("Down"),
	},
	{
		key = "k",
		mods = "LEADER|SHIFT",
		action = start_resize_pane("Up"),
	},
	{
		key = "l",
		mods = "LEADER|SHIFT",
		action = start_resize_pane("Right"),
	},

	-- workspaces (like "desktops" for separate projects)
	{
		key = "s",
		mods = "LEADER",
		action = wezterm.action.ShowLauncherArgs({ flags = "FUZZY|WORKSPACES" }),
	},
	{
		key = "n",
		mods = "LEADER",
		action = wezterm.action.PromptInputLine({
			description = "Name for new workspace",
			action = wezterm.action_callback(function(window, pane, line)
				if line and #line > 0 then
					window:perform_action(wezterm.action.SwitchToWorkspace({ name = line }), pane)
				end
			end),
		}),
	},

	-- font size
	{
		key = "=",
		mods = "CMD",
		action = wezterm.action.IncreaseFontSize,
	},
	{
		key = "-",
		mods = "CMD",
		action = wezterm.action.DecreaseFontSize,
	},
	{
		key = "0",
		mods = "CMD",
		action = wezterm.action.ResetFontSize,
	},

	-- misc
	{
		key = "k",
		mods = "CMD",
		action = wezterm.action.ClearScrollback("ScrollbackAndViewport"),
	},
	{
		key = "f",
		mods = "CMD|SHIFT",
		action = wezterm.action.Search({ CaseSensitiveString = "" }),
	},
	{
		key = "r",
		mods = "CMD|SHIFT",
		action = wezterm.action.ReloadConfiguration,
	},
}

return config
