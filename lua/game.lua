
--  game.lua
--  Game prototype and related functions

local Actor = require "lua/actor"
local Global = require "lua/global"
local Map = require "lua/map"
local Mapgen = require "lua/mapgen"
local Terrain = require "lua/terrain"
local Weather = require "lua/weather"

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

  --  message log
  self.messageLog = {}

  --  this tells us if the game is currently inside the main loop
  self.running = false

  --  the player Actor object, so the game knows which actor to follow
  self.player = nil

  --  initialize a curses window, also getting the terminal window's size
  self.terminalWidth, self.terminalHeight = curses.init()

  --  we need at least an 80x25 terminal to work, so exit if that requirement
  --  isn't met, and let the user know of this issue
  if  self.terminalWidth < Global.minimalTerminalWidth or
      self.terminalHeight < Global.minimalTerminalHeight then
    curses.terminate()
    print("Terminal window should be at least 80x25.")
    return false
  end

  --  log the terminal data
  self.log:write("Terminal is " .. self.terminalWidth .. "x" .. self.terminalHeight .. "\n")

  --  create an empty map (filled with floor tiles), and place it into the map list
  local tempMap = Map.new(100, 100)
  Mapgen.forest(tempMap, 0.2, 0.8, 0.01, 0.005)
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
  self.cameraX = self.player.x - math.floor(Global.viewportWidth/2)
  self.cameraY = self.player.y - math.floor(Global.viewportHeight/2)

  --  greet the player!
  self:announce("Welcome! Please don't die often.")

  --  create a Weather object
  self.weather = Weather.new(self, tempMap, "sunny")

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
    --  update the weather
    self.weather:takeEffect()
    self.weather:cycle()

    for i = 1, #(self.actorList) do
      local a = self.actorList[i]
      self.log:write("Actor " .. tostring(a) .. " now acting.\n")

      a:updateStats()
      self.log:write("\tUpdated stats.\n")

      if a.isPlayer then
        --  the actor is player-controlled, so update the screen, get input,
        --  and pass onto translating the keystroke into an action
        self:drawMainScreen()
        local k = curses.getch()
        a:handleKey(k)
      else
        --  no AI for now, so leave the actor alone
      end

      --  increase the actor's turn count
      a.turns = a.turns + 1
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
  map.gameInstance = self
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

--  Game:itemAt - returns the item at a specified position, or nil, if none
--  can be found
--  x, y: coordinates of the point to search
--  map:  map on which the item should be
function Game:itemAt(x, y, map)
  for i = 1, #(self.itemList) do
    local it = self.itemlist[i]
    if it.map == map and it.x == x and it.y == y then
      return it
    end
  end

  --  nothing has been found, so return nil
  return nil
end

--  Game:drawMainScreen - draws the main screen - map display, message bars,
--  player data etc.
function Game:drawMainScreen()
  self.log:write("Started drawing the main screen.\n")

  --  shortcut to currently drawn map
  local m = self.player.map

  --  update the camera coordinates to center on the player
  self:updateCamera(self.player.x, self.player.y)

  self.player:updateFieldOfView()

  --  clear the area that holds messages (so they won't overlap on successive
  --  drawings)
  for i = Global.viewportHeight, Global.minimalTerminalWidth do
    curses.move(0, i)
    curses.clrtoeol()
  end

  --  clear the area to the right of the viewport
  for i = 0, Global.viewportHeight do
    curses.move(Global.viewportWidth, i)
    curses.clrtoeol()
  end

  --  draw the terrain
  for i = self.cameraX, self.cameraX + Global.viewportWidth - 1 do
    for j = self.cameraY, self.cameraY + Global.viewportHeight - 1 do
      local t = m:getTile(i, j)
      local mt = m:getMemorisedTile(i, j)

      --  don't draw anything if it's out of bounds
      if t then
        if self.player:inSight(i, j) then
          --  if the tile is in the field of view, draw it as it is
          curses.attr(t.color)
          curses.write(i - self.cameraX, j - self.cameraY, t.face)
        elseif mt then
          --  if the tile is not in view, but has been seen, draw it from memory
          curses.attr(curses.black + curses.bold)
          curses.write(i - self.cameraX, j - self.cameraY, mt.face)
        else
          --  nothing is known about this tile, so draw nothing
          curses.attr(curses.white)
          curses.write(i - self.cameraX, j - self.cameraY, " ")
        end
      else
        --  tile is out of bounds, so draw nothing
        curses.attr(curses.white)
        curses.write(i - self.cameraX, j - self.cameraY, " ")
      end
    end
  end

  --  draw the actors
  for i = 1, #(self.actorList) do
    local a = self.actorList[i]

    --  draw only if the actor is on the same map as the player, and in view
    if  a.map == self.player.map and self:coordinateInView(a.x, a.y) and
        self.player:inSight(a.x, a.y) then
      curses.attr(a.color)
      curses.write(a.x - self.cameraX, a.y - self.cameraY, a.face)
    end
  end

  --  write some useful data (debugging purposes)
  curses.attr(curses.white)
  curses.write(Global.viewportWidth, 0, "Player: " .. self.player.x .. ", " .. self.player.y)
  curses.write(Global.viewportWidth, 1, "Camera: " .. self.cameraX .. ", " .. self.cameraY)

  curses.write(Global.viewportWidth, 3, "Thirst: " .. self.player.thirst .. "%")
  curses.write(Global.viewportWidth + 20, 3, "Hunger: " .. self.player.hunger .. "%")
  curses.write(Global.viewportWidth, 4, "Weather: " .. self.weather.state)

  --  draw the last five messages
  for i = 0, 4 do
    local message = self.messageLog[#(self.messageLog) - i]
    if message then
      if message.repeats == 1 then
        curses.write(0, Global.viewportHeight + i, message.text)
      else
        curses.write(0, Global.viewportHeight + i, message.text ..
          " (x" .. message.repeats .. ")")
      end
    end
  end

  --  put the cursor on the player
  curses.move(self.player.x - self.cameraX, self.player.y - self.cameraY)

  self.log:write("Terminated drawing the main screen.\n")
end

--  Game:updateCamera - updates the camera coordinates so that the given
--  coordinates stay relatively centered in view; only moves the camera one
--  square in any direction per call, to give the sensation of scrolling
--  x, y: position to move the camera towards
function Game:updateCamera(x, y)
  if x - self.cameraX < Global.viewportLeftMargin then
    self.cameraX = self.cameraX - 1
  end
  if x - self.cameraX > Global.viewportRightMargin then
    self.cameraX = self.cameraX + 1
  end
  if y - self.cameraY < Global.viewportUpperMargin then
    self.cameraY = self.cameraY - 1
  end
  if y - self.cameraY > Global.viewportLowerMargin then
    self.cameraY = self.cameraY + 1
  end
end

--  Game:coordinateInView - tells us if a certain coordinate can be seen from
--  where the camera is currently at
--  x, y: the position to check
function Game:coordinateInView(x, y)
  return (  x >= self.cameraX and y >= self.cameraY and
            x < self.cameraX + Global.viewportWidth and
            y < self.cameraY + Global.viewportHeight)
end

--  Game:lookAt - enters 'look mode', which allows the user to look around
--  with the same keys as used for player movement; looking is limited to the
--  insides of the player's field of view
--  x, y: the position the looking starts from
function Game:lookAt(x, y)
  --  current coordinates
  local cx, cy = x, y

  --  key pressed
  local k = ""

  while k ~= "q" do
    --  redraw the main screen
    self:drawMainScreen()

    --  the examined tile
    local t = self.player.map:getTile(cx, cy)

    --  clear the space reserved for looking information
    for i = Global.viewportHeight, Global.minimalTerminalHeight do
      curses.move(0, i)
      curses.clrtoeol()
    end

    --  draw examination details
    curses.attr(curses.yellow)
    curses.write(0, Global.viewportHeight, "Looking (q to quit)")
    curses.attr(curses.white)
    if t and self.player.sightMap[cx][cy] then
      curses.write(0, Global.viewportHeight+1, "Tile: " .. t.name)
      curses.write(0, Global.viewportHeight+2, t.description)
    else
      curses.write(0, Global.viewportHeight+1, "I can't see what's there.")
    end

    --  center the cursor on the examined position
    curses.move(cx - self.cameraX, cy - self.cameraY)

    k = curses.getch()
    if k == "h" and cx > self.cameraX then
      cx = cx - 1
    end
    if k == "j" and cy < self.cameraY + Global.viewportHeight - 1 then
      cy = cy + 1
    end
    if k == "k" and cy > self.cameraY then
      cy = cy - 1
    end
    if k == "l" and cx < self.cameraX + Global.viewportWidth - 1 then
      cx = cx + 1
    end
  end
end

--  Game:announce - adds a message into the log, so the user can receive
--  feedback; also manages multiple, similar messages
--  message: the string to add to the log
function Game:announce(message)
  --  this is the first message announce, so don't bother checking for previous
  --  similar messages
  if #self.messageLog == 0 then
    table.insert(self.messageLog, {
      text = message,
      repeats = 1
    })
    return true
  end

  if message == self.messageLog[#self.messageLog].text then
    --  if the message is the same as the last one, collapse them and add a
    --  counter which tells the user how many times that particular action happened
    self.messageLog[#self.messageLog].repeats = self.messageLog[#self.messageLog].repeats + 1
  else
    --  if the messages aren't similar, add the message with a counter of one
    table.insert(self.messageLog, {
      text = message,
      repeats = 1
    })
  end
end

return Game

-- vim: set ts=2 sw=2:
