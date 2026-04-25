--- Author: COMT

--[[

  QuotientFilter

]]

--!native
--!optimize 2
--!strict


-- -- State

local Module = {}
Module.__index = Module

export type QuotientFilter = typeof(setmetatable({} :: {
  Size: number,
  Mask: number,
  QBits: number,
  RBits: number,

  Occupied: {boolean},
  Continuation: {boolean},
  Shifted: {boolean},
  [number]: number
}, Module))


-- -- Helpers

local bit32_band = bit32.band
local bit32_lshift = bit32.lshift
local bit32_rshift = bit32.rshift
local bit32_bxor = bit32.bxor

local string_byte = string.byte

local table_create = table.create

local function findRun(self: QuotientFilter, quotient: number): number
  local continuation = self.Continuation
  local mask = self.Mask
  local occupied = self.Occupied
  local shifted = self.Shifted
  
  local index = quotient
  while shifted[index] do
    index = bit32_band(index - 1, mask)
  end

  local currentQuotient = index
  while currentQuotient ~= quotient do
    repeat
      index = bit32_band(index + 1, mask)
    until not continuation[index]

    repeat
      currentQuotient = bit32_band(currentQuotient + 1, mask)
    until occupied[currentQuotient]
  end

  return index
end

local function splitHash(self: QuotientFilter, value: any): (number, number)
  if typeof(value) == "string" then
    local hash = 2166136261
    for index = 1, #value do
        hash = (bit32_bxor(hash, string_byte(value, index)) * 16777619) % 0x100000000
    end
    value = hash
  else
    error("Unsupported key type")
  end
  
  value = bit32_bxor(value, bit32_rshift(value, 16))
  value = (value * 0x7feb352d) % 0x100000000
  value = bit32_bxor(value, bit32_rshift(value, 15))
  value = (value * 0x846ca68b) % 0x100000000
  value = bit32_bxor(value, bit32_rshift(value, 16))

  local rBits = self.RBits
  return bit32_band(bit32_rshift(value, rBits), self.Mask), bit32_band(value, bit32_lshift(1, rBits) - 1)
end


-- -- Functions

function Module.new(qBits: number, rBits: number): QuotientFilter
  local size = 2 ^ qBits
  local self = table_create(size, 0) :: QuotientFilter
  self.QBits = qBits
  self.RBits = rBits
  self.Size = size
  self.Mask = size - 1
  self.Occupied = table_create(size, false) :: {boolean}
  self.Continuation = table_create(size, false) :: {boolean}
  self.Shifted = table_create(size, false) :: {boolean}
  
  return setmetatable(self, Module)
end


-- -- Methods

function Module.insert(self: QuotientFilter, value: any)
  local continuation = self.Continuation
  local mask = self.Mask
  local shifted = self.Shifted
  
  local quotient, remainder = splitHash(self, value)

  self.Occupied[quotient] = true

  local index = findRun(self, quotient)

  while continuation[index] and self[index] < remainder do
    index = bit32_band(index + 1, mask)
  end

  local insertPosition = index

  local currentRemainder = remainder
  local currentContinuation = false
  local curShift = (insertPosition ~= quotient)

  while true do
    local oldRemainder = self[insertPosition]
    local oldContinuation = continuation[insertPosition]
    local oldShift = shifted[insertPosition]

    self[insertPosition] = currentRemainder
    continuation[insertPosition] = currentContinuation
    shifted[insertPosition] = curShift

    if oldRemainder == 0 and not oldShift then
      break
    end

    currentRemainder = oldRemainder
    currentContinuation = true
    curShift = true

    insertPosition = bit32_band(insertPosition + 1, mask)
  end
end

function Module.contains(self: QuotientFilter, value: any): boolean
  local quotient, remainder = splitHash(self, value)

  if not self.Occupied[quotient] then
    return false
  end

  local continuation = self.Continuation
  local mask = self.Mask
  
  local index = findRun(self, quotient)

  repeat
    if self[index] == remainder then
      return true
    end
    index = bit32_band(index + 1, mask)
  until not continuation[index]

  return false
end

function Module.remove(self: QuotientFilter, value: any): boolean
  local quotient, remainder = splitHash(self, value)

  if not self.Occupied[quotient] then
    return false
  end

  local continuation = self.Continuation
  local mask = self.Mask
  local shifted = self.Shifted
  
  local index = findRun(self, quotient)

  repeat
    if self[index] == remainder then
      self[index] = 0
      continuation[index] = false
      shifted[index] = false
      return true
    end
    index = bit32_band(index + 1, mask)
  until not continuation[index]

  return false
end


-- -- End

return Module
