--- Author: COMT

--[[

	CombSort

]]

--!native
--!strict


-- -- Helpers

local math_max = math.max


-- -- End

--[[
	CombSort

	Space Complexity: O(1)
	Time Complexity: Ω(nlog(n)), O(n^2)
	Mispredictions: Likely
	Stability: Unstable
]]
return function(list: {number})
  local length = #list
  local gap = length
  local swapped = true
  while gap > 1 or swapped do
    gap = math_max(1, gap // 1.3)
    swapped = false
    
    for index = 1, length - gap do
      local a, b = list[index], list[index + gap]
      if a > b then
        list[index], list[index + gap] = b, a
        swapped = true
      end
    end
  end
end
