--- Author: COMT

--[[

  Multiset (Not sorted)

]]

--!native
--!optimize 2
--!strict


-- -- State

local Module = {}
Module.__index = Module

export type Multiset = typeof(setmetatable({} :: {
  [any]: number
}, Module))


-- -- Functions

function Module.new(): Multiset
  return setmetatable({}, Module)
end


-- -- Methods

function Module.decrement(self: Multiset, value: any, decrement: number?)
  local count = self[value]
  if not count then
    return
  end
  self[value] = count - (decrement or 1)
end

function Module.increment(self: Multiset, value: any, increment: number?)
  self[value] = (self[value] or 0) + (increment or 1)
end

function Module.remove(self: Multiset, value: any)
  self[value] = nil
end


-- -- End

return Module
