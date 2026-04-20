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


-- -- Helpers

local table_create = table.create
local table_insert = table.insert
local table_remove = table.remove

local function allocate(self: BinarySearchTree, value: any): number
  local freeRoot = self.FreeRoot
  if freeRoot then
    self.FreeRoot = self[freeRoot + 1]
    return freeRoot
  end
  return #self + 1
end

local function free(self: BinarySearchTree, address: number)
  local freeRoot = self.FreeRoot
  if freeRoot then
    self[address + 1] = freeRoot
  else
    self[address + 1] = false
  end
  self.FreeRoot = address
end


-- -- Methods

--[[
  Find a value if it exists.
  returns: valueWasFound

  Space Complexity: O(1)
  Time Complexity: Ω(1), Theta(log_2(n)), O(n)
]]
function Module.find(self: BinarySearchTree, value: any): boolean
  local current = self.Root
  
  while current do
    local currentValue = self[current]
    if currentValue == value then
      return true
    end
    if currentValue > value then
      current = self[current + 1]
    else
      current = self[current + 2]
    end
  end

  return false
end

--[[
  Remove a value if it exists.
  returns: valueWasRemoved

  Space Complexity: O(1)
  Time Complexity: Ω(1), Theta(log_2(n)), O(n)
]]
function Module.remove(self: BinarySearchTree, value: any): boolean
  local current = self.Root
  
  local parent = nil
  while current do
    local currentValue = self[current]
    if currentValue == value then
      break
    end
    parent = current
    if currentValue > value then
      current = self[current + 1]
    else
      current = self[current + 2]
    end
  end

  if not current then
    return false
  end

  local left, right = self[current + 1], self[current + 2]
  if not left or not right then
    local replacement
    if not left then
        replacement = right
    else
        replacement = left
    end

    if not parent then
      self.Root = replacement
      self.Size -= 1
      return true
    end

    if current == self[parent + 1] then
        self[parent + 1] = replacement
    else
        self[parent + 2] = replacement
    end

    free(self, current)
  else
    local parent = current
    local successor = right
    left = self[successor + 1]
    while left do
      parent = successor
      successor = left
    end

    self[current] = self[successor]

    right = self[successor + 2]
    if parent ~= current then
      self[parent + 1] = right
    else
      self[parent + 2] = right
    end

    free(self, successor)
  end

  self.Size -= 1
  return true
end

--[[
  Insert new value or update existing value.

  Space Complexity: O(1)
  Time Complexity: Ω(1), Theta(log_2(n)), O(n)
]]
function Module.upsert(self: BinarySearchTree, value: any)
  local current = self.Root
  if not current then
    self.Root = 1
    self[1], self[2], self[3] = value, false, false
    return
  end

  local currentValue: any
  while true do
    currentValue = self[current]
    local left = self[current + 1]
    if left and currentValue > value then
      current = left
      continue
    end
    local right = self[current + 2]
    if right and currentValue < value then
      current = right
    else
      if currentValue == value then
        self[current] = value
        return
      end
      break
    end
  end

  local address = allocate(self, value)
  
  if currentValue > value then
    self[current + 1] = address
  else
    self[current + 2] = address
  end

  self[address], self[address + 1], self[address + 2] = value, false, false
  self.Size += 1
end

--[[
  Get an array containing values from an inorder traversal of the given BinarySearchTree.

  Space Complexity: O(n)
  Time Complexity: Ω(n), O(n)
]]
function Module.inorder(self: BinarySearchTree): {any}
  local array = table_create(0, self.Size)
  local array_Top = 1
  local stack = {}

  local current = self.Root

  while current or #stack > 0 do
    while current do
      table_insert(stack, current)
      current = self[current + 1]
    end

    current = table_remove(stack)
    
    array[array_Top] = self[current :: number] :: number
    array_Top += 1

    current = self[current :: number + 2]
  end

  return array
end

--[[
  Get an array containing values from a postorder traversal of the given BinarySearchTree.

  Space Complexity: O(n)
  Time Complexity: Ω(n), O(n)
]]
function Module.postorder(self: BinarySearchTree): {any}
  local array_Top = self.Size
  local array = table_create(0, array_Top)
  local stack = {}

  local current = self.Root
  while current do
    array[array_Top] = self[current]
    array_Top -= 1
    
    local left, right = self[current + 1], self[current + 2]
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
  Get an array containing values from a preorder traversal of the given BinarySearchTree.

  Space Complexity: O(n)
  Time Complexity: Ω(n), O(n)
]]
function Module.preorder(self: BinarySearchTree): {any}
  local array = table_create(0, self.Size)
  local array_Top = 1
  local stack = {}

  local current = self.Root
  while current do
    array[array_Top] = self[current]
    array_Top += 1
    
    local left, right = self[current + 1], self[current + 2]
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
