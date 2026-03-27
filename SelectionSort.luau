--- Author: COMT

--[[

	SelectionSort

]]

--!native
--!optimize 2
--!strict


-- -- End

--[[
	SelectionSort

	Space Complexity: O(1)
	Time Complexity: Ω(n^2), O(n^2)
	Mispredictions: Unlikely
	Stability: Stable
]]
return function(list: {number})
	local length = #list 
	for i = 1, length - 1 do 
		local minIndex = i 
		for j = i + 1, length do
			if list[j] < list[minIndex] then
				minIndex = j
			end
		end

		if minIndex ~= i then
			list[i], list[minIndex] = list[minIndex], list[i]
		end
	end 
end
