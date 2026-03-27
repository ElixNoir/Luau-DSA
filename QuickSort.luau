--- Author: COMT

--[[

	QuickSort

]]

--!native
--!optimize 2
--!strict


-- -- Helpers

--[[
	QuickSort

	Space Complexity: O(log(n))
	Time Complexity: Ω(n*log(n)), O(n^2)
	Mispredictions: Likely
	Stability: Unstable
]]
return function(list: {number}, low: number, high: number)
	local stack = {[1] = low, [2] = high}
	local top = 2

	while top > 0 do
		local right = stack[top]
		local left = stack[top - 1]
		top -= 2

		while left < right do
			local pivot = list[right]
			local index = left - 1

			for jndex = left, right - 1 do
				local vj = list[jndex]
				if vj <= pivot then
					index += 1
					list[index], list[jndex] = vj, list[index]
				end
			end

			index += 1

			list[index], list[right] = pivot, list[index]

			local inc = index + 1
			local dec = index - 1

			if dec - left < right - inc then
				if left < dec then
					right = dec
				else
					if inc < right then
						stack[top + 1] = inc
						stack[top + 2] = right
						top += 2
					end
					break
				end
			else
				if inc < right then
					left = inc
				else
					if left < dec then
						stack[top + 1] = left
						stack[top + 2] = dec
						top += 2
					end
					break
				end
			end
		end
	end
end
