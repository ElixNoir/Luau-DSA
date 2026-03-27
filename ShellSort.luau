--- Author: COMT

--[[

	ShellSort

]]

--!native
--!optimize 2
--!strict


-- -- End

--[[
  ShellSort

  Space Complexity: O(1)
  Time Complexity: O(n(log(n))^2)
  Mispredictions: Likely
  Stability: Unstable
]]
return function(list: {number})
  local length = #list
  local gap = length // 2
  while gap > 0 do
    gap //= 2
    for index = gap, length do
      local temporary = list[index]
      while index >= gap and list[index - gap] > temporary do
        list[index] = list[index - gap]
        index -= gap
      end
      list[index] = temporary
    end
  end
end
