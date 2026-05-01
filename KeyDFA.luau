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

function Module.add(self: DFA, key: string)
  local length = #key
  local state = 0
  local top = self.Top

  for index = 1, length - 1 do
    local address = math_abs(state) * 0x100 + (string_byte(key, index) + 1)
    local nextState = self[address]
    if not nextState then
      nextState = top
      top = nextState + 1
      self[address] = nextState
    end

    state = nextState
  end

  local address = math_abs(state) * 0x100 + (string_byte(key, length) + 1)
  if not self[address] then
    self[address] = -top
  end

  self.Top = top + 1
end

function Module.find(self: DFA, key: string): boolean
  local state = 0

  for index = 1, #key do
    state = self[math_abs(state) * 0x100 + (string_byte(key, index) + 1)]
    if not state then
      return false
    end
  end

  return state < 0
end

function Module.remove(self: DFA, key: string): boolean
  local length = #key
  local state = 0
  
  for index = 1, length do
    state = self[math_abs(state) * 0x100 + (string_byte(key, index) + 1)]
    if not state then
      return false
    end
  end

  self[state] = math_abs(state)

  return true
end


-- -- End

return Module
