
--  terrain.lua
--  Terrain data.

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
  },
  ["grass"] = {
    name = "Grass",
    description = "Green grass.",
    face = ".",
    color = curses.green,
    solid = false,
    opaque = false
  },
  ["tall-grass"] = {
    name = "Tall grass",
    description = "Tall grass. It's harder to see through it.",
    face = ";",
    color = curses.green,
    solid = false,
    opaque = true
  },
  ["dirt"] = {
    name = "Dirt",
    description = "It's dirt. Everybody knows what dirt is.",
    face = ".",
    color = curses.yellow,
    solid = false,
    opaque = false
  },
  ["tree"] = {
    name = "Tree",
    description = "A tree. Oak, or something.",
    face = "7",
    color = curses.green,
    solid = true,
    opaque = true
  },
  ["small-tree"] = {
    name = "Small tree",
    description = "A tree's baby tree.",
    face = "1",
    color = curses.green + curses.bold,
    solid = true,
    opaque = false
  }
}

-- vim: set ts=2 sw=2:
