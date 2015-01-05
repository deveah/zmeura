
--  item.lua
--  item prototype and related functions

local Util = require "lua/util"

local Item = {}
Item.__index = Item

--  Item.new - creates a new item object from a specified prototype, which it
--  clones upon initialization
function Item.new(proto)
  local i = {}
  i = Util.cloneTable(proto)

  setmetatable(i, Item)

  return i
end

return Item

--  vim: set ts=2 sw=2:
