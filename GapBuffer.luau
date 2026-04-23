--- Author: COMT

--[[

  GapBuffer

]]

--!native
--!optimize 2
--!strict


-- -- State

local Module = {}
Module.__index = Module

export type GapBuffer = typeof(setmetatable({} :: {
  End: number,
  Start: number,
  [number]: any
}, Module))


-- -- Helpers

local table_concat = table.concat
local table_create = table.create
local table_move = table.move


-- -- Functions

function Module.new(capacity: number?): GapBuffer
  capacity = capacity or 16
  
  return setmetatable({
    Buffer = table_create(capacity, false),
    End = capacity,
    Start = 1
  }, Module)
end


-- -- Metamethods

--[[
  Concatenate all values into a string.
  returns: stringOfValues

  Space Complexity: O(n)
  Time Complexity: O(n)
]]
function Module.__tostring(self: GapBuffer): string
  return table_concat(self:get())
end


-- -- Methods

--[[
  Ensure that a gap exists, usually before inserting more values.

  It is worth noting that this would normally manually handle dynamic array resizing.

  Space Complexity: O(1)
  Time Complexity: O(1)
]]
function Module.ensureGap(self: GapBuffer, size: number)
  local _end = self.End
  if _end - self.Start + 1 >= size then
      return
  end

  self.End = _end + size
end

--[[
  Get a representation of the buffer without the gap.
  returns: buffer

  Space Complexity: O(n)
  Time Complexity: O(n)
]]
function Module.moveCursor(self: GapBuffer, position: number)
  local _end = self.End
  local start = self.Start
  local cursor = start
  if position < cursor then
    local shift = cursor - position
    _end += 1
    for index = 1, shift do
      self[_end - index] = self[start - index]
      --self[start - index] = false
    end
    self.End = _end - shift - 1
    self.Start = start - shift
  elseif position > cursor then
    local shift = position - cursor
    start -= 1
    for index = 1, shift do
      self[start + index] = self[_end + index]
      --self[_end + index] = false
    end
    self.End = _end + shift
    self.Start = start + shift + 1
  end
end

--[[
  Get a representation of the buffer without the gap.
  returns: buffer

  Optimizations:
  - table_move

  Space Complexity: O(n)
  Time Complexity: O(n)
]]
function Module.get(self: GapBuffer): {any}
  local result = {}

  local top = self.Start
  table_move(self, 1, top - 1, 1, result)
  table_move(self, self.End + 1, #self, top, result)

  return result
end

--[[
  Insert a value.

  Space Complexity: O(1)
  Time Complexity: O(1)
]]
function Module.insert(self: GapBuffer, value: any)
  self:ensureGap(1)

  local start = self.Start
  self[start] = value
  self.Start = start + 1
end

--[[
  Insert multiple values.

  Optimizations:
  - batching
  - table_move

  Space Complexity: O(1)
  Time Complexity: O(n)
]]
function Module.insertMany(self: GapBuffer, values: {any})
  local length = #values
  
  self:ensureGap(length)

  local start = self.Start
  table_move(values, 1, length, start, self)
  self.Start = start + length
end

--[[
  Remove a given count of values.

  Optimizations:
  - batching
  - table_move

  Space Complexity: O(1)
  Time Complexity: O(count)
]]
function Module.remove(self: GapBuffer, count: number?)
  count = count or 1

  local _end = self.End
  local newEnd = _end + count
  table_move(self, _end + 1, newEnd, _end, self)
  table_move(Module, 1, count - 1, _end + 1, self) -- 'Module' does not have any initialized values in its array, so this works

  self.End = newEnd
end

--[[
  Get the number of values not in a gap.
  returns: size

  Space Complexity: O(1)
  Time Complexity: O(1)
]]
function Module.size(self: GapBuffer): number
  return self.End - self.Start + 1
end


-- -- End

return Module
