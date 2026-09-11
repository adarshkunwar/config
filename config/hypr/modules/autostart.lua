local programs = require("modules.program")

hl.on("hyprland.start", function()
	hl.exec_cmd(programs.terminal)
	hl.exec_cmd("waybar & hyprpaper & firefox")
	hl.exec_cmd("/usr/lib/polkit-kde-authentication-agent-1")
end)
