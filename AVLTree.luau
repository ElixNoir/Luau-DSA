--- Author: COMT

--[[

  AVLTree

]]

--!native
--!optimize 2
--!strict


-- -- State

local Module = {}
Module.__index = Module

export type AVLTree = typeof(setmetatable({} :: {
  FreeRoot: false | number,
  Root: false | number,
  Size: number,
  [number]: false | number | any
}, Module))


-- -- Constants

local HEIGHT = 1
local LEFT = 2
local RIGHT = 3


-- -- Helpers

local math_max = math.max

local table_create = table.create
local table_insert = table.insert

local function allocate(self: AVLTree, key: number): number
  local address = self.FreeRoot
  if address then
    self.FreeRoot = self[address]
  else
    address = #self + 1
  end

  self[address :: number] = key
  self[address :: number + HEIGHT] = 1
  self[address :: number + LEFT] = false
  self[address :: number + RIGHT] = false

  self.Size += 1

  return address :: number
end

local function free(self: AVLTree, address: number)
  self[address] = self.FreeRoot
  self.FreeRoot = address

  self.Size -= 1
end

local function rotateLeft(self: AVLTree, address: number): number
  local y = self[address + RIGHT]
  local T2 = self[y + LEFT]

  self[y + LEFT] = self[address]
  self[address + RIGHT] = T2

  local left, right = self[address + LEFT], self[address + RIGHT]
  self[address + HEIGHT] = math_max(left and self[left + HEIGHT] or 0, left and self[right + HEIGHT] or 0) + 1
  left, right = self[y + LEFT], self[y + RIGHT]
  self[y + HEIGHT] = math_max(left and self[left + HEIGHT] or 0, left and self[right + HEIGHT] or 0) + 1

  return y
end

local function rotateRight(self: AVLTree, address: number): number
  local x = self[address + LEFT]
  local T2 = self[x + RIGHT]

  self[x + RIGHT] = address
  self[address + LEFT] = T2

  local left, right = self[address + LEFT], self[address + RIGHT]
  self[address + HEIGHT] = math_max(left and self[left + HEIGHT] or 0, left and self[right + HEIGHT] or 0) + 1
  left, right = self[x + LEFT], self[x + RIGHT]
  self[x + HEIGHT] = math_max(left and self[left + HEIGHT] or 0, left and self[right + HEIGHT] or 0) + 1

  return x
end

local function rebalance(self: AVLTree, address: number): number
  local left, right = self[address + LEFT], self[address + RIGHT]
  local left_Height, right_Height = left and self[left + HEIGHT] or 0, right and self[right + HEIGHT] or 0

  local balanceFactor = left_Height - right_Height
  
  self[address + HEIGHT] = (balanceFactor > 0 and left_Height or right_Height) + 1

  if balanceFactor > 1 then
    local lleft, lright = self[left + LEFT], self[right + RIGHT]
    if (lleft and self[lleft + HEIGHT] or 0) < (lright and self[lright + HEIGHT] or 0) then
        self[address + LEFT] = rotateLeft(self, left :: number)
    end
    return rotateRight(self, address)
  end

  if balanceFactor < -1 then
    local rleft, rright = self[right + LEFT], self[right + RIGHT]
    if (rleft and self[rleft + HEIGHT] or 0) > (rright and self[rright + HEIGHT] or 0) then
        self[address + RIGHT] = rotateRight(self, right :: number)
    end
    return rotateLeft(self, address)
  end

  return address
end


-- -- Functions

function Module.new(): AVLTree
    return setmetatable({
      FreeRoot = false,
      Root = false,
      Size = 0
    }, Module) :: AVLTree
end

--[[
  Find a node by its key.

  Space Complexity: O(1)
  Time Complexity: Ω(1), O(log(n))
]]
function Module.find(self: AVLTree, key: number, address: false | number?): false | number
  while address do
    local currentKey = self[address]
    if key < currentKey then
      address = self[address + LEFT]
    elseif key > currentKey then
      address = self[address + RIGHT]
    else
      return address
    end
  end
  
  return false
end

--[[
  Insert a key if it doesn't already exist.
  returns: keyWasInserted

  Space Complexity: O(1)
  Time Complexity: Ω(1), O(log(n))
]]
function Module.upsert(self: AVLTree, key: number, address: false | number?): boolean
  local root = self.Root
  if not root then
    self.Root = allocate(self, key)
    return true
  end

  local path = table_create(32) :: {number}
  local dirs = table_create(32) :: {boolean}

  local current = address or root
  while current do
    table_insert(path, current)

    local currentKey = self[current]

    if key < currentKey then
      table_insert(dirs, false)
      local left = self[current + LEFT]
      if not left then
        local newNode = allocate(self, key)
        self[current + LEFT] = newNode
        table_insert(path, newNode)
        break
      end
      current = left
    elseif key > currentKey then
      table_insert(dirs, true)
      local right = self[current + RIGHT]
      if not right then
        local newNode = allocate(self, key)
        self[current + RIGHT] = newNode
        table_insert(path, newNode)
        break
      end
      current = right
    else
      return false
    end
  end

  for index = #path - 1, 1, -1 do
    local newRoot = rebalance(self, path[index])

    if index == 1 then
      self.Root = newRoot
    else
      local parent = path[index - 1]
      if dirs[index - 1] then
        self[parent + RIGHT] = newRoot
      else
        self[parent + LEFT] = newRoot
      end
    end
  end

  return true
end

--[[
  Remove a key.
  returns: keyWasRemoved

  Space Complexity: O(1)
  Time Complexity: Ω(1), O(log(n))
]]
function Module.remove(self: AVLTree, key: number, address: false | number?): boolean
  local path = table_create(32) :: {number}
  local dirs = table_create(32) :: {boolean}

  local current = address or self.Root

  while current do
    local currentKey = self[current]
    if key == currentKey then
      break
    end

    table_insert(path, current)

    if key < currentKey then
      table_insert(dirs, false)
      current = self[current + LEFT]
    else
      table_insert(dirs, true)
      current = self[current + RIGHT]
    end
  end

  if not current then
    return false
  end

  if self[current + LEFT] and self[current + RIGHT] then
    table_insert(path, current)
    table_insert(dirs, true)

    local successor = self[current + RIGHT]
    local s = self[successor + LEFT]

    while s do
      s = self[successor + LEFT]
      table_insert(path, successor :: number)
      table_insert(dirs, false)
      successor = s
    end

    self[current], self[successor] = self[successor], self[current]

    current = successor
  end

  local child = self[current + LEFT] or self[current + RIGHT]

  local length = #path
  if length == 0 then
    self.Root = child
  else
    local parent = path[length]
    if dirs[#dirs] then
      self[parent + RIGHT] = child
    else
      self[parent + LEFT] = child
    end
  end

  free(self, current)

  for index = length, 1, -1 do
    local newRoot = rebalance(self, path[index])

    if index == 1 then
      self.Root = newRoot
    else
      local parent = path[index - 1]
      if dirs[index - 1] then
        self[parent + RIGHT] = newRoot
      else
        self[parent + LEFT] = newRoot
      end
    end
  end

  return true
end


-- -- End

return Module
