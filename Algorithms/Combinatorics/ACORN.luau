--- Author: COMT

--[[

  ACORN - A pseudo-random number generator

]]

--!native
--!optimize 2
--!strict


-- -- State

local Module = {}
Module.__index = Module

export type ACORN = typeof(setmetatable({} :: {
  Order: number,
  Modulus: number,
  [number]: number
}, Module))


-- -- Helpers

local table_create = table.create

local os_time = os.time


-- -- Functions

--[[
  Expects: order >= 1

  Space Complexity: O(order)
  Time Complexity: O(order)
]]
function Module.new(order: number, seed: number?, modulus: number?): ACORN
  seed = seed or os_time()
  modulus = modulus or 0x100000000

  local self = table_create(order) :: ACORN
  self.Modulus = modulus
  self.Order = order

  local value = seed % modulus
  for index = 1, order do
    value = (1664525 * value + 1013904223) % modulus
    self[index] = value
  end

  return setmetatable(self, Module)
end

--[[
  Step over current generation.

  Space Complexity: O(1)
  Time Complexity: O(order)
]]
local function step(self: ACORN)
  local m = self.Modulus
  local value = self[self.Order]
  for index = 1, self.Order do
    value = (self[index] + value) % m
    self[index] = value
  end
end Module.step = step

--[[
  returns: randomNumber

  Space Complexity: O(1)
  Time Complexity: O(1)
]]
function Module.next(self: ACORN): number
  step(self)
  return self[self.Order] / self.Modulus
end

--[[
  returns: randomInteger

  Space Complexity: O(1)
  Time Complexity: O(1)
]]
function Module.nextInteger(self: ACORN): number
  step(self)
  return self[self.Order]
end

--[[
  returns: randomNumberInRange

  Space Complexity: O(1)
  Time Complexity: O(?)
]]
function Module.nextInRange(self: ACORN, min: number, max: number): number
  local modulus = self.Modulus
  local range = max - min
  local limit = modulus - (modulus % range)
  while true do
    step(self)
    local value = self[self.Order]
    if value < limit then
      return min + range * value / modulus
    end
  end
end

--[[
  returns: randomIntegerInRange

  Space Complexity: O(1)
  Time Complexity: O(?)
]]
function Module.nextIntegerInRange(self: ACORN, min: number, max: number): number
  local modulus = self.Modulus
  local range = max - min
  local limit = modulus - (modulus % range)
  while true do
    step(self)
    local value = self[self.Order]
    if value < limit then
      return min + (value % range)
    end
  end
end


-- -- End

return Module
