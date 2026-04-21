--- Author: COMT

--[[

  HyperLogLog

]]

--!native
--!optimize 2
--!strict


-- -- State

local Module = {}
Module.__index = Module

export type HyperLogLog = typeof(setmetatable({} :: {
    M: number,
    P: number,
    [number]: number
}, Module))


-- -- Helpers

local bit32_band = bit32.band
local bit32_bxor = bit32.bxor
local bit32_countlz = bit32.countlz
local bit32_rshift = bit32.rshift
local bit32_lshift = bit32.lshift

local math_log = math.log

local string_byte = string.byte

local table_create = table.create


-- -- Functions

function Module.new(p: number): HyperLogLog
  local m = 2 ^ p
  local self = table_create(m, 0) :: HyperLogLog
  self.P = p
  self.M = m

  return setmetatable(self, Module)
end


-- -- Methods

--[[
  Add to the frequency of a given value.

  Space Complexity: O(1)
  Time Complexity: Ω(1), O(1)
]]
function Module.add(self: HyperLogLog, value: any)
  local p = self.P

  if typeof(value) == "string" then
    local hash = 2166136261
    for i = 1, #value do
      hash = bit32_bxor(hash, string_byte(value, i))
      hash = (hash * 16777619) % 0x100000000
    end
    value = hash
  elseif typeof(value) ~= "number" then
    error("Unsupported key type")
  end
  
  value = bit32_bxor(value, 0x9e3779b9)
  value = bit32_bxor(value, bit32_rshift(value, 16))
  value = (value * 0x7feb352d) % 0x100000000
  value = bit32_bxor(value, bit32_rshift(value, 15))
  value = (value * 0x846ca68b) % 0x100000000
  value = bit32_bxor(value, bit32_rshift(value, 16))

  local index = bit32_rshift(value, 32 - p) + 1
  local rank = bit32_countlz(bit32_lshift(value, p)) + 1 
  if rank > self[index] then
    self[index] = rank
  end
end

--[[
  Estimate the frequency of a given value.

  Space Complexity: O(1)
  Time Complexity: Ω(m), O(m)
]]
function Module.estimate(self: HyperLogLog): number
  local m = self.M

  local sum = 0
  local zeros = 0

  for i = 1, m do
      local v = self[i]
      sum += 2 ^ (-v)
      if v == 0 then
          zeros += 1
      end
  end

  local estimate = ((m == 16 and 0.673) or (m == 32 and 0.697) or (m == 64 and 0.709) or 0.7213 / (1 + 1.079 / m)) * m * m / sum
  if estimate <= 2.5 * m and zeros > 0 then
      estimate = m * math_log(m / zeros)
  end

  return estimate
end


-- -- End

return Module
