--- Author: COMT

--[[

  HashedArrayTree

]]

--!native
--!optimize 2
--!strict


-- -- State

local Module = {}
Module.__index = Module

export type HashedArrayTree = typeof(setmetatable({} :: {
	BlockSize: number,
	[number]: {any}
}, Module))


-- -- Helpers

local table_create = table.create


-- -- Functions

function Module.new(blockPower: number?): HashedArrayTree
	return setmetatable({
		BlockSize = 2 ^ (blockPower or 4)
	}, Module)
end


-- -- Internal


-- -- Methods

--[[
  Space Complexity: O(1)
  Time Complexity: O(1)
]]
function Module.get(self: HashedArrayTree, index: number): any?
  local blockSize = self.BlockSize
  local block = self[index // blockSize + 1]
  if not block then
    return nil
  end

  return block[(index % blockSize) + 1]
end

--[[
  Space Complexity: O(1)
  Time Complexity: O(1)
]]
function Module.remove(self: HashedArrayTree, index: number)
  local blockSize = self.BlockSize
  local blockAddress = index // blockSize
  local block = self[blockAddress]
  if block then
    if not next(block) then
      self[blockAddress] = nil
      return
    end
    block[(index % blockSize) + 1] = nil
  end
end

--[[
  Space Complexity: O(1)
  Time Complexity: O(1)
]]
function Module.set(self: HashedArrayTree, index: number, value: any)
  local blockSize = self.BlockSize
  local blockAddress = index // blockSize + 1
  local block = self[blockAddress]
  if not block then
    block = table_create(blockSize)
    self[blockAddress] = block
  end
  block[(index % blockSize) + 1] = value
end

--[[
  Space Complexity: O(1)
  Time Complexity: O(n)
]]
function Module.iterate(self: HashedArrayTree, callback: (number, any) -> ())
  local blockSize = self.BlockSize
  for blockAddress, block in self do
    for index = 1, blockSize do
      local value = block[index]
      if value ~= nil then
        callback(blockAddress * blockSize + (index - 1), value)
      end
    end
  end
end


-- -- End

return Module
