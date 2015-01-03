
--  map.lua
--  Map prototype and related functions;
--  A map holds data about a level - terrain data, mostly.

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
  for i = 1, width do
    m.tile[i] = {}
    for j = 1, height do
      m.tile[i][j] = {}
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

--  Map:setTile - sets the tile at position (x, y); if the coordinates are out
--  of bounds, it does nothing
--  x, y:  the coordinates
--  tile:  the tile to be put at the specified location
function Map:setTile(x, y, tile)
  if not self:isLegal(x, y) then
    return nil
  end

  self.tile[x][y] = tile
end

--  Map:isSolid - checks if a position on the map is solid
--  x, y: the coordinates of the tile
function Map:isSolid(x, y)
  --  an out-of-bounds tile is considered solid
  if not self:isLegal(x, y) then
    return true
  end

  --  return the tile's 'solid' characteristic
  return self.tile[x][y].solid
end

--  Map:fill - fills the whole map with a single terrain tile
--  tile: which tile to fill the map with
function Map:fill(tile)
  for i = 1, self.width do
    for j = 1, self.height do
      self.tile[i][j] = tile
    end
  end
end

return Map

-- vim: set ts=2 sw=2:
