--- Author: COMT

--[[

  MaxHeap

]]

--!native
--!optimize 2
--!strict


-- -- State

local Module = {}
Module.__index = Module

export type MaxHeap = typeof(setmetatable({} :: {
  Size: number,
  [number]: any
}, Module))


-- -- Functions

function Module.new(): MaxHeap
  return setmetatable({
    Size = 0
  }, Module)
end


-- -- Methods

local function heapifyMaximum(self: MaxHeap, key: any)
  local size = self.Size
  while true do
    local smallest = key
    
    local left, right = 2 * key, 2 * key + 1
    if left <= size and self[left] > self[smallest] then
      smallest = left
    end
    if right <= size and self[right] > self[smallest] then
      smallest = right
    end
  
    if smallest == key then
      return
    end
  
    self[key], self[smallest] = self[smallest], self[key]
    key = smallest
  end
end Module.heapifyMaximum = heapifyMaximum

function Module.changeKey(self: MaxHeap, key: any, new: any)
  local oldKey = self[key]
  if oldKey == new then
    return
  end
  if oldKey < new then
    local currentKey = new
    self[key] = new
  
    while key ~= 1 do
      local parent = (key - 1) // 2 + 1
      local parentKey = self[parent]
  
      if currentKey <= parentKey then
        break
      end
      
      self[key], self[parent] = parentKey, currentKey
      key = parent
    end
  else
    self[key] = new
    heapifyMaximum(self, key)
  end
end

--[[
  Remove and get the maximum key.

  Space Complexity: O(1)
  Time Complexity: Ω(1), O(log(n))
]]
function Module.extractMaximum(self: MaxHeap): (false | any, number?)
  local size = self.Size
  if size == 0 then
    return false, nil
  end
  
  local root = self[1]
  if size == 1 then
    self.Size = 0
    return root, 1
  end

  self[1] = self[size]
  self.Size = size - 1

  heapifyMaximum(self, 1)
  self[size] = nil
  
  return root, 1
end

--[[
  Insert a key.

  Space Complexity: O(1)
  Time Complexity: Ω(1), O(log(n))
]]
function Module.insert(self: MaxHeap, key: any): boolean
  local current = self.Size + 1
  self[current] = key
  self.Size = current

  while current ~= 1 do
    local parent = (current - 1) // 2 + 1
    local parentKey = self[parent]
    if key <= parentKey then
      break
    end
    self[current], self[parent] = parentKey, key
    current = parent
  end
  
  return true
end

--[[
  Remove a key.

  Space Complexity: O(1)
  Time Complexity: Ω(1), O(log(n))
]]
function Module.remove(self: MaxHeap, key: any)
  local size = self.Size
  if key > size then
    return
  end

  self[key] = self[size]
  self[size] = nil
  self.Size = size - 1
  heapifyMaximum(self, key)
end


-- End

return Module
