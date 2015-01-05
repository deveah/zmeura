
--  util.lua
--  misc. utility functions

local Util = {}

--  Util.cloneTable - copies a specified table recursively
function Util.cloneTable(tbl)
  local t = {}

  for k, v in pairs(tbl) do
    if type(v) == "table" then
      t[k] = Util.cloneTable(v)
    else
      t[k] = v
    end
  end

  return t
end

return Util

--  vim: set ts=2 sw=2:
