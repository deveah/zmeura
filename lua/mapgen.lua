
--  mapgen.lua
--  Map generator algorithms and related functions.

local Terrain = require "lua/terrain"

local Mapgen = {}

--  Mapgen.fill - fills the whole map with a single terrain tile
--  map: the map to work on
--  tile: which tile to fill the map with
function Mapgen.fill(map, tile)
  for i = 1, map.width do
    for j = 1, map.height do
      map:setTile(i, j, tile)
    end
  end
end

--  Mapgen.randomFill - fills the provided map with all availible terrain
--  types (except for 'void' terrain), uniformly random
--  map: the map to work on
function Mapgen.randomFill(map)
  local tileTypes = {}
  for k, v in pairs(Terrain) do
    if k ~= "void" then
      table.insert(tileTypes, v)
    end
  end

  for i = 1, map.width do
    for j = 1, map.height do
      map:setTile(i, j, tileTypes[math.random(1, #tileTypes)])
    end
  end
end

--  Mapgen.forest - generates a forest on the provided map
--  map:              the map to work on
--  treeDensity:      chance to place a tree
--  grassDensity:     chance to place grass (place dirt otherwise)
--  puddleDensity:    chance to place a puddle of water
--  berryBushDensity: chance to place a berry bush
function Mapgen.forest(map, treeDensity, grassDensity, puddleDensity, berryBushDensity)
  for i = 1, map.width do
    for j = 1, map.height do
      if math.random() < treeDensity then
        if math.random() < 0.5 then
          map:setTile(i, j, Terrain["tree"])
        else
          map:setTile(i, j, Terrain["small-tree"])
        end
      else
        map:setTile(i, j, Terrain["dirt"])
        if math.random() < grassDensity then
          if math.random() < 0.8 then
            map:setTile(i, j, Terrain["grass"])
          else
            map:setTile(i, j, Terrain["tall-grass"])
          end
        end
      end
    end
  end

  --  puddles and bushes come over the layer of grass, and since they're pretty
  --  rare, they don't affect much the densities of grass/dirt
  for i = 1, map.width do
    for j = 1, map.height do
      if math.random() < puddleDensity then
        map:setTile(i, j, Terrain["puddle"])
      end
      if math.random() < berryBushDensity then
        map:setTile(i, j, Terrain["berry-bush"])
      end
    end
  end
end

return Mapgen

--  vim: ts=2 sw=2:
