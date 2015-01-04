
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
  self.modifier[x][y] = {}

  --  the hit points are reset to default
  if self.tile[x][y].hitPoints then
    self.modifier[x][y].hitPoints = self.tile[x][y].hitPoints
  end

  --  the uses are set to maximum
  if self.tile[x][y].uses then
    self.modifier[x][y].uses = self.tile[x][y].uses
  end
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

--  Map:getTileUses - returns the number of uses left in a tile
--  x, y: the coordinates of the tile
function Map:getTileUses(x, y)
  if not self:isLegal(x, y) then
    return nil
  end

  if not self.modifier[x][y].uses then
    return nil
  end

  return self.modifier[x][y].uses
end

--  Map:modifyTileUses - changes the amount of uses a tile has left by a
--  specified amount; doesn't check for anything but bounds; returns true if
--  the tile has been changed to something else, and false otherwise
--  quantity: the amount to modify by; can be either positive or negative
function Map:modifyTileUses(x, y, quantity)
  if not self:isLegal(x, y) then
    return false
  end

  self.modifier[x][y].uses = self.modifier[x][y].uses + quantity

  --  if the tile is out of uses, transform it
  if self.modifier[x][y].uses <= 0 then
    local t = self:getTile(x, y)
    if t.name == "Berry bush" then
      self:setTile(x, y, Terrain["bush"])
      return true
    end
    if t.name == "Puddle" then
      --  20% chance to turn into dirt, 80% chance to turn into grass
      if math.random() < 0.2 then
        self:setTile(x, y, Terrain["dirt"])
      else
        self:setTile(x, y, Terrain["grass"])
      end
      return true
    end
  end

  return false
end

return Map

-- vim: set ts=2 sw=2:
