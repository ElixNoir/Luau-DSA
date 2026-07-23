--- Author: COMT

--[[

	HashSort

]]

--!native
--!strict


-- -- End

--[[
	HashSort

	Space Complexity: O(1)
	Time Complexity: O(n)
	Stability: Stable
]]
return function(list: {number})
  local length = #list
  
  local hysteresisCount = 0
  local position = 1
  local swapCount = 0
  
  local value: number
  local other: number

  while swapCount ~= length and hysteresisCount ~= length do
    value = list[position]
    other = list[value]
    if other == value then
      hysteresisCount += 1
      position += 1
    else
      list[position], list[value] = other, value
      swapCount += 1
    end
  end
end
