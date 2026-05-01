--- Author: COMT

--[[

  DFA (Deterministic Finite Automaton)

]]

--!native
--!optimize 2
--!strict


-- -- state

local Module = {}
Module.__index = Module

export type DFA = typeof(setmetatable({} :: {
  Top: number,
  [number]: number
}, Module))


-- -- Helpers

local math_abs = math.abs

local string_byte = string.byte


-- -- Functions

function Module.new(): DFA
  return setmetatable({
    Top = 1
  }, Module) :: DFA
end


-- -- Methods

--[[
  Get a value associated with a key.

  Space Complexity: O(1)
  Time Complexity: O(#key)
]]
function Module.get(self: DFA, key: string): any
  local address: number
  local state = 0

  for index = 1, #key do
    address = 2 * (math_abs(state) * 0x100 + (string_byte(key, index) + 1))
    state = self[address]
    if not state then
      return false
    end
  end

  return state < 0 and self[address - 1] or nil
end

--[[
  Associate a value with a key.

  Space Complexity: O(1)
  Time Complexity: O(#key)
]]
function Module.set(self: DFA, key: string, value: any)
  local address: number
  local length = #key
  local state = 0
  local top = self.Top

  for index = 1, length - 1 do
    address = 2 * (math_abs(state) * 0x100 + (string_byte(key, index) + 1))
    local nextState = self[address]
    if not nextState then
      nextState = top
      top = nextState + 1
      self[address] = nextState
    end

    state = nextState
  end

  address = 2 * (math_abs(state) * 0x100 + (string_byte(key, length) + 1))
  state = self[address]
  if not state then
    self[address] = -top
    self.Top = top + 1
  elseif state > 0 then
    self[address] = -state
  end

  self[address - 1] = value
end

--[[
  Remove a key-value association.

  Space Complexity: O(1)
  Time Complexity: O(#key)
]]
function Module.remove(self: DFA, key: string): boolean
  local address: number
  local length = #key
  local state = 0
  
  for index = 1, length do
    address = 2 * (math_abs(state) * 0x100 + (string_byte(key, index) + 1))
    state = self[address]
    if not state then
      return false
    end
  end

  self[address] = math_abs(state)

  return true
end


-- -- End

return Module
