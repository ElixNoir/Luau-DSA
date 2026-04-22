--- Author: COMT

--[[

  CuckooFilter

]]

--!native
--!optimize 2
--!strict


-- -- State

local Module = {}
Module.__index = Module

export type CuckooFilter = typeof(setmetatable({} :: {
  BucketSize: number,
  Mask: number,
  MaxKicks: number,
  [number]: number
}, Module))


-- -- Helpers

local bit32_band = bit32.band
local bit32_bxor = bit32.bxor
local bit32_rshift = bit32.rshift

local math_log = math.log
local math_random = math.random

local string_byte = string.byte

local table_create = table.create

local function index2(self: CuckooFilter, i1: number, fp: number): number
  fp = bit32_bxor(fp, bit32_rshift(fp, 16))
  fp = (fp * 0x7feb352d) % 0x100000000
  fp = bit32_bxor(fp, bit32_rshift(fp, 15))
  fp = (fp * 0x846ca68b) % 0x100000000
  fp = bit32_bxor(fp, bit32_rshift(fp, 16))
  return bit32_band(bit32_bxor(i1, fp), self.Mask)
end

local function mixHashNormalized(value: any): number
  if typeof(value) == "string" then
    local hash = 2166136261
    for index = 1, #value do
      hash = bit32_bxor(hash, string_byte(value, index))
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
  
  return value
end


-- -- Functions

function Module.new(capacityPower: number, bucketSize: number): CuckooFilter
  local capacity = 2 ^ capacityPower
  
  local self = table_create(capacity * bucketSize, 0) :: CuckooFilter
  self.BucketSize = bucketSize
  self.Mask = capacity - 1
  self.MaxKicks = 500

  return setmetatable(self, Module)
end


-- -- Methods

--[[
  Get whether a value is probably contained.

  Space Complexity: O(1)
  Time Complexity: O(bucketSize + string.len(value))
]]
function Module.contains(self: CuckooFilter, value: any): boolean
  local hash = mixHashNormalized(value)
  local fp = bit32_band(hash, 0xFF)
  if fp == 0 then
      fp = 1
  end

  local bucketSize = self.BucketSize
  
  local i1 = bit32_band(hash, self.Mask)
  local base = i1 * bucketSize
  for index = base + 1, base + bucketSize do
    if self[index] == fp then
      return true
    end
  end

  base = index2(self, i1, fp) * bucketSize
  for index = base + 1, base + bucketSize do
    if self[index] == fp then
      return true
    end
  end

  return false
end

--[[
  Insert a value.

  Space Complexity: O(1)
  Time Complexity: O(bucketSize + string.len(value))
]]
function Module.insert(self: CuckooFilter, value: any): boolean
  local hash = mixHashNormalized(value)
  local fp = bit32_band(hash, 0xFF)
  if fp == 0 then
      fp = 1
  end

  local bucketSize = self.BucketSize

  local i1 = bit32_band(hash, self.Mask)
  local base = i1 * bucketSize
  for index = base + 1, base + bucketSize do
    if self[index] == 0 then
      self[index] = fp
      return true
    end
  end

  local i2 = index2(self, i1, fp)
  base = i2 * bucketSize
  for index = base + 1, base + bucketSize do
    if self[index] == 0 then
      self[index] = fp
      return true
    end
  end

  local i = (math_random() < 0.5) and i1 or i2

  for _ = 1, self.MaxKicks do
    local index = i * bucketSize + math_random(1, bucketSize)
    fp, self[index] = self[index], fp
    i = index2(self, i, fp)

    base = i * bucketSize
    for index = base + 1, base + bucketSize do
      if self[index] == 0 then
        self[index] = fp
        return true
      end
    end
  end

  return false -- table likely full
end

--[[
  Remove a value.

  Space Complexity: O(1)
  Time Complexity: O(bucketSize + string.len(value))
]]
function Module.remove(self: CuckooFilter, value: any): boolean
  local hash = mixHashNormalized(value)
  local fp = bit32_band(hash, 0xFF)
  if fp == 0 then
      fp = 1
  end

  local bucketSize = self.BucketSize
  
  local i = bit32_band(hash, self.Mask)
  local base = i * bucketSize
  for index = base + 1, base + bucketSize do
    if self[index] == fp then
      self[index] = 0
      return true
    end
  end

  base = index2(self, i, fp) * bucketSize
  for index = base + 1, base + bucketSize do
    if self[index] == fp then
      self[index] = 0
      return true
    end
  end

  return false
end


-- -- End

return Module
