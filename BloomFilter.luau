--- Author: COMT

--[[

  BloomFilter

]]

--!native
--!optimize 2
--!strict


-- -- State

local Module = {}
Module.__index = Module

export type BloomFilter = typeof(setmetatable({} :: {
  BucketCount: number, HashCount: number,
  [number]: number
}, Module))


-- -- Helpers

local bit32_band = bit32.band
local bit32_bor = bit32.bor
local bit32_bxor = bit32.bxor
local bit32_lshift = bit32.lshift

local string_byte = string.byte

local table_create = table.create


-- -- Functions

function Module.new(bucketCount: number, hashCount: number): BloomFilter
  local self = table_create(bucketCount, 0) :: BloomFilter
  self.BucketCount = bucketCount * 32
  self.HashCount = hashCount
  
  return setmetatable(self, Module)
end


-- -- Methods

local function hashes(self: BloomFilter, key: string): {number}
  local hash1 = 5381
  for index = 1, #key do
    hash1 = bit32_band((hash1 * 33 + string_byte(key, index)), 0xFFFFFFFF)
  end
  
  local hash2 = bit32_bxor(hash1, 0x5bd1e995)

  local bucketCount, hashCount = self.BucketCount, self.HashCount
  local results = table_create(hashCount, 0)

  for index = 1, hashCount do
    local combined = (hash1 + (index - 1) * hash2) % bucketCount
    results[index] = combined
  end

  return results
end

--[[
  Add the given key to the BloomFilter.

  Space Complexity: O(1)
  Time Complexity: Ω(#key), O(#key)
]]
function Module.add(self: BloomFilter, key: string)
  for _, index in ipairs(hashes(self, key)) do
    local bucket, offset = index // 32 + 1, index % 32
    self[bucket] = bit32_bor(self[bucket], bit32_lshift(1, offset))
  end
end

--[[
  Get whether the given key is probably contained within this BloomFilter.
  returns: containsKey

  Space Complexity: O(1)
  Time Complexity: Ω(#key), O(#key)
]]
function Module.probablyContains(self: BloomFilter, key: string): boolean
  for _, index in ipairs(hashes(self, key)) do
    local bucket, offset = index // 32 + 1, index % 32
    if bit32_band(self[bucket], bit32_lshift(1, offset)) == 0 then
      return false
    end
  end
  
  return true
end


-- -- End

return Module
