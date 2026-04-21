--- Author: COMT

--[[

  MinHeap

]]

--!native
--!optimize 2
--!strict


-- -- State

local Module = {}
Module.__index = Module

export type MinHeap = typeof(setmetatable({} :: {
  Size: number,
  [number]: any
}, Module))


-- -- Functions

function Module.new(): MinHeap
  return setmetatable({
    Size = 0
  }, Module)
end


-- -- Methods

local function heapifyMinimum(self: MinHeap, key: any)
  local size = self.Size
  while true do
    local smallest = key
    
    local left, right = 2 * key, 2 * key + 1
    if left <= size and self[left] < self[smallest] then
      smallest = left
    end
    if right <= size and self[right] < self[smallest] then
      smallest = right
    end
  
    if smallest == key then
      return
    end
  
    self[key], self[smallest] = self[smallest], self[key]
    key = smallest
  end
end Module.heapifyMinimum = heapifyMinimum

function Module.changeKey(self: MinHeap, key: any, new: any)
  local oldKey = self[key]
  if oldKey == new then
    return
  end
  if oldKey < new then
    self[key] = new
    heapifyMinimum(self, key)
  else
    local currentKey = new
    while key ~= 1 do
      local parent = (key - 1) // 2 + 1
      local parentKey = self[parent]
      if currentKey >= parentKey then
        break
      end
      
      self[key], self[parent] = parentKey, currentKey
      key = parent
      currentKey = parentKey
    end
  end
end

--[[
  Remove and get the minimum key.

  Space Complexity: O(1)
  Time Complexity: Ω(1), O(log(n))
]]
function Module.extractMinimum(self: MinHeap): false | any
  local size = self.Size
  if size == 0 then
    return false
  end
  
  local root = self[1]
  if size == 1 then
    self.Size = 0
    return root
  end

  self[1] = self[size]
  self.Size = size - 1

  heapifyMinimum(self, 1)

  return root
end

--[[
  Insert a key.

  Space Complexity: O(1)
  Time Complexity: Ω(1), O(log(n))
]]
function Module.insert(self: MinHeap, key: any): boolean
  local current = self.Size + 1
  self[current] = key
  self.Size = current

  while current ~= 1 do
    local parent = (current - 1) // 2 + 1
    local parentKey = self[parent]
    if key >= parentKey then
      break
    end
    self[current], self[parent] = parentKey, key
    current = parent
    key = parentKey
  end
  
  return true
end

--[[
  Remove a key.

  Space Complexity: O(1)
  Time Complexity: Ω(1), O(log(n))
]]
function Module.remove(self: MinHeap, key: any)
  local size = self.Size
  if key > size then
    return
  end

  self[key] = self[size]
  self.Size = size - 1
  heapifyMinimum(self, key)
end


-- End

return Module
