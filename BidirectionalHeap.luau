--- Author: COMT

--[[

  BidirectionalHeap

]]


--!native
--!strict

local Module = {}
Module.__index = Module

export type BidirectionalHeap = typeof(setmetatable({} :: {
  Size: number,
  [number]: any
}, Module))


-- -- Helpers

local math_log = math.log


-- -- Functions

function Module.new(): BidirectionalHeap
  return setmetatable({
    Size = 0
  }, Module)
end

function Module._pushUpMin(self: BidirectionalHeap, index: number)
  while index > 3 do
    local grand = index // 4
    if self[index] < self[grand] then
      self[index], self[grand] = self[grand], self[index]
      index = grand
    else
      break
    end
  end
end

function Module._pushUpMax(self: BidirectionalHeap, index: number)
  while index > 3 do
    local grand = index // 4
    if self[index] > self[grand] then
      self[index], self[grand] = self[grand], self[index]
      index = grand
    else
      break
    end
  end
end

function Module._pushUp(self: BidirectionalHeap, index: number)
  if index == 1 then
    return
  end

  local parent = index // 2
  local a, b = self[index], self[parent]
  if (math_log(index, 2) // 1) % 2 == 0 then
    if a > b then
      self[index], self[parent] = b, a

      self:_pushUpMax(parent)
    else
      self:_pushUpMin(index)
    end
  else
    if a < b then
      self[index], self[parent] = b, a
      self:_pushUpMin(parent)
    else
      self:_pushUpMax(index)
    end
  end
end

function Module._smallestDescendant(self: BidirectionalHeap, index: number): number?
  local size = self.Size

  local best: number? = nil

  local function consider(i)
    if i <= size then
      if not best or self[i] < self[best] then
        best = i
      end
    end
  end

  local left = index * 2
  local right = left + 1

  consider(left)
  consider(right)

  consider(left * 2)
  consider(left * 2 + 1)
  consider(right * 2)
  consider(right * 2 + 1)

  return best
end

function Module._largestDescendant(self: BidirectionalHeap, index: number): number?
  local size = self.Size

  local best: number? = nil

  local function consider(i)
    if i <= size then
      if not best or self[i] > self[best] then
        best = i
      end
    end
  end

  local left = index * 2
  local right = left + 1

  consider(left)
  consider(right)

  consider(left * 2)
  consider(left * 2 + 1)
  consider(right * 2)
  consider(right * 2 + 1)

  return best
end

function Module._pushDownMin(self: BidirectionalHeap, index: number)
  while true do
    local m = self:_smallestDescendant(index)

    if not m then
      break
    end

    if m >= index * 4 then
      if self[m] < self[index] then
        self[m], self[index] = self[index], self[m]

        local parent = m // 2

        if self[m] > self[parent] then
          self[m], self[parent] = self[parent], self[m]
        end

        index = m
      else
        break
      end
    else
      if self[m] < self[index] then
        self[m], self[index] = self[index], self[m]
      end

      break
    end
  end
end

function Module._pushDownMax(self: BidirectionalHeap, index: number)
  while true do
    local m = self:_largestDescendant(index)

    if not m then
      break
    end

    if m >= index * 4 then
      if self[m] > self[index] then
        self[m], self[index] = self[index], self[m]

        local parent = m // 2

        if self[m] < self[parent] then
          self[m], self[parent] = self[parent], self[m]
        end

        index = m
      else
        break
      end
    else
      if self[m] > self[index] then
        self[m], self[index] = self[index], self[m]
      end

      break
    end
  end
end

function Module._pushDown(self: BidirectionalHeap, index: number)
  if (math_log(index, 2) // 1) % 2 == 0 then
    self:_pushDownMin(index)
  else
    self:_pushDownMax(index)
  end
end

function Module._popAt(self: BidirectionalHeap, index: number): any
  local size = self.Size
  local value = self[index]

  self[index] = self[size]
  self[size] = nil

  self.Size = size - 1

  if index <= size - 1 then
    self:_pushDown(index)
  end

  return value
end

function Module.insert(self: BidirectionalHeap, value: any)
  local size = self.Size + 1
  self.Size = size
  self[size] = value
  self:_pushUp(size)
end

function Module.max(self: BidirectionalHeap): any
  local size = self.Size
  if size == 0 then
    return
  elseif size <= 2 then
    return self[size]
  end
  
  local a, b = self[2], self[3]
  if a > b then
    return a
  else
    return b
  end
end


-- -- Methods

function Module.min(self: BidirectionalHeap): any
  return self[1]
end

function Module.popMaximum(self: BidirectionalHeap): any
  local size = self.Size
  if size == 0 then
    return
  end

  if size == 1 then
    self.Size = 0

    local root = self[1]
    self[1] = nil
    
    return root
  end

  local index
  if size == 2 then
    index = 2
  else
    if self[2] > self[3] then
      index = 2
    else
      index = 3
    end
  end

  return self:_popAt(index)
end

function Module.popMinimum(self: BidirectionalHeap): any
  local size = self.Size
  if size == 0 then
    return
  end

  self.Size = size - 1

  local root = self[1]

  self[1] = self[size]
  self[size] = nil

  if size > 0 then
    self:_pushDown(1)
  end

  return root
end


-- -- End

return Module
