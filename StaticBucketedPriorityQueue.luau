--- Author: COMT

--[[

  StaticBucketedPriorityQueue

]]

--!native
--!optimize 2
--!strict


-- -- State

local Module = {}
Module.__index = Module

type Queue = {
  Bottom: number,
  Top: number,
  [number]: any
}

export type StaticBucketedPriorityQueue = typeof(setmetatable({} :: {
  Mask: number,
  [number]: Queue
}, Module))


-- -- Helpers

local bit32_band = bit32.band
local bit32_bnot = bit32.bnot
local bit32_bor = bit32.bor
local bit32_countlz = bit32.countlz
local bit32_lshift = bit32.lshift


-- -- Functions

--[[
  Construct a new bucketed priority queue.
  returns: StaticBucketedPriorityQueue
]]
function Module.new(): StaticBucketedPriorityQueue
  local self = {Mask = 0}
  for index = 1, 32 do
    self[index] = {Bottom = 1, Top = 1}
  end

  return setmetatable(self, Module)
end


-- -- Methods

--[[
  Dequeue the first enqueued value at the highest priority.

  Space Complexity: O(1)
  Time Complexity: Ω(1), O(1)
]]
function Module.dequeue(self: StaticBucketedPriorityQueue): (any, number)
  local mask = self.Mask
  if mask == 0 then
    return
  end
  
  local priority = 32 - bit32_countlz(mask)
  local queue = self[priority]
  local bottom = queue.Bottom
  local value = queue[bottom]
  
  if bottom == queue.Top then
    queue.Bottom, queue.Top = 1, 1
    self.Mask = bit32_band(mask, bit32_bnot(bit32_lshift(1, priority - 1)))
  else
    queue.Bottom = bottom + 1
  end

  return value, priority
end

--[[
  Enqueue a value at a priority.

  Space Complexity: O(1)
  Time Complexity: Ω(1), O(1)
]]
function Module.enqueue(self: StaticBucketedPriorityQueue, value: any, priority: number)
  local queue = self[priority]
  local top = queue.Top
  queue[top] = value
  queue.Top = top + 1
  
  self.Mask = bit32_bor(self.Mask, bit32_lshift(1, priority - 1))
end

--[[
  Peek the first enqueued value at the highest priority.

  Space Complexity: O(1)
  Time Complexity: Ω(1), O(1)
]]
function Module.peek(self: StaticBucketedPriorityQueue): (any, number)
  local mask = self.Mask
  if mask == 0 then
    return
  end
  
  local priority = 32 - bit32_countlz(mask)
  local queue = self[priority]
  local value = queue[queue.Bottom]

  return value, priority
end


-- -- End

return Module
