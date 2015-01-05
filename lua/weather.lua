
--  weather.lua
--  Weather prototype and related functions

--  TODO: weather cycles by chance seem strange; maybe take turns using random
--  expiration times (eg. 100 turns rain, 400 turns sunny, 60 turns rain etc.)

local Terrain = require "lua/terrain"

local Weather = {}
Weather.__index = Weather

--  Weather.new - creates a new Weather object
--  gameInstance: game instance this object is attached to
--  map:          the map the weather takes effect on
--  state:        state to start from
function Weather.new(gameInstance, map, state)
  local w = {}
  setmetatable(w, Weather)

  w.gameInstance = gameInstance
  w.map = map
  w.state = state

  --  time since current state has been started
  w.currentTime = 0

  return w
end

--  Weather:takeEffect - alters the current map in a weather type-dependant
--  way and advances internal state
function Weather:takeEffect()
  --  advance weather clock
  self.currentTime = self.currentTime + 1

  if self.state == "sunny" then
    --  puddles slowly evaporate, their number of uses decreasing; this happens
    --  with a chance of 5% per pond, per 10 weather turns
    for i = 1, self.map.width do
      for j = 1, self.map.height do
        if  self.map:getTile(i, j).name == "Puddle" and math.random() < 0.05 and
            self.currentTime % 10 == 0 then
          self.map:modifyTileUses(i, j, -1)
        end
      end
    end
  elseif self.state == "raining" then
    --  create puddles
    for i = 1, self.map.width do
      for j = 1, self.map.height do
        --  there's a 0.05% chance to produce a puddle on any given tile
        --  puddling only works once per 10 weather turns
        if  self.map:getTile(i, j).name ~= "Puddle" and math.random() < 0.0005 and
            self.currentTime % 10 == 0 then
          self.map:setTile(i, j, Terrain["puddle"])
        end
      end
    end
  end
end

--  Weather:cycle - cycles the weather
function Weather:cycle()
  if self.state == "sunny" then
    --  there's a 1% chance it'll rain
    if math.random() < 0.01 then
      self.state = "raining"
      self.currentTime = 0

      --  announce the change of weather
      self.gameInstance:announce("It started raining.", curses.yellow + curses.bold)
      return true
    end
  elseif self.state == "raining" then
    --  there's a 1% it'll stop raining
    if math.random() < 0.01 then
      self.state = "sunny"
      self.currentTime = 0

      --  announce the change of weather
      self.gameInstance:announce("It stopped raining.", curses.yellow + curses.bold)
      return true
    end
  end
end

return Weather

--  vim: set ts=2 sw=2:
