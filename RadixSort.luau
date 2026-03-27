--- Author: COMT

--[[

	RadixSort

]]

--!native
--!optimize 2
--!strict


-- -- Helpers

local math_max = math.max

local table_clear = table.clear
local table_create = table.create
local table_move = table.move


-- -- End

--[[
  RadixSort

	Space Complexity: O(log(n))
	Time Complexity: Ω(d*(n+k)), O(d+k); d=digts, k=base
	Mispredictions: Likely
	Stability: Unstable
]]
return function(list: {number}, base: number?)
	base = base or 10

	local length = #list

	local maximum = list[1]
	for index = 2, length do
		maximum = math_max(maximum, list[index])
	end

	local count = table_create(base, 0)
	local output = table_create(length, 0)

	local exponent = 1

	while maximum // exponent > 0 do
		table_clear(count)

		for index = 1, length do
			count[(list[index] // exponent) % base + 1] += 1
		end

		for index = 2, base do
			count[index] += count[index - 1]
		end

		for index = length, 1, -1 do
			local digit = (list[index] // exponent) % base + 1
			output[count[digit]] = list[index]
			count[digit] -= 1
		end
		
		table_move(output, 1, length, 1, list)

		exponent *= base
	end
end
