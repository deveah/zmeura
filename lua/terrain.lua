
--  terrain.lua
--  Terrain data.

--  flag/attribute explanation:
--  solid: blocks movement
--  opaque: blocks vision
--  breakable: (only if solid) whether or not the tile can be destroyed
--    hitPoints: the amount of damage needed to break it
--    breaksInto: the tile it transforms into when broken
--  uses: the number of uses the tile holds (see Actor:useTerrain)

return {
  ["void"] = {
    name = "Void",
    description = "Nothing. It's probably a bug.",  
    face = " ",
    color = curses.black,
    solid = true,
    opaque = false
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
    uses = 3  -- you can drink three times from a puddle before it vanishes
  },
  ["berry-bush"] = {
    name = "Berry bush",
    description = "A bush containing some kind of berries. I bet they're edible.",
    face = "%",
    color = curses.magenta,
    solid = false,
    opaque = true
    --  the berry bush can only be used once, so don't bother memorising uses
  },
  ["bush"] = {
    name = "Bush",
    description = "A berry bush, although it has no berries right now.",
    face = "%",
    color = curses.green,
    solid = false,
    opaque = true
  }
}

-- vim: set ts=2 sw=2:
