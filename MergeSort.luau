--- Author: COMT

--[[

	MergeSort

]]

--!native
--!optimize 2
--!strict


-- -- Helpers

local math_min = math.min

local table_create = table.create
local table_move = table.move


-- -- End

--[[
	MergeSort

	Space Complexity: O(n)
	Time Complexity: Ω(n), O(n*log(n))
	Mispredictions: Likely
	Stability: Unstable
]]
return function(list: {number})
	local length = #list
	if length <= 1 then
		return
	end

	local src = list
	local dst = table_create(length, 0)

	local width = 1
	while width < length do
		local width2 = width * 2
		local index = 1
		while index <= length do
			local mid  = math_min(index + width - 1, length)
			local right = math_min(index + 2 * width - 1, length)

			local p = index
			local a = index
			local b = mid + 1

			while a <= mid and b <= right do
				local va = src[a]
				local vb = src[b]

				if va <= vb then
					dst[p] = va
					a += 1
				else
					dst[p] = vb
					b += 1
				end
				
				p += 1
			end
			
			if a > mid then
				table_move(src, b, right, p, dst)
				p += (right - b + 1)
			end
			
			if b > right then
				table_move(src, a, mid, p, dst)
				p += (mid - a + 1)
			end

			index += width2
		end

		src, dst = dst, src
		width = width2
	end

	if src ~= list then
		table_move(src, 1, length, 1, list)
	end
end
