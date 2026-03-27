--- Author: COMT

--[[

	BubbleSort

]]

--!native
--!optimize 2
--!strict


-- -- End

--[[
	BubbleSort

	Space Complexity: O(1)
	Time Complexity: Ω(n), O(n^2)
	Mispredictions: Likely
	Stability: Stable
]]
return function(list: {number})
	local length = #list 
	local swapped: boolean
	repeat
		swapped = false
		local j = 2
		for i = 1, length - 1 do 
			local a, b = list[i], list[j]
			if a > b then
				list[i], list[j] = b, a
				swapped = true
			end
			j += 1
		end
		length -= 1
	until not swapped
end
