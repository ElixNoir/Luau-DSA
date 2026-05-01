--- Author: COMT

--[[

	HeapSort

]]

--!native
--!optimize 2
--!strict


-- -- End

--[[
	HeapSort

	Space Complexity: O(1)
	Time Complexity: Ω(n*log(n)), O(n*log(n))
	Mispredictions: Likely
	Stability: Unstable
]]
return function(list: {number}, low: number, high: number)
	local length = high - low + 1

	for start = (length // 2) - 1, 0, -1 do
		local root = start
		while true do
			local child = root * 2 + 1
			if child >= length then
				break
			end

			local c = low + child
			local c2 = c + 1
			local childIndex = child
			if child + 1 < length and list[c] < list[c2] then
				child += 1
				childIndex = child
			end

			local a, b = list[low + root], list[low + childIndex]
			if a < b then
				list[low + root], list[low + childIndex] = b, a
				root = child
			else
				break
			end
		end
	end

	for i = length - 1, 1, -1 do
		local first = low
		local last = low + i
		list[first], list[last] = list[last], list[first]

		local root = 0
		while true do
			local child = root * 2 + 1
			if child >= i then
				break
			end

			local c = low + child
			local c2 = c + 1
			local childIndex = child
			if child + 1 < i and list[c] < list[c2] then
				child += 1
				childIndex = child
			end

			local a, b = list[low + root], list[low + childIndex]
			if a < b then
				list[low + root], list[low + childIndex] = b, a
				root = child
			else
				break
			end
		end
	end
end
