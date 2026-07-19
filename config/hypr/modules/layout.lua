-- ~/.config/hypr/modules/layouts.lua
-- Layout-specific settings. "general.layout" (set in appearance.lua)
-- decides which of these is actually active.

-- Ref https://wiki.hypr.land/Configuring/Basics/Workspace-Rules/
-- "Smart gaps" / "No gaps when only" -- uncomment to use
-- hl.workspace_rule({ workspace = "w[tv1]", gaps_out = 0, gaps_in = 0 })
-- hl.workspace_rule({ workspace = "f[1]",   gaps_out = 0, gaps_in = 0 })
-- hl.window_rule({
--     name  = "no-gaps-wtv1",
--     match = { float = false, workspace = "w[tv1]" },
--     border_size = 0,
--     rounding    = 0,
-- })
-- hl.window_rule({
--     name  = "no-gaps-f1",
--     match = { float = false, workspace = "f[1]" },
--     border_size = 0,
--     rounding    = 0,
-- })

-- See https://wiki.hypr.land/Configuring/Layouts/Dwindle-Layout/
hl.config({
	dwindle = {
		preserve_split = true,
	},
})

-- See https://wiki.hypr.land/Configuring/Layouts/Master-Layout/
hl.config({
	master = {
		new_status = "master",
		mfact = 0.60,
		orientation = "left",
	},
})

-- See https://wiki.hypr.land/Configuring/Layouts/Scrolling-Layout/
hl.config({
	scrolling = {
		fullscreen_on_one_column = true,
	},
})
