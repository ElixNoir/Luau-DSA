--- Author: COMT

--[[

  CountMinSketch

]]

--!native
--!optimize 2
--!strict


-- -- State

local Module = {}
Module.__index = Module

export type CountMinSketch = typeof(setmetatable({} :: {
  Depth: number,
  Width: number,
  Seeds: {number},
  [number]: number
}, Module))


-- -- Helpers

local bit32_band = bit32.band
local bit32_bxor = bit32.bxor
local bit32_lshift = bit32.lshift
local bit32_rshift = bit32.rshift

local math_Huge = math.huge
local math_random = math.random

local string_byte = string.byte

local table_create = table.create

-- Simple 32-bit mix hash
local function mixHash(x: number, seed: number): number
    x = bit32_bxor(x, seed)
    x = bit32_bxor(x, bit32_rshift(x, 16))
    x = (x * 0x7feb352d) % 0x100000000
    x = bit32_bxor(x, bit32_rshift(x, 15))
    x = (x * 0x846ca68b) % 0x100000000
    x = bit32_bxor(x, bit32_rshift(x, 16))
    return x
end


-- -- Functions

-- Constructor
function Module.new(width: number, depth: number): CountMinSketch
  local self = table_create(depth * width, 0) :: CountMinSketch
  self.Depth = depth
  self.Width = width

  local seeds = table_create(depth, 0)
  self.Seeds = seeds
  for index = 1, depth do
    seeds[index] = math_random(1, 0x7FFFFFFF)
  end

  return setmetatable(self, Module)
end

local function stringHash(str: string): number
    local hash = 2166136261
    for i = 1, #str do
        hash = bit32_bxor(hash, string_byte(str, i))
        hash = (hash * 16777619) % 0x100000000
    end
    return hash
end

local function normalize(value: any): number
    if typeof(value) == "number" then
        return value
    elseif typeof(value) == "string" then
        return stringHash(value)
    else
        error("Unsupported key type")
    end
end

--[[
  Add to the frequency of a given value.

  Space Complexity: O(1)
  Time Complexity: Ω(n), O(n)
]]
function Module.add(self: CountMinSketch, value: any, count: number)
  local base = normalize(value)

  local width = self.Width
  local seeds = self.Seeds

  for row = 1, self.Depth do
    local hash = mixHash(base, seeds[row])
    local column = hash % self.Width

    self[(row - 1) * width + column + 1] += count
  end
end

--[[
  Estimate the frequency of a given value.
  returns: estimatedFrequency

  Space Complexity: O(1)
  Time Complexity: Ω(n), O(n)
]]
function Module.estimate(self: CountMinSketch, value: any): number
    local base = normalize(value)

    local width = self.Width
    local seeds = self.Seeds

    local minVal = math.huge

    for row = 1, self.Depth do
        local hash = mixHash(base, seeds[row])
        local column = hash % self.Width

        local val = self[(row - 1) * width + column + 1]
        if val < minVal then
            minVal = val
        end
    end

    return minVal
end


-- -- End

return Module
