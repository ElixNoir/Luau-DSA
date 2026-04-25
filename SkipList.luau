--- Author: COMT

--[[

  SkipList

]]

--!native
--!optimize 2
--!strict


-- -- State

local Module = {}
Module.__index = Module

export type SkipList = typeof(setmetatable({} :: {
  FreeHead: false | number,
  Head: number,
  Level: number,
  Size: number,
  [number]: false | {number} | any
}, Module))


-- -- Constants

local MAX_LEVEL = 16
local P = 0.5

local VALUE = 1


-- -- Helpers

local math_random = math.random

local table_concat = table.concat
local table_create = table.create

local function allocate(self: SkipList, level: number, value: any): (number, {number})
  local address = self.FreeHead
  if address then
    self.FreeHead = self[address + VALUE]
  else
    address = #self + 1
  end

  local forwardList = table_create(level) :: {number}
  self[address :: number] = forwardList
  self[address :: number + VALUE] = value
  
  self.Size += 1
  
  return address :: number, forwardList
end

local function free(self: SkipList, address: number)
  local freeHead = self.FreeHead

  self[address] = false
  self[address + VALUE] = freeHead
  
  self.FreeHead = address
  self.Size -= 1
end

local function findPath(self: SkipList, value: any): {number}
  local address = self.Head
  local update = table_create(MAX_LEVEL) :: {number}

  for level = self.Level, 1, -1 do
    local forwardList = self[address]

    while true do
      local nextAddress = forwardList[level]
      if not nextAddress or self[nextAddress + VALUE] >= value then
        break
      end
      address = nextAddress
      forwardList = self[address]
    end

    update[level] = address
  end

  return update
end

local function randomLevel(): number
  local level = 1
  while math_random() < P and level < MAX_LEVEL do
    level += 1
  end
  return level
end


-- -- Functions

function Module.new(): SkipList
  local self = setmetatable({
    FreeHead = false,
    Head = 1,
    Level = 1,
    Size = 1,
    [1] = table_create(MAX_LEVEL),
    [2] = false
  }, Module)

  return self
end


-- -- Metamethods

function Module.__tostring(self: SkipList): string
  local head = self.Head
  
  local result = {}
  
  local address = self[head][1] :: number?
  while address do
    result[#result + 1] = tostring(self[address + VALUE])
    address = self[address][1]
  end

  return table_concat(result, ", ")
end


-- -- Methods

function Module.find(self: SkipList, value: any): number?
  local address = self.Head
  local forwardList = self[address]

  for index = self.Level, 1, -1 do
    while true do
      local nextAddress = forwardList[index] :: number?
      if not nextAddress or self[nextAddress + VALUE] >= value then
        break
      end
      address = nextAddress
      forwardList = self[nextAddress]
    end
  end

  address = forwardList[1] :: number?
  if address and self[address + VALUE] == value then
    return address
  end

  return nil
end

function Module.insert(self: SkipList, value: any)
  local update = findPath(self, value)
  local randLevel = randomLevel()

  local level = self.Level
  if randLevel > level then
    local head = self.Head
    for index = level + 1, randLevel do
      update[index] = head
    end
    self.Level = randLevel
  end

  local address, forwardList = allocate(self, randLevel, value)

  for index = 1, randLevel do
    local other = update[index]
    local otherForwardList = self[other]
    forwardList[index] = otherForwardList[index]
    otherForwardList[index] = address
  end
end

function Module.upsert(self: SkipList, value: any)
  local update = findPath(self, value)
  local nextAddress = self[update[1]][1] :: number?

  if nextAddress and self[nextAddress + VALUE] == value then
    self[nextAddress + VALUE] = value -- may compare as the same thing, but not necessarily be the same thing
    return
  end

  self:insert(value)
end

function Module.remove(self: SkipList, value: any)
  local update = findPath(self, value)
  local address = self[update[1]][1] :: number?

  if not address or self[address + VALUE] ~= value then
    return false
  end

  local thisForwardList = self[address]
  local level = self.Level
  for index = 1, level do
    local forwardList = self[update[index]] :: {number}
    if forwardList[index] ~= address then
      break
    end
    forwardList[index] = thisForwardList[index]
  end

  local headForwardList = self[self.Head]
  while level > 1 and not headForwardList[level] do
    level -= 1
  end

  free(self, address)

  self.Level = level

  return true
end


-- -- End

return Module
