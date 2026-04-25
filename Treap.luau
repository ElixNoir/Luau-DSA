--- Author: COMT

--[[

  Treap

]]


--!native
--!optimize 2
--!strict

local Module = {}
Module.__index = Module

export type Treap = typeof(setmetatable({} :: {
  FreeRoot: false | number,
  Root: false | number,
  Size: number,
  [number]: false | any
}, Module))


-- -- Constants

local LEFT = 1
local RIGHT = 2
local PRIORITY = 3


-- -- Helpers

local math_random = math.random

local table_create = table.create
local table_insert = table.insert
local table_remove = table.remove

local function allocate(self: Treap, key: any): number
  local address = self.FreeRoot
  if address then
    self.FreeRoot = self[address]
  else
    address = #self + 1
  end

  self[address :: number] = key
  self[address :: number + LEFT] = false
  self[address :: number + RIGHT] = false
  self[address :: number + PRIORITY] = math_random()

  self.Size += 1
  
  return address :: number
end

local function free(self: Treap, address: number)
  self[address] = self.FreeRoot
  self.FreeRoot = address
  self.Size -= 1
end

local function rotateLeft(self: Treap, address: number): number
  local y = self[address + RIGHT]
  self[address + RIGHT] = self[y + LEFT]
  self[y + LEFT] = address
  return y
end

local function rotateRight(self: Treap, address: number): number
  local y = self[address + LEFT]
  self[address + LEFT] = self[y + RIGHT]
  self[y + RIGHT] = address
  return y
end

-- -- Functions

function Module.new(): Treap
  return setmetatable({
    FreeRoot = false,
    Root = false,
    Size = 0
  }, Module) :: Treap
end


-- -- Methods

--[[
  Find the greatest key if it exists.
  returns: false | nodeAddress

  Space Complexity: O(1)
  Time Complexity: Ω(1), Theta(log_2(n)), O(n)
]]
function Module.ceiling(self: Treap, key: any): false | number
  local current = self.Root
  local candidate = current

  while current do
    local currentKey = self[current]

    if currentKey == key then
      return current
    elseif currentKey > key then
      candidate = current
      current = self[current + LEFT]
    else
      current = self[current + RIGHT]
    end
  end

  return candidate
end

--[[
  Find a key if it exists.
  returns: false | nodeAddress

  Space Complexity: O(1)
  Time Complexity: Ω(1), Theta(log_2(n)), O(n)
]]
function Module.find(self: Treap, key: any): false | number
  local current = self.Root

  while current do
    local currentKey = self[current]
    if currentKey == key then
      return current
    elseif key < currentKey then
      current = self[current + LEFT]
    else
      current = self[current + RIGHT]
    end
  end

  return false
end

--[[
  Find the least key if it exists.
  returns: false | nodeAddress

  Space Complexity: O(1)
  Time Complexity: Ω(1), Theta(log_2(n)), O(n)
]]
function Module.floor(self: Treap, key: any): false | number
  local current = self.Root
  local candidate = current

  while current do
    local currentKey = self[current]

    if currentKey == key then
      return current
    elseif currentKey < key then
      candidate = current
      current = self[current + RIGHT]
    else
      current = self[current + LEFT]
    end
  end

  return candidate
end

--[[
  Remove a key if it exists.
  returns: false | removedNodeAddress

  Space Complexity: O(1)
  Time Complexity: Ω(1), Theta(log_2(n)), O(n)
]]
function Module.remove(self: Treap, key: any): false | number
  local current = self.Root
  local parent = nil

  while current do
    local currentKey = self[current]
    if currentKey == key then
      break
    end

    parent = current
    if key < currentKey then
      current = self[current + LEFT]
    else
      current = self[current + RIGHT]
    end
  end

  if not current then
    return false
  end

  while true do
    local left = self[current + LEFT]
    local right = self[current + RIGHT]

    if not left and not right then
      break
    end

    local newRoot

    if not right or (left and self[left + PRIORITY] < self[right + PRIORITY]) then
      newRoot = rotateRight(self, current)
    else
      newRoot = rotateLeft(self, current)
    end

    -- reconnect parent
    if not parent then
      self.Root = newRoot
    else
      if self[parent + LEFT] == current then
        self[parent + LEFT] = newRoot
      else
        self[parent + RIGHT] = newRoot
      end
    end

    parent = newRoot
  end

  if not parent then
    self.Root = false
  else
    if self[parent + LEFT] == current then
      self[parent + LEFT] = false
    else
      self[parent + RIGHT] = false
    end
  end

  free(self, current)
  
  return current
end

--[[
  Insert new key or update existing key.

  Space Complexity: O(1)
  Time Complexity: Ω(1), Theta(log_2(n)), O(n)
]]
function Module.upsert(self: Treap, key: any): (false | number)
  local current = self.Root
  if not current then
    local address = allocate(self, key)
    self.Root = address
    return address
  end

  local path = {}
  
  while true do
    table_insert(path, current)
    local currentKey = self[current]

    if key == currentKey then
      self[current] = key
      return false
    elseif key < currentKey then
      local left = self[current + LEFT]
      if left then
        current = left
      else
        local address = allocate(self, key)
        self[current + LEFT] = address
        table_insert(path, address)
        current = address
        break
      end
    else
      local right = self[current + RIGHT]
      if right then
        current = right
      else
        local address = allocate(self, key)
        self[current + RIGHT] = address
        table_insert(path, address)
        current = address
        break
      end
    end
  end

  for index = #path - 1, 1, -1 do
    local parent = path[index]
    local child = path[index + 1]

    if self[child + PRIORITY] >= self[parent + PRIORITY] then
      break
    end

    local newRoot
    if self[parent + LEFT] == child then
      newRoot = rotateRight(self, parent)
    else
      newRoot = rotateLeft(self, parent)
    end

    if index == 1 then
      self.Root = newRoot
    else
      local grand = path[index - 1]
      if self[grand + LEFT] == parent then
        self[grand + LEFT] = newRoot
      else
        self[grand + RIGHT] = newRoot
      end
    end

    path[index] = newRoot
    path[index + 1] = parent
  end
  
  return current
end

--[[
  Get an array containing keys from an inorder traversal of the given Treap.
  returns: inorderArray

  Space Complexity: O(n)
  Time Complexity: Ω(n), O(n)
]]
function Module.inorder(self: Treap): {any}
  local array = table_create(self.Size)
  local stack = {}

  local current = self.Root

  while current or #stack > 0 do
    while current do
      table_insert(stack, current)
      current = self[current + LEFT]
    end

    current = table_remove(stack)
    table_insert(array, self[current :: number])

    current = self[current :: number + RIGHT]
  end

  return array
end

--[[
  Get an array containing keys from a levelorder traversal of the given Treap.
  returns: levelorderArray

  Space Complexity: O(n)
  Time Complexity: Ω(n), O(n)
]]
function Module.levelorder(self: Treap): {any}
  local array = table_create(self.Size)

  local current = self.Root
  if not current then
    return array
  end

  local queue = {}
  local head = 0

  while head <= #queue do
    table_insert(array, self[current])

    local left = self[current + LEFT]
    local right = self[current + RIGHT]

    if left then
      table_insert(queue, left)
    end
    if right then
      table_insert(queue, right)
    end

    head += 1
    current = queue[head]
  end

  return array
end

--[[
  Get an array containing keys from a postorder traversal of the given Treap.
  returns: postorderArray

  Space Complexity: O(n)
  Time Complexity: Ω(n), O(n)
]]
function Module.postorder(self: Treap): {any}
  local array = table_create(self.Size)
  local stack = {}

  local current = self.Root
  while current do
    table_insert(array, self[current])
    
    local left, right = self[current + LEFT], self[current + RIGHT]
    if left then
      table_insert(stack, left)
    end
    if right then
      table_insert(stack, right)
    end

    current = table_remove(stack)
  end
  
  return array
end

--[[
  Get an array containing keys from a preorder traversal of the given Treap.
  returns: preorderArray

  Space Complexity: O(n)
  Time Complexity: Ω(n), O(n)
]]
function Module.preorder(self: Treap): {any}
  local array = table_create(self.Size)
  local stack = {}

  local current = self.Root
  while current do
    table_insert(array, self[current])
    
    local left, right = self[current + LEFT], self[current + RIGHT]
    if right then
      table_insert(stack, right)
    end
    if left then
      table_insert(stack, left)
    end

    current = table_remove(stack)
  end
  
  return array
end


-- -- End

return Module
