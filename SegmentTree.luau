--- Author: COMT

--[[

  SegmentTree

]]

--!native
--!optimize 2
--!strict


-- -- State

local Module = {}
Module.__index = Module

export type SegmentTree = typeof(setmetatable({} :: {
  Identity: any,
  Merge: (any, any) -> any,
  Size: number,
  [number]: any
}, Module))


-- -- Helpers

local math_ceil = math.ceil
local math_log = math.log

local table_create = table.create
local table_move = table.move


-- -- Functions

function Module.new(array: {any}, merge: (any, any) -> any, identity: any): SegmentTree
  local length = #array
  local size = 2 ^ math_ceil(math_log(length, 2))

  local self = table_create(2 * size, identity) :: SegmentTree
  table_move(array, 1, length, size, self)
  for index = size - 1, 1, -1 do
    self[index] = merge(self[2 * index], self[2 * index + 1])
  end
  self.Identity = identity
  self.Merge = merge
  self.Size = size

  return setmetatable(self, Module)
end

--[[
  Query a range.

  Space Complexity: O(1)
  Time Complexity: Ω(1), O(log(n))
]]
function Module.query(self: SegmentTree, left: number, right: number): any
  local merge = self.Merge
  local resLeft = self.Identity
  local resRight = resLeft

  local decSize = self.Size - 1
  left += decSize
  right += decSize

  while left <= right do
    if (left % 2) == 1 then
      resLeft = merge(resLeft, self[left])
      left += 1
    end

    if (right % 2) == 0 then
      resRight = merge(self[right], resRight)
      right -= 1
    end

    left //= 2
    right //= 2
  end

  return merge(resLeft, resRight)
end

--[[
  Space Complexity: O(1)
  Time Complexity: Ω(1), O(log(n))
]]
function Module.update(self: SegmentTree, index: number, value: any)
  local merge = self.Merge

  index += self.Size - 1
  self[index] = value

  index = (index // 2) * 2 -- if it's odd, set it to even
  while index >= 1 do
    self[index] = merge(self[index], self[index + 1])
    index //= 2
  end
end


-- -- End

return Module
