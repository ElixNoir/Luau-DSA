--- Author: COMT

--[[

  BinarySearchTree

]]


--!native
--!optimize 2
--!strict


-- -- State

local Module = {}
Module.__index = Module

export type BinarySearchTree = typeof(setmetatable({} :: {
  FreeRoot: false | number,
  Root: false | number,
  Size: number,
  [number]: false | any
}, Module))


-- -- Helpers


-- -- Functions

function Module.new(): BinarySearchTree
  return setmetatable({
    FreeRoot = false,
    Root = false,
    Size = 0
  }, Module) :: BinarySearchTree
end


-- -- Constants

local LEFT = 1
local RIGHT = 2


-- -- Helpers

local table_create = table.create
local table_insert = table.insert
local table_remove = table.remove

local function allocate(self: BinarySearchTree, key: any): number
  local address = self.FreeRoot
  if address then
    self.FreeRoot = self[address]
  else
    address = #self + 1
  end

  self[address :: number] = key
  self[address :: number + LEFT] = false
  self[address :: number + RIGHT] = false
  
  self.Size += 1
  
  return address :: number
end

local function free(self: BinarySearchTree, address: number)
  local freeRoot = self.FreeRoot
  if freeRoot then
    self[address] = freeRoot
  else
    self[address] = false
  end
  
  self.FreeRoot = address
  self.Size -= 1
end


-- -- Methods

--[[
  Find the greatest key if it exists.
  returns: false | nodeAddress

  Space Complexity: O(1)
  Time Complexity: Ω(1), Theta(log_2(n)), O(n)
]]
function Module.ceiling(self: BinarySearchTree, key: any): false | number
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
function Module.find(self: BinarySearchTree, key: any): false | number
  local current = self.Root
  
  while current do
    local currentkey = self[current]
    if currentkey == key then
      return current
    end
    if currentkey > key then
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
function Module.floor(self: BinarySearchTree, key: any): false | number
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
function Module.remove(self: BinarySearchTree, key: any): false | number
  local current = self.Root
  
  local parent = nil
  while current do
    local currentkey = self[current]
    if currentkey == key then
      break
    end
    parent = current
    if currentkey > key then
      current = self[current + LEFT]
    else
      current = self[current + RIGHT]
    end
  end

  if not current then
    return false
  end

  local left, right = self[current + LEFT], self[current + RIGHT]
  if not left or not right then
    local replacement = left or right

    if not parent then
      self.Root = replacement
    elseif self[parent + LEFT] == current then
      self[parent + LEFT] = replacement
    else
      self[parent + RIGHT] = replacement
    end

    free(self, current)
    return current
  end
  
  parent = current
  left = self[right + LEFT]
  while left do
    parent = right
    right = left
    left = self[right + LEFT]
  end

  self[current] = self[right]

  local replacement = self[right + RIGHT]
  if parent == current then
    self[parent + RIGHT] = replacement
  else
    self[parent + LEFT] = replacement
  end

  free(self, right :: number)

  return current
end

--[[
  Insert new key or update existing key.

  Space Complexity: O(1)
  Time Complexity: Ω(1), Theta(log_2(n)), O(n)
]]
function Module.upsert(self: BinarySearchTree, key: any): false | number
  local current = self.Root
  if not current then
    local address = allocate(self, key)
    self.Root = address
    return address
  end

  while true do
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
        return address
      end
    else
      local right = self[current + RIGHT]
      if right then
        current = right
      else
        local address = allocate(self, key)
        self[current + RIGHT] = address
        return address
      end
    end
  end
end

--[[
  Get an array containing keys from an inorder traversal of the given BinarySearchTree.
  returns: inorderArray

  Space Complexity: O(n)
  Time Complexity: Ω(n), O(n)
]]
function Module.inorder(self: BinarySearchTree): {any}
  local array = table_create(self.Size)
  local stack = {}

  local current = self.Root

  while current or #stack > 0 do
    while current do
      table_insert(stack, current)
      current = self[current + LEFT]
    end

    current = table_remove(stack)
    table_insert(array, self[current :: number] :: number)
    current = self[current :: number + RIGHT]
  end

  return array
end

--[[
  Get an array containing keys from a levelorder traversal of the given BinarySearchTree.
  returns: levelorderArray

  Space Complexity: O(n)
  Time Complexity: Ω(n), O(n)
]]
function Module.levelorder(self: BinarySearchTree): {any}
  local array = table_create(self.Size)

  local current = self.Root
  if not current then
    return array
  end

  local queue = {}
  local head = 1
  
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
  Get an array containing keys from a postorder traversal of the given BinarySearchTree.
  returns: postorderArray

  Space Complexity: O(n)
  Time Complexity: Ω(n), O(n)
]]
function Module.postorder(self: BinarySearchTree): {any}
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
  Get an array containing keys from a preorder traversal of the given BinarySearchTree.
  returns: preorderArray

  Space Complexity: O(n)
  Time Complexity: Ω(n), O(n)
]]
function Module.preorder(self: BinarySearchTree): {any}
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
