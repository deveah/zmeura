
--  main.lua
--  Entry point of Zmeura. Does nothing more but create a new Game instance
--  and jump into its loop, cleaning up afterwards

local Game = require "lua/game"

local g = Game.new()

if g:initialize() then
  g:loop()
  g:terminate()
end

-- vim: set ts=2 sw=2:
