local programs = require("modules.program")

hl.on("hyprland.start", function()
	hl.exec_cmd(programs.terminal)
	hl.exec_cmd("waybar & hyprpaper & firefox")
end)
