
--  game.lua
--  Game prototype and related functions

local Actor = require "lua/actor"
local Map = require "lua/map"
local Mapgen = require "lua/mapgen"
local Terrain = require "lua/terrain"

local Game = {}
Game.__index = Game

--  Game.new - creates a new Game object
function Game.new()
  local g = {}
  setmetatable(g, Game)

  --  there's nothing here, since all the initialization needed takes place
  --  in Game:initialize()

  return g
end

--  Game:initialize - initializes the Game object, and creates a curses window
--  returns true if the game has been successfully initialized, false otherwise
function Game:initialize()
  --  the log that's used to output debugging data
  self.log = io.open("log.txt", "w")
  self.log:write("Logging started.\n")

  --  set a random seed and log it
  self.randomSeed = os.time()
  math.randomseed(self.randomSeed)
  self.log:write("Random seed is " .. self.randomSeed .. ".\n")

  --  game state lists
  self.actorList = {}
  self.itemList = {}
  self.mapList = {}

  --  this tells us if the game is currently inside the main loop
  self.running = false

  --  the player Actor object, so the game knows which actor to follow
  self.player = nil

  --  initialize a curses window, also getting the terminal window's size
  self.terminalWidth, self.terminalHeight = curses.init()

  --  we need at least an 80x25 terminal to work, so exit if that requirement
  --  isn't met, and let the user know of this issue
  if self.terminalWidth < 80 or self.terminalHeight < 25 then
    curses.terminate()
    print("Terminal window should be at least 80x25.")
    return false
  end

  --  log the terminal data
  self.log:write("Terminal is " .. self.terminalWidth .. "x" .. self.terminalHeight .. "\n")

  --  create an empty map (filled with floor tiles), and place it into the map list
  local tempMap = Map.new(100, 100)
  Mapgen.randomFill(tempMap)
  self:addMap(tempMap)

  --  create the player
  self.player = Actor.new("Player", "@", "white")
  self.player.isPlayer = true
  --  center the player on the map
  self.player.map = tempMap
  self.player.x = 50
  self.player.y = 50
  --  add the player into the actor list
  self:addActor(self.player)

  --  the camera focuses the view on a certain portion of the map;
  --  its coordinates designate the position which corresponds to the
  --  uppermost, leftmost square drawn;
  --  we center the camera on the player
  self.cameraX = self.player.x - 30
  self.cameraY = self.player.y - 10

  --  everything's all right, so continue the flow
  return true
end

--  Game:loop - the main action loop of the game, dealing with everything
--  from the actors' movements to updating the game state
function Game:loop()
  --  signal that we've entered the loop
  self.running = true
  self.log:write("Entered main loop.\n")

  --  loop through all the actors inside actorList, giving them a chance to act
  while self.running do
    for i = 1, #(self.actorList) do
      local a = self.actorList[i]
      self.log:write("Actor " .. tostring(a) .. " now acting.\n")

      if a.isPlayer then
        --  the actor is player-controlled, so update the screen, get input,
        --  and pass onto translating the keystroke into an action
        self:drawMainScreen()
        local k = curses.getch()
        a:handleKey(k)
      else
        --  no AI for now, so leave the actor alone
      end
    end
  end

  --  signal that we've left the loop; by now, something must have triggered
  --  self.running = false, so don't bother doing that again
  self.log:write("Exited main loop.\n")
end

--  Game:terminate - deals with cleaning up the resources allocated; should
--  be called after Game:loop() exits
function Game:terminate()
  self.log:write("Logging ended.\n")
  self.log:close()
end

--  Game:addActor - adds an actor into a Game object's (active) actor list
--  actor: the actor to be added
function Game:addActor(actor)
  table.insert(self.actorList, actor)
  actor.gameInstance = self
end

--  Game:removeActor - removes an actor from a Game object's (active) actor
--  list; warning: this function modifies the actorList table, so that calling
--  it when iterating over the table may cause serious bugs
--  actor: the actor to be removed
function Game:removeActor(actor)
  local index = 0
  for i = 1, #(self.actorList) do
    if self.actorList[i] == actor then
      index = i
    end
  end
  table.remove(self.actorList, index)
end

--  Game:addItem - adds an item into a Game object's item list
--  item: the item to be added
function Game:addItem(item)
  table.insert(self.itemList, item)
  item.gameInstance = self
end

--  Game:removeItem - removes an item from a Game object's item list; same
--  warning as in the case of actor removal
--  item: the item to be removed
function Game:removeItem(item)
  local index = 0
  for i = 1, #(self.itemList) do
    if self.itemList[i] == item then
      index = i
    end
  end
  table.remove(self.itemList, index)
end

--  Game:addMap - adds a map into a Game object's map list
--  map: the map to be added
function Game:addMap(map)
  table.insert(self.mapList, map)
  map.gameInstance = map
end

--  Game:removeMap - removes a map from a Game object's map list; same
--  warning as in the case of the actor removal
--  map: the map to be removed
function Game:removeMap(map)
  local index = 0
  for i = 1, #(self.mapList) do
    if self.mapList[i] == map then
      index = i
    end
  end
  table.remove(self.mapList, index)
end

--  Game:drawMainScreen - draws the main screen - map display, message bars,
--  player data etc.
function Game:drawMainScreen()
  self.log:write("Started drawing the main screen.\n")

  --  shortcut to currently drawn map
  local m = self.player.map

  --  clear the window for a new draw
  curses.clear()

  --  update the camera coordinates
  self:updateCamera()

  --  draw the map display, which is 60x20, and scrolling
  for i = self.cameraX, self.cameraX + 60 do
    for j = self.cameraY, self.cameraY + 20 do
      local t = m:getTile(i, j)

      --  don't draw anything if it's out of bounds
      if t then
        curses.attr(t.color)
        curses.write(i - self.cameraX, j - self.cameraY, t.face)
      end
    end
  end

  --  draw the actors
  for i = 1, #(self.actorList) do
    local a = self.actorList[i]

    --  draw only if the actor is on the same map as the player, and in view
    if a.map == self.player.map and self:coordinateInView(a.x, a.y) then
      curses.attr(a.color)
      curses.write(a.x - self.cameraX, a.y - self.cameraY, a.face)
    end
  end

  --  write some useful data (debugging purposes)
  curses.attr(curses.white)
  curses.write(60, 0, "Player: " .. self.player.x .. ", " .. self.player.y)
  curses.write(60, 1, "Camera: " .. self.cameraX .. ", " .. self.cameraY)
  curses.write(60, 2, "Tile: " .. self.player.map:getTile(self.player.x, self.player.y).name)

  --  put the cursor on the player
  curses.move(self.player.x - self.cameraX, self.player.y - self.cameraY)

  self.log:write("Terminated drawing the main screen.\n")
end

--  Game:updateCamera - updates the camera coordinates so that the player stays
--  relatively centered in view; only moves the camera one square in any
--  direction per call, to give the sensation of scrolling
function Game:updateCamera()
  --  these margins designate the 'center' zone of the view
  local upperMargin, lowerMargin, leftMargin, rightMargin = 5, 15, 20, 40

  if self.player.x - self.cameraX < leftMargin then
    self.cameraX = self.cameraX - 1
  end
  if self.player.x - self.cameraX > rightMargin then
    self.cameraX = self.cameraX + 1
  end
  if self.player.y - self.cameraY < upperMargin then
    self.cameraY = self.cameraY - 1
  end
  if self.player.y - self.cameraY > lowerMargin then
    self.cameraY = self.cameraY + 1
  end
end

--  Game:coordinateInView - tells us if a certain coordinate can be seen from
--  where the camera is currently at
--  x, y: the position to check
function Game:coordinateInView(x, y)
  return (  x >= self.cameraX and y >= self.cameraY and
            x < self.cameraX + 60 and y < self.cameraY + 20)
end

return Game

-- vim: set ts=2 sw=2:
