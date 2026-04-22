--- Author: COMT

--[[

  WrappedBuffer

]]

--!native
--!optimize 2
--!strict


-- -- State

local Module = {}
Module.__index = Module

export type WrappedBuffer = typeof(setmetatable({} :: {
  ReadAddress: number,
  WriteAddress: number,
  [number]: any
}, Module))


-- -- Helpers

local table_create = table.create


-- -- Functions

function Module.new(capacity: number?): WrappedBuffer
  local self = table_create(capacity or 0)
  self.ReadAddress = 1
  self.WriteAddress = 1

  return setmetatable(self, Module)
end


-- -- Methods

--[[
  Append the given value, raising the size of the buffer.

  Space Complexity: O(1)
  Time Complexity: O(1)
]]
function Module.append(self: WrappedBuffer, value: any)
  self[#self + 1] = value
end

--[[
  Overwrite the next value.

  Space Complexity: O(1)
  Time Complexity: O(1)
]]
function Module.overwrite(self: WrappedBuffer, value: any)
  local length = #self
  local writeAddress = self.WriteAddress
  self[writeAddress] = value
  writeAddress = (writeAddress + 1) % length
end

--[[
  Consume and return the next value if there is one.
  returns: success

  Space Complexity: O(1)
  Time Complexity: O(1)
]]
function Module.read(self: WrappedBuffer): (boolean, any)
  local readAddress = self.ReadAddress
  local writeAddress = self.WriteAddress
  if readAddress == writeAddress then
    return false
  end

  local length = #self

  self.ReadAddress = (readAddress + 1) % length
  return true, self[readAddress]
end

--[[
  Write the given value if the buffer is not full.
  returns: success

  Space Complexity: O(1)
  Time Complexity: O(1)
]]
function Module.write(self: WrappedBuffer, value: any): boolean
  local length = #self
  local readAddress = self.ReadAddress
  local writeAddress = self.WriteAddress
  if readAddress == writeAddress % length then
    return false
  end

  self[writeAddress] = value
  writeAddress = (writeAddress + 1) % length
  return true
end


-- -- End

return Module
