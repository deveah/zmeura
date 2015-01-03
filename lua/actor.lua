
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

  --  the game instance this actor is attached to
  a.gameInstance = nil

  return a
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

  --  system keys
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
    L:write("\tActor tried to move onto a solid tile.\n")
    return false
  end

  --  finally, update the actor's coordinates and return that it has moved
  self.x = self.x + dx
  self.y = self.y + dy
  L:write("Ok.\n")
  return true
end

return Actor

-- vim: set ts=2 sw=2:
