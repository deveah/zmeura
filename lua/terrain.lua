
--  terrain.lua
--  Terrain data.

return {
  ["void"] = {
    name = "Void",
    description = "Nothing. It's probably a bug.",  
    face = " ",
    color = curses.black,
    solid = true,
    opaque = false,
    breakable = false
  },
  ["grass"] = {
    name = "Grass",
    description = "Green grass.",
    face = ".",
    color = curses.green,
    solid = false,
    opaque = false,
    breakable = false
  },
  ["tall-grass"] = {
    name = "Tall grass",
    description = "Tall grass. It's harder to see through it.",
    face = ";",
    color = curses.green,
    solid = false,
    opaque = true,
    breakable = false
  },
  ["dirt"] = {
    name = "Dirt",
    description = "It's dirt. Everybody knows what dirt is.",
    face = ".",
    color = curses.yellow,
    solid = false,
    opaque = false,
    breakable = false
  },
  ["tree"] = {
    name = "Tree",
    description = "A tree. Oak, or something.",
    face = "7",
    color = curses.green,
    solid = true,
    opaque = true,
    breakable = true,
    hitPoints = 10,
    breaksInto = "dirt"
  },
  ["small-tree"] = {
    name = "Small tree",
    description = "A tree's baby tree.",
    face = "1",
    color = curses.green + curses.bold,
    solid = true,
    opaque = false,
    breakable = true,
    hitPoints = 3,
    breaksInto = "dirt"
  },
  ["puddle"] = {
    name = "Puddle",
    description = "A small puddle of water. Seems fresh.",
    face = "~",
    color = curses.blue,
    solid = false,
    opaque = false,
    breakable = false,
    uses = 3  -- you can drink three times from a puddle before it vanishes
  }
}

-- vim: set ts=2 sw=2:
