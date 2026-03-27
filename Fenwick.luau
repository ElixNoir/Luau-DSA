--- Author: COMT

--[[

	FenwickTree

]]

--!native
--!optimize 2
--!strict


-- -- State

local Module = {}
Module.__index = Module

export type FenwickTree = typeof(setmetatable({} :: {
	number
}, Module))


-- -- Helpers

local bit32_band = bit32.band
local bit32_countlz = bit32.countlz
local bit32_lshift = bit32.lshift
local bit32_rshift = bit32.rshift

local table_create = table.create


-- -- Functions

--[[
	Space Complexity: O(1)
	Time Complexity: Ω(n), O(nlog(n))
]]
function Module.fromArray(array: {number}): FenwickTree
	local length = #array
	local self = setmetatable(table_create(length, 0), Module)
	for index = 1, #array do
		while index <= length do
			self[index] += array[index]
			index += bit32_band(index, -index)
		end
	end
	return self
end

--[[
	Space Complexity: O(1)
	Time Complexity: O(n)
]]
function Module.new(size: number?): FenwickTree
	return setmetatable(table_create(size or 0, 0), Module)
end


-- -- Methods

--[[
	Space Complexity: O(1)
	Time Complexity: Ω(n), O(n)
]]
function Module.buildAllAlive(self: FenwickTree, n: number)
	for index = 1, n do
		self[index] = bit32_band(index, -index)
	end
end

--[[
	Find smallest index whose prefix sum >= k.
	
	Assert:
	- k <= totalSum
	
	Space Complexity: O(1)
	Time Complexity: Ω(log(n)), O(log(n))
]]
function Module.findKth(self: FenwickTree, k: number): number
	local length = #self
	
	local bit = bit32_lshift(1, 31 - bit32_countlz(length))
	
	local index = 0
	while bit > 0 do
		local next = index + bit
		local value = self[next]
		if next <= length and value < k then
			k -= value
			index = next
		end
		bit = bit32_rshift(bit, 1)
	end
	
	return index + 1
end

--[[
	Space Complexity: O(1)
	Time Complexity: Ω(1), O(log(n))
]]
local function prefixSum(self: FenwickTree, index: number): number
	local sum = 0
	while index > 0 do
		sum += self[index]
		index -= bit32_band(index, -index)
	end
	return sum
end Module.prefixSum = prefixSum

--[[
	Space Complexity: O(1)
	Time Complexity: Ω(1), O(log(n))
]]
local function rangeSum(self: FenwickTree, left: number, right: number): number
	if right < left then
		return 0
	end
	return prefixSum(self, right) - prefixSum(self, left - 1)
end Module.rangeSum = rangeSum

--[[
	Space Complexity: O(1)
	Time Complexity: Ω(1), O(log(n))
]]
local function update(self: FenwickTree, index: number, delta: number)
	local length = #self
	while index <= length do
		self[index] += delta
		index += bit32_band(index, -index)
	end
end Module.update = update

--[[
	Space Complexity: O(1)
	Time Complexity: Ω(1), O(log(n))
]]
function Module.pointQuery(self: FenwickTree, index: number): number
	return rangeSum(self, index, index)
end

--[[
	Space Complexity: O(1)
	Time Complexity: Ω(1), O(log(n))
]]
function Module.setValue(self: FenwickTree, index: number, value: number)
	update(self, index, value - rangeSum(self, index, index))
end


-- -- End

return Module
