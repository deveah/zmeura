
--  map.lua
--  Map prototype and related functions;
--  A map holds data about a level - terrain data, mostly.

local Terrain = require "lua/terrain"

local Map = {}
Map.__index = Map

--  Map.new - creates a new Map object
--  width:  the width of the map
--  height:  the height of the map
function Map.new(width, height)
  local m = {}
  setmetatable(m, Map)

  --  width and height of the map
  m.width = width
  m.height = height

  --  Game instance this Map object is attached to
  m.gameInstance = nil

  --  terrain data
  m.tile = {}

  --  memory data - what the player has seen before
  m.memory = {}

  --  terrain modifiers - hit points etc.
  m.modifier = {}

  for i = 1, width do
    m.tile[i] = {}
    m.memory[i] = {}
    m.modifier[i] = {}
    for j = 1, height do
      m.tile[i][j] = nil
      m.memory[i][j] = nil
      m.modifier[i][j] = {}
    end
  end

  return m
end

--  Map:isLegal - checks whether a pair of coordinates is in map bounds
--  x, y: the coordinates
function Map:isLegal(x, y)
  return x > 0 and y > 0 and x <= self.width and y <= self.height
end

--  Map:getTile - returns the tile at position (x, y) or nil, if the
--  coordinates are out of bounds
--  x, y: the coordinates
function Map:getTile(x, y)
  if not self:isLegal(x, y) then
    return nil
  end

  return self.tile[x][y]
end

--  Map:getMemorisedTile - returns the tile at position (x, y) from memory,
--  or nil, if the coordinates are out of bounds
--  x, y: the coordinates
function Map:getMemorisedTile(x, y)
  if not self:isLegal(x, y) then
    return nil
  end

  return self.memory[x][y]
end

--  Map:setTile - sets the tile at position (x, y); if the coordinates are out
--  of bounds, it does nothing
--  x, y:  the coordinates
--  tile:  the tile to be put at the specified location
function Map:setTile(x, y, tile)
  if not self:isLegal(x, y) then
    return nil
  end

  self.tile[x][y] = tile
  
  --  update modifier tables

  --  the hit points are reset to default
  self.modifier[x][y].hitPoints = self.tile[x][y].hitPoints
end

--  Map:isSolid - checks if a position on the map is solid (blocks movement)
--  x, y: the coordinates of the tile
function Map:isSolid(x, y)
  --  an out-of-bounds tile is considered solid
  if not self:isLegal(x, y) then
    return true
  end

  --  return the tile's 'solid' characteristic
  return self.tile[x][y].solid
end

--  Map:isBreakable - checks if a position on the map is breakable (solid, but
--  with enough damage, transforms into another terrain type)
--  x, y: the coordinates of the tile
function Map:isBreakable(x, y)
  --  an out-of-bounds tile is considered unbreakable
  if not self:isLegal(x, y) then
    return false
  end

  return self.tile[x][y].breakable
end

--  Map:isOpaque - checks if a position on the map is opaque (blocks vision)
--  x, y: the coordinates of the tile
function Map:isOpaque(x, y)
  --  an out-of-bounds tile is considered opaque
  if not self:isLegal(x, y) then
    return true
  end

  --  return the tile's 'opaque' characteristic
  return self.tile[x][y].opaque
end

--  Map:damageTile - damages a tile; if the tile remains out of hit points,
--  transforms it into its 'damaged' variant; returns true if the terrain has
--  been destroyed, and false otherwise
--  x, y:     the coordinates of the tile to receive damage
--  quantity: how much damage to deal
function Map:damageTile(x, y, quantity)
  local L = self.gameInstance.log
  
  --  can't damage out-of-bounds tiles
  if not self:isLegal(x, y) then
    L:write("ERR: Attempt to damage an out-of-bounds tile.\n")
    return false
  end

  --  can't damage unbreakable tiles
  if not self:isBreakable(x, y) then
    L:write("ERR: Attempt to damage an unbreakable tile.\n")
    return false
  end

  --  deal the damage
  self.modifier[x][y].hitPoints = self.modifier[x][y].hitPoints - quantity
  --  manage the transformation
  if self.modifier[x][y].hitPoints <= 0 then
    L:write("Tile " .. x .. ", " .. y .. " (" .. self:getTile(x, y).name ..
      ") of map " .. tostring(self) .. " broke into " ..
      self:getTile(x, y).breaksInto .. ".\n")
    self:setTile(x, y, Terrain[self:getTile(x, y).breaksInto])
    return true
  end
end

return Map

-- vim: set ts=2 sw=2:
