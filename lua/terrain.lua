
--	terrain.lua
--	Terrain data.

return {
	["void"] = {
		name = "Void",
		description = "Nothing. It's probably a bug.",	
		face = " ",
		color = curses.black,
		solid = true,
		opaque = false
	},
	["floor"] = {
		name = "Floor",
		description = "You walk on it. It's that simple.",
		face = ".",
		color = curses.white,
		solid = false,
		opaque = false
	},
	["wall"] = {
		name = "Wall",
		description = "A solid, concrete wall.",
		face = "#",
		color = curses.white,
		solid = true,
		opaque = true
	}
}

-- vim: set ts=2 sw=2:
