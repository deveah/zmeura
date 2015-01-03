
--  mapgen.lua
--  Map generator algorithms and related functions.

local Terrain = require "lua/terrain"

local Mapgen = {}

--  Mapgen.randomFill - fills the provided map with all availible terrain
--  types, uniformly random
--  map: the map to work on
function Mapgen.randomFill(map)
  local tileTypes = {}
  for _, v in pairs(Terrain) do
    table.insert(tileTypes, v)
  end

  for i = 1, map.width do
    for j = 1, map.height do
      map:setTile(i, j, tileTypes[math.random(1, #tileTypes)])
    end
  end
end

return Mapgen

--  vim: ts=2 sw=2:
