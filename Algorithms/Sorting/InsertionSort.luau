--- Author: COMT

--[[

	InsertionSort

]]

--!native
--!optimize 2
--!strict


-- -- Helpers


-- -- End

--[[
	InsertionSort

	Space Complexity: O(1)
	Time Complexity: Ω(n), O(n^2)
	Mispredictions: Unlikely
	Stability: Stable
]]
return function(list: {number})
	local length = #list 
	for i = 2, length do 
		local key = list[i] 
		local j = i - 1 

		while j >= 1 and list[j] > key do
			list[j + 1] = list[j] 
			j = j - 1
		end
		list[j + 1] = key
	end
end
