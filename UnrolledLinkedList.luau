--- Author: COMT

--[[

  UnrolledLinkedList

]]


--!native
--!optimize 2
--!strict


-- -- State

local Module = {}
Module.__index = Module

export type UnrolledLinkedList = typeof(setmetatable({} :: {
  FreeHead: false | number,
  Head: false | number,
  NodeCount: number,
  Size: number,
  Tail: false | number,
  [number]: false | {any} | any
}, Module))


-- -- Constants

local NEXT = 1


-- -- Helpers

local table_create = table.create
local table_insert = table.insert
local table_remove = table.remove

local function allocate(self: UnrolledLinkedList, next: false | number): (number, {any})
  local address = self.FreeHead
  if address then
    self.FreeHead = self[address]
  else
    address = #self + 1
  end

  local list = {}
  self[address :: number] = list
  self[address :: number + NEXT] = next

  self.Size += 1

  return address :: number, list
end

local function free(self: UnrolledLinkedList, address: number)
  self[address] = self.FreeHead
  self.FreeHead = address
  self.Size -= 1
end


-- -- Functions

function Module.new(): UnrolledLinkedList
  return setmetatable({
    FreeHead = false,
    Head = false,
    NodeCount = 0,
    Size = 0,
    Tail = false
  }, Module) :: UnrolledLinkedList
end


-- -- Methods

--[[
  Space Complexity: O(1)
  Time Complexity: Ω(1), O(log(n))
]]
function Module.get(self: UnrolledLinkedList, index: number): any
  local current = self.Head :: number
  while current do
    local list = self[current] :: {any}

    local length = #list
    if index < length then
      return list[index]
    end
    
    index -= length
    current = self[current + NEXT]
  end

  return nil
end

--[[
  Space Complexity: O(1)
  Time Complexity: O(1)
]]
function Module.insert(self: UnrolledLinkedList, value: any)
  if not self.Head then
    local address, list = allocate(self, false)
    list[1] = value

    self.Head = address
    self.Tail = address
    self.Size = 1
    self.NodeCount = 0
    return
  end

  local tail = self.Tail
  local list = self[tail]

  local nodeCount = self.NodeCount
  local capacity = 2 ^ nodeCount

  if #list >= capacity then
    self.NodeCount = nodeCount + 1

    local address, newList = allocate(self, false)
    self[tail + NEXT] = address
    self.Tail = address

    list = newList
  end

  table_insert(list, value)
  self.Size += 1
end

--[[
  Space Complexity: O(1)
  Time Complexity: Ω(1), O(chunkSize)
]]
function Module.remove(self: UnrolledLinkedList, index: number) -- might want to look at merges, but i'm too lazy to bother
  local address = self.Head :: number
  local list = self[address] :: {any}
  while address do
    local length = #list
    if index < length then
      break
    end
    
    index -= length
    address = self[address + NEXT]
    list = self[address]
  end

  local removed = table_remove(list, index + 1)
  self.Size -= 1

  if #list == 0 then
    local prev = nil
    local current = self.Head

    while current and current ~= address do
      prev = current
      current = self[current + NEXT]
    end

    if not current then
      return
    end

    local next = self[current + NEXT]

    if prev then
      self[prev + NEXT] = next
    else
      self.Head = next
    end

    if self.Tail == current then
      self.Tail = prev
    end

    self[current] = self.FreeHead
    self.FreeHead = current
  end

  return removed
end


-- -- End

return Module
