--- Author: COMT

--[[

  SplayTree

]]

--!native
--!optimize 2
--!strict


-- -- State

local Module = {}
Module.__index = Module

export type SplayTree = typeof(setmetatable({} :: {
  FreeRoot: false | number,
  Root: false | number,
  Size: number,
  [number]: false | number | any
}, Module))


-- -- Constants

local LEFT = 1
local RIGHT = 2
local PARENT = 3


-- -- Helpers

local table_create = table.create


-- -- Functions

function Module.new(capacity: number?): SplayTree
  local self = table_create((capacity or 0) * 4, 0) :: SplayTree
  self.FreeRoot = false
  self.Root = false
  self.Size = 0

  return setmetatable(self, Module)
end


-- -- Methods

local function allocate(self: SplayTree, key: any, parent: false | number): number
  local address = self.FreeRoot
  if address then
    self.FreeRoot = self[address]
  else
    address = #self + 1
  end

  self[address :: number] = key
  self[address :: number + LEFT] = false
  self[address :: number + RIGHT] = false
  self[address :: number + PARENT] = parent
  
  self.Size += 1
  
  return address :: number
end

local function free(self: SplayTree, address: number)
  local freeRoot = self.FreeRoot
  if freeRoot then
    self[address] = freeRoot
  else
    self[address] = false
  end
  
  self.FreeRoot = address
  self.Size -= 1
end

local function rotate(self: SplayTree, address: number)
  local parent = self[address + PARENT]
  if not parent then
    return
  end

  local grandParent = self[parent + PARENT]

  if self[parent + LEFT] == address then
    local right = self[address + RIGHT]
    self[parent + LEFT] = right
    if right then
      self[right + PARENT] = parent
    end
    self[address + RIGHT] = parent
  else
    local left = self[address + LEFT]
    self[parent + RIGHT] = left
    if left then
      self[left + PARENT] = parent
    end
    self[address + LEFT] = parent
  end

  self[parent + PARENT] = address
  self[address + PARENT] = grandParent

  if grandParent then
    if self[grandParent + LEFT] == parent then
      self[grandParent + LEFT] = address
    else
      self[grandParent + RIGHT] = address
    end
  else
    self.Root = address
  end
end

local function splay(self: SplayTree, address: number)
  local parent = self[address + PARENT]
  while parent do
    local grandParent = self[parent + PARENT]

    if not grandParent then -- Zig
      rotate(self, address)
    elseif (self[grandParent + LEFT] == parent) == (self[parent + LEFT] == address) then -- Zig-zig
      rotate(self, parent)
      rotate(self, address)
    else -- Zig-zag
      rotate(self, address)
      rotate(self, address)
    end

    parent = self[address + PARENT]
  end
end

function Module.upsert(self: SplayTree, key: any): false | number
  local current = self.Root
  if not current then
    local address = allocate(self, key)
    self.Root = address
    return address
  end
  
  while true do
    local currentKey = self[current]
    if key == currentKey then
      return false
    elseif key < currentKey then
      local left = self[current + LEFT]
      if not left then
        local address = allocate(self, key, current)
        self[current + LEFT] = address
        splay(self, address)
        return address
      end
      current = left
    else
      local right = self[current + RIGHT]
      if not right then
        local address = allocate(self, key, current)
        self[current + RIGHT] = address
        splay(self, address)
        return address
      end
      current = right
    end
  end
end

function Module.find(self: SplayTree, key: any): false | number
  local current = self.Root
  local last = false

  while current do
    last = current
    local currentValue = self[current]
    if key == currentValue then
      splay(self, current)
      return current
    elseif key < currentValue then
      current = self[current + LEFT]
    else
      current = self[current + RIGHT]
    end
  end

  if last then
    splay(self, last :: number)
  end

  return false
end

function Module.remove(self: SplayTree, key: any): false | number
  local address = self:find(key)
  if not address then
    return false
  end

  local left = self[address + LEFT]
  local right = self[address + RIGHT]

  if not left then
    self.Root = right
    if right then
      self[right + PARENT] = false
    end
  else
    self[left + PARENT] = false
    local m = left
    while self[m + RIGHT] do
      m = self[m + RIGHT]
    end
    splay(self, m)
    self[m + RIGHT] = right
    if right then
      self[right + PARENT] = m
    end
    self.Root = m
  end

  free(self, address)
  
  return address
end


-- -- End

return Module
