--- Author: COMT

--[[

  SortedArray

]]

--!native
--!optimize 2
--!strict


-- -- State

local Module = {}
Module.__index = Module

export type SortedArray = typeof(setmetatable({} :: {
  [number]: any
}, Module))


-- -- Helpers

local table_insert = table.insert
local table_remove = table.remove


-- -- Functions

function Module.new(): SortedArray
  return setmetatable({}, Module)
end


-- -- Methods

--[[
  Find the index of a value.

  Space Complexity: O(1)
  Time Complexity: Ω(1), O(log(n))
]]
function Module.find(self: SortedArray, value: any): number?
  local low = 1
  local high = #self

  while low <= high do
    local middle = (low + high) // 2
    local middleValue = self[middle]

    if value > middleValue then
      low = middle + 1
    elseif value < middleValue then
      high = middle - 1
    else
      return middle
    end
  end

  return nil
end

--[[
  Insert a new value.

  Space Complexity: O(1)
  Time Complexity: Ω(1), O(n)
]]
function Module.insert(self: SortedArray, value: any)
  local low = 1
  local high = #self

  while low <= high do
    local middle = (low + high) // 2
    local middleValue = self[middle]

    if value > middleValue then
      low = middle + 1
    elseif value < middleValue then
      high = middle - 1
    else
      table_insert(self, middle + 1, value)
      return
    end
  end
  
  table_insert(self, low, value)
end

--[[
  Insert a value if it doesn't already exist.

  Space Complexity: O(1)
  Time Complexity: Ω(1), O(n)
]]
function Module.remove(self: SortedArray, value: any): number?
  local low = 1
  local high = #self

  while low <= high do
    local middle = (low + high) // 2
    local middleValue = self[middle]

    if value > middleValue then
      low = middle + 1
    elseif value < middleValue then
      high = middle - 1
    else
      table_remove(self, low)
      return low
    end
  end
  
  return nil
end

--[[
  Insert a value if it doesn't already exist.

  Space Complexity: O(1)
  Time Complexity: Ω(1), O(n)
]]
function Module.upsert(self: SortedArray, value: any)
  local low = 1
  local high = #self

  while low <= high do
    local middle = (low + high) // 2
    local middleValue = self[middle]

    if value > middleValue then
      low = middle + 1
    elseif value < middleValue then
      high = middle - 1
    else
      return
    end
  end
  
  table_insert(self, low, value)
end


-- -- End

return Module
