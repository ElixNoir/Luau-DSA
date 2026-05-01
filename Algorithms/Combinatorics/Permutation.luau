--- Author: COMT

--[[

	Permutation - A module for permuting

]]

--!native
--!optimize 2
--!strict


-- -- State

local FenwickTree = require("./FenwickTree")

local Module = {}


-- -- Helpers

local table_clone = table.clone
local table_find = table.find
local table_remove = table.remove

local Factorials: {number} = {[0] = 1, 1, 2, 6, 24, 120, 720, 5040, 40320, 362880, 3628800, 39916800, 479001600, 6227020800, 87178291200, 1307674368000, 20922789888000, 355687428096000, 6402373705728000}


-- -- Functions

--[[
	Space Complexity: O(1)
	Time Complexity: Ω(n^2), O(n^2)
]]
function Module.permutationOffset(initialList: {any}, alternateList: {any}): number
	local length = #initialList

	local available = table_clone(initialList)
	local offset = 0

	for position = 1, length do
		local element = alternateList[position]

		local index = table_find(available, element) :: number

		offset += (index - 1) * Factorials[length - position]
		table_remove(available, index)
	end

	return offset
end

--[[
	Space Complexity: O(1)
	Time Complexity: Ω(n*log(n)), O(n*log(n))
]]
function Module.permutationOffsetWithFenwick(initialList: {any}, permutation: {any}): number
	local length = #initialList
	if length <= 1 then
		return 0
	end

	local ranks = {}
	for index = 1, #initialList do
		ranks[initialList[index]] = index
	end

	local fenwickTree = FenwickTree.new(length)
	fenwickTree:buildAllAlive(length)

	local offset = 0

	for position = 1, length do
		local rank = ranks[permutation[position]]
		local unused = fenwickTree:prefixSum(rank - 1)
		offset += unused * Factorials[length - position]

		fenwickTree:update(rank, -1)
	end

	return offset
end

--[[
	Space Complexity: O(1)
	Time Complexity: Ω(n*log(n)), O(n*log(n))
]]
function Module.permutationFromOffsetWithFenwick(initialList: {any}, offset: number): {any}
	local length = #initialList
	if length <= 1 then
		return {initialList[1]}
	end

	local result = table_create(length, 0)
	local fenwickTree = FenwickTree.new(length)
	fenwickTree:buildAllAlive(length)

	for position = 1, length do
		local blockSize = Factorials[length - position]

		local k = (offset / blockSize) // 1 + 1
		offset %= blockSize

		local rank = fenwickTree:findKth(k)

		result[position] = initialList[rank]
		fenwickTree:update(rank, -1)
	end

	return result
end

--[[
	Space Complexity: O(1)
	Time Complexity: Ω(n), O(n)
	Mispredictions: Likely
	Stability: Unstable
]]
function Module.permute(list: {any}, offset: number)
	local length = #list
	local available = table_clone(list)
	for position = 1, length do
		local factorial = Factorials[length - pos]
		list[position] = available[(offset // factorial) + position]
		offset %= factorial
	end
end


-- -- End

return Module
