
--  actor.lua
--  Actor prototype and related functions;
--  An actor is a live being who has the right to act when prompted by the
--  game loop.

local Actor = {}
Actor.__index = Actor

--  Actor.new - creates a new Actor object
--  name:      name of the actor
--  face:      how the actor looks on a map
--  color:     the color of the actor on a map
function Actor.new(name, face, color)
  local a = {}
  setmetatable(a, Actor)

  --  name of the actor
  a.name = name

  --  how the actor looks in-game
  a.face = face
  a.color = color

  --  whether the actor is controlled by the player
  a.isPlayer = false

  --  coordinates the actor is currently on
  a.x = 0
  a.y = 0
  a.map = nil

  --  the sightMap is an array as big as the map the actor currently is on,
  --  and holds information about the visibility of the tiles
  a.sightMap = nil

  --  the game instance this actor is attached to
  a.gameInstance = nil

  return a
end

--  Actor:resetSightMap - resizes the sight map to fit the map the actor
--  currently is on, setting everything to 'not seen'
function Actor:resetSightMap()
  self.sightMap = {}
  for i = 1, self.map.width do
    self.sightMap[i] = {}
    for j = 1, self.map.height do
      self.sightMap[i][j] = false
    end
  end
end

--  Actor:updateFieldOfView - resets the actor's sight map, and then
--  recalculates the field of view
function Actor:updateFieldOfView()
  --  doRay - trace a ray from (startX, startY) at an angle of `angle'
  --  over a distance of `distance'; tracing stops when the ray hits either
  --  an out-of-bounds tile, or an opaque one
  local function doRay(startX, startY, angle, distance)
    --  a tile's center is at (+0.5, +0.5)
    local cx, cy = startX + 0.5, startY + 0.5
    local dx = math.cos(angle * math.pi / 180)
    local dy = math.sin(angle * math.pi / 180)

    --  starting position is always visible
    self.sightMap[startX][startY] = true
      
    for i = 1, distance do
      cx = cx + dx
      cy = cy + dy

      if not self.map:isLegal(math.floor(cx), math.floor(cy)) then
        return false
      end

      --  mark that this tile can be seen from the actor's point of view
      self.sightMap[math.floor(cx)][math.floor(cy)] = true

      --  the player's sight map has memory, so be sure to update the memory
      if self.isPlayer then
        self.map.memory[math.floor(cx)][math.floor(cy)] = self.map.tile[math.floor(cx)][math.floor(cy)]
      end

      if self.map:isOpaque(math.floor(cx), math.floor(cy)) then
        return false
      end
    end
  end

  --  clear the old sight map
  self:resetSightMap()

  --  trace rays in a circle using 1 degree increments
  for i = 0, 360, 0.1 do
    doRay(self.x, self.y, i, 10)
  end
end

--  Actor:inSight - checks whether the point (x, y) is seen from the actor's
--  point of view
--  x, y: coordinates of the point
function Actor:inSight(x, y)
  --  nonexistant tiles cannot be seen
  if not self.map:isLegal(x, y) then
    return false
  end

  return self.sightMap[x][y]
end

--  Actor:handleKey - acts according to the key provided; returns true if the
--  action has been successfully performed, or false otherwise
--  key: the key to translate into an action
function Actor:handleKey(key)
  local L = self.gameInstance.log
  L:write("Actor " .. tostring(self) .. " handleKey: " .. key .. "\n")

  --  movement keys
  if key == "h" then
    return self:moveRelative(-1, 0)
  end
  if key == "j" then
    return self:moveRelative(0, 1)
  end
  if key == "k" then
    return self:moveRelative(0, -1)
  end
  if key == "l" then
    return self:moveRelative(1, 0)
  end

  --  look/examine key
  if key == "x" then
    self.gameInstance:lookAt(self.x, self.y)

    --  looking around doesn't spend a turn
    return false
  end

  --  quit key
  if key == "q" then
    --  exit the game loop abruptly
    self.gameInstance.running = false

    L:write("Actor " .. tostring(self) .. " requested a game exit.\n")

    --  although no action is performed by the actor, signaling that there has
    --  been one allows the game loop to leave the actor alone and handle its
    --  own shutdown
    return true
  end

  --  no known action matched the key provided, so assume nothing could have
  --  been done and return that nothing has been performed
  return false
end

--  Actor:moveRelative - changes the actor's coordinates relatively; returns
--  a boolean telling us if the action has been performed or not
--  dx, dy: the relative coordinates
function Actor:moveRelative(dx, dy)
  local L = self.gameInstance.log
  L:write("Actor " .. tostring(self) .. " moveRelative: " .. dx .. ", " .. dy .. ".\n")

  --  check first if the desired coordinate is in bounds for the map the actor
  --  is currently on
  if not self.map:isLegal(self.x+dx, self.y+dy) then
    L:write("\tOut of bounds movement.\n")
    return false
  end

  --  check if the desired coordinate is not solid (it can be moved upon)
  if self.map:isSolid(self.x+dx, self.y+dy) then
    if self.map:isBreakable(self.x+dx, self.y+dy) then
      local oldName = self.map:getTile(self.x+dx, self.y+dy).name

      --  let the user know he/she is dealing damage to a tree or something
      if self.isPlayer then
        self.gameInstance:announce("You hit the " .. oldName .. "!")
      end

      L:write("\tActor hit " .. oldName .. ".\n")
      if self.map:damageTile(self.x+dx, self.y+dy, 1) then
        --  let the user know he/she destroyed the terrain
        if self.isPlayer then
          self.gameInstance:announce("You destroy the " .. oldName .. "!")
        end
      end
      return true
    end

    L:write("\tActor tried to move onto a solid, unbreakable tile.\n")
    return false
  end

  --  finally, update the actor's coordinates and return that it has moved
  self.x = self.x + dx
  self.y = self.y + dy
  L:write("\tOk.\n")
  return true
end

return Actor

-- vim: set ts=2 sw=2:
