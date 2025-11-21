-- ~/.wezterm.lua
-- Lovecraft / Mike Fisher - WezTerm Config
-- Replaces tmux + sesh with native WezTerm workspaces
local wezterm = require("wezterm")
local act = wezterm.action
local mux = wezterm.mux
local config = wezterm.config_builder()

-- ==== THEME ====
config.color_scheme = "Catppuccin Macchiato"
config.window_background_opacity = 0.98
config.macos_window_background_blur = 10

-- Font configuration (matching Ghostty)
config.font = wezterm.font_with_fallback({
	"JetBrainsMono Nerd Font",
	"JetBrains Mono",
	"Noto Color Emoji",
})
config.font_size = 18.0

-- Split styling / "unfocused split opacity"
config.inactive_pane_hsb = { saturation = 1.0, brightness = 0.5 }
config.colors = { split = "#33008a" }

-- Close behavior (no "are you sure?")
config.window_close_confirmation = "NeverPrompt"
config.skip_close_confirmation_for_processes_named = { "bash", "zsh", "fish", "tmux", "nvim", "vim", "sh" }

-- ==== APPEARANCE ====
config.window_padding = { left = 4, right = 4, top = 8, bottom = 8 }
config.default_cursor_style = "SteadyBlock"

-- Minimal UI: Hide tab bar when only one tab (like Ghostty)
config.hide_tab_bar_if_only_one_tab = true
config.use_fancy_tab_bar = false

-- Remove window decorations for minimal look
config.window_decorations = "RESIZE"

-- Shell integration: detect cursor changes, sudo prompts, etc.
config.detect_password_input = true

-- ==== MOUSE ====
config.hide_mouse_cursor_when_typing = true

-- Focus follows mouse for better split navigation (Ghostty-like)
config.pane_focus_follows_mouse = true

-- Explicit "copy on select" to Clipboard (Ghostty-like)
config.mouse_bindings = {
	{ event = { Up = { streak = 1, button = "Left" } }, mods = "NONE", action = act.CompleteSelection("Clipboard") },
	{ event = { Down = { streak = 1, button = "Left" } }, mods = "NONE", action = act.Nop },
	{ event = { Up = { streak = 1, button = "Left" } }, mods = "CTRL", action = act.OpenLinkAtMouseCursor },
	{ event = { Down = { streak = 1, button = "Left" } }, mods = "CTRL", action = act.Nop },
}

-- ==== PERFORMANCE ====
config.scrollback_lines = 9000000
config.front_end = "WebGpu"
config.max_fps = 120
config.audible_bell = "Disabled"

-- macOS specific: Option key as Alt (Ghostty-like)
config.send_composed_key_when_left_alt_is_pressed = false
config.send_composed_key_when_right_alt_is_pressed = false

-- ==== SIMPLE PANE NAVIGATION ====
-- CTRL+H/J/K/L to navigate WezTerm panes
-- Use CTRL+W then H/J/K/L to navigate Neovim splits (Neovim default)

-- ==== WORKSPACE DEFINITIONS (replaces sesh.toml) ====
local project_workspaces = {
	{
		id = "listium",
		label = "⚡ listium",
		path = wezterm.home_dir .. "/dev/personal/listium",
		tabs = {
			{ name = "dev", command = "nvim ." },
			{ name = "claude", command = "claude" },
			{ name = "codex", command = "codex" },
			{ name = "git", command = "gt log" },
			{ name = "tasks" },
			{ name = "scripts" },
		},
	},
	{
		id = "tmux-config",
		label = "⚙️  tmux config",
		path = wezterm.home_dir .. "/.config/tmux",
		tabs = {
			{ name = "sesh-settings", command = "lv " .. wezterm.home_dir .. "/.config/sesh/sesh.toml" },
			{ name = "tmux-settings", command = "lv tmux.conf" },
			{ name = "tmux-reset", command = "lv tmux.reset.conf" },
			{ name = "git", command = "gt log" },
		},
	},
	{
		id = "scratch",
		label = "📝 scratch",
		path = wezterm.home_dir .. "/dev/scratch",
		tabs = {
			{ name = "notes", command = "nvim notes.md" },
			{ name = "experiments", command = "nvim" },
			{ name = "shell" },
		},
	},
	{
		id = "wezterm-config",
		label = "⚡ wezterm config",
		path = wezterm.home_dir .. "/.config/wezterm",
		tabs = {
			{ name = "config", command = "nvim wezterm.lua" },
			{ name = "git", command = "gt log" },
		},
	},
}

-- Function to spawn a workspace with multiple tabs
local function spawn_project_workspace(workspace_config)
	local tab, pane, window = mux.spawn_window({
		workspace = workspace_config.id,
		cwd = workspace_config.path,
	})

	-- Set up first tab
	if workspace_config.tabs[1] then
		tab:set_title(workspace_config.tabs[1].name)
		if workspace_config.tabs[1].command then
			pane:send_text(workspace_config.tabs[1].command .. "\n")
		end
	end

	-- Create remaining tabs
	for i = 2, #workspace_config.tabs do
		local tab_config = workspace_config.tabs[i]
		local new_tab, new_pane, _ = window:spawn_tab({
			cwd = workspace_config.path,
		})
		new_tab:set_title(tab_config.name)

		if tab_config.command then
			new_pane:send_text(tab_config.command .. "\n")
		end
	end

	-- Activate the first tab
	mux.get_window(window:window_id()):gui_window():activate()
	window:tabs()[1]:activate()
end

-- ==== WORKSPACE HELPERS ====
-- Get current workspace name for status line
wezterm.on("update-status", function(window, pane)
	local workspace = window:active_workspace()
	local cwd = pane:get_current_working_dir()
	local cwd_path = ""

	if cwd then
		cwd_path = cwd.file_path:gsub(wezterm.home_dir, "~")
	end

	-- Display workspace name in status line
	window:set_right_status(wezterm.format({
		{ Foreground = { Color = "#8aadf4" } },
		{ Text = " ⚡ " .. workspace .. " " },
		{ Foreground = { Color = "#6e738d" } },
		{ Text = " | " },
		{ Foreground = { Color = "#f5a97f" } },
		{ Text = " " .. cwd_path .. " " },
	}))
end)

-- ==== KEYBINDINGS ====
config.keys = {
	-- ===== PANES (like tmux splits) =====
	-- Split panes (inherit current directory like your tmux config)
	{
		key = "d",
		mods = "CMD",
		action = act.SplitVertical({ domain = "CurrentPaneDomain" }),
	},
	{
		key = "D",
		mods = "CMD|SHIFT",
		action = act.SplitHorizontal({ domain = "CurrentPaneDomain" }),
	},

	-- Navigate panes with CTRL+h/j/k/l
	-- (In Neovim, use CTRL+W then h/j/k/l for vim splits)
	{ key = "h", mods = "CTRL", action = act.ActivatePaneDirection("Left") },
	{ key = "j", mods = "CTRL", action = act.ActivatePaneDirection("Down") },
	{ key = "k", mods = "CTRL", action = act.ActivatePaneDirection("Up") },
	{ key = "l", mods = "CTRL", action = act.ActivatePaneDirection("Right") },

	-- Resize panes (like your tmux ,.-= bindings)
	{ key = "LeftArrow", mods = "CMD|SHIFT", action = act.AdjustPaneSize({ "Left", 5 }) },
	{ key = "RightArrow", mods = "CMD|SHIFT", action = act.AdjustPaneSize({ "Right", 5 }) },
	{ key = "DownArrow", mods = "CMD|SHIFT", action = act.AdjustPaneSize({ "Down", 5 }) },
	{ key = "UpArrow", mods = "CMD|SHIFT", action = act.AdjustPaneSize({ "Up", 5 }) },

	-- Close current pane (like CMD+W in browsers)
	{ key = "w", mods = "CMD", action = act.CloseCurrentPane({ confirm = false }) },

	-- Zoom pane (like tmux prefix+z)
	{ key = "z", mods = "CMD", action = act.TogglePaneZoomState },

	-- ===== TABS (like tmux windows) =====
	-- New tab in current directory
	{ key = "t", mods = "CMD", action = act.SpawnTab("CurrentPaneDomain") },

	-- Navigate tabs with CMD+Shift+[ and ]
	{ key = "[", mods = "CMD|SHIFT", action = act.ActivateTabRelative(-1) },
	{ key = "]", mods = "CMD|SHIFT", action = act.ActivateTabRelative(1) },

	-- Move tabs around
	{ key = "{", mods = "CMD|SHIFT", action = act.MoveTabRelative(-1) },
	{ key = "}", mods = "CMD|SHIFT", action = act.MoveTabRelative(1) },

	-- ===== WORKSPACES (replaces tmux sessions + sesh) =====
	-- Fuzzy find and launch pre-configured workspace (like sesh connect with fzf)
	{
		key = "f",
		mods = "CMD",
		action = wezterm.action_callback(function(window, pane)
			local choices = {}
			for _, ws in ipairs(project_workspaces) do
				table.insert(choices, {
					id = ws.id,
					label = ws.label,
				})
			end

			window:perform_action(
				act.InputSelector({
					action = wezterm.action_callback(function(_, _, id, _)
						if not id then
							return
						end

						for _, ws in ipairs(project_workspaces) do
							if ws.id == id then
								spawn_project_workspace(ws)
								break
							end
						end
					end),
					title = "⚡ Select Workspace",
					choices = choices,
					fuzzy = true,
				}),
				pane
			)
		end),
	},

	-- Prompt to create/switch simple workspace (no tabs)
	{
		key = "s",
		mods = "CMD",
		action = act.PromptInputLine({
			description = "Enter workspace name:",
			action = wezterm.action_callback(function(window, pane, line)
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

	-- Create workspace from current directory (like your tmux project sessions)
	{
		key = "n",
		mods = "CMD",
		action = wezterm.action_callback(function(window, pane)
			local cwd = pane:get_current_working_dir()
			if cwd then
				local workspace_name = cwd.file_path:match("([^/]+)$")
				window:perform_action(
					act.SwitchToWorkspace({
						name = workspace_name,
						spawn = { cwd = cwd.file_path },
					}),
					pane
				)
			end
		end),
	},

	-- Switch between workspaces (like alt-tab but for workspaces)
	{ key = "o", mods = "CMD", action = act.SwitchWorkspaceRelative(1) },
	{ key = "o", mods = "CMD|SHIFT", action = act.SwitchWorkspaceRelative(-1) },

	-- List all workspaces
	{
		key = "w",
		mods = "CMD|SHIFT",
		action = act.ShowLauncherArgs({
			flags = "FUZZY|WORKSPACES",
			title = "⚡ Workspaces",
		}),
	},

	-- ===== UTILITY =====
	-- Copy Mode (vim-like navigation)
	{ key = "C", mods = "CMD|SHIFT", action = act.ActivateCopyMode },

	-- Quick Select (URLs, paths, etc.)
	{ key = ";", mods = "CMD", action = act.QuickSelect },

	-- Search scrollback
	{ key = "f", mods = "CMD|SHIFT", action = act.Search("CurrentSelectionOrEmptyString") },

	-- Reload config (like tmux prefix+R)
	{ key = "r", mods = "CMD|SHIFT", action = act.ReloadConfiguration },

	-- Command Palette
	{ key = "p", mods = "CMD|SHIFT", action = act.ActivateCommandPalette },

	-- New window inheriting CWD
	{
		key = "N",
		mods = "CMD|SHIFT",
		action = wezterm.action_callback(function(window, pane)
			local cwd_uri = pane:get_current_working_dir()
			local cwd = cwd_uri and cwd_uri.file_path or nil
			window:perform_action(act.SpawnCommandInNewWindow({ cwd = cwd }), pane)
		end),
	},
}

-- Trim trailing spaces on copy (Ghostty-like clipboard behavior)
table.insert(config.keys, 1, {
	key = "c",
	mods = "CMD",
	action = wezterm.action_callback(function(window, pane)
		local text = window:get_selection_text_for_pane(pane)
		if text and #text > 0 then
			text = text:gsub("[ \t]+(\r?\n)", "%1")
			window:copy_to_clipboard(text, "Clipboard")
			window:perform_action(act.ClearSelection, pane)
		else
			window:perform_action(act.CopyTo("Clipboard"), pane)
		end
	end),
})

return config
