--- Author: COMT

--[[

  KeyDFA (Deterministic Finite Automaton, no key-value association)

]]

--!native
--!optimize 2
--!strict


-- -- state

local Module = {}
Module.__index = Module

export type KeyDFA = typeof(setmetatable({} :: {
  Top: number,
  [number]: number
}, Module))


-- -- Helpers

local math_abs = math.abs

local string_byte = string.byte


-- -- Functions

function Module.new(): KeyDFA
  return setmetatable({
    Top = 1
  }, Module) :: KeyDFA
end


-- -- Methods

function Module.set(self: KeyDFA, key: string)
  local address: number
  local length = #key
  local state = 0
  local top = self.Top

  for index = 1, length - 1 do
    address = math_abs(state) * 0x100 + (string_byte(key, index) + 1)
    local nextState = self[address]
    if not nextState then
      nextState = top
      top = nextState + 1
      self[address] = nextState
    end

    state = nextState
  end

  address = math_abs(state) * 0x100 + (string_byte(key, length) + 1)
  state = self[address]
  if not state then
    self[address] = -top
    self.Top = top + 1
  elseif state > 0 then
    self[address] = -state
  end
end

function Module.find(self: KeyDFA, key: string): boolean
  local state = 0

  for index = 1, #key do
    state = self[math_abs(state) * 0x100 + (string_byte(key, index) + 1)]
    if not state then
      return false
    end
  end

  return state < 0
end

function Module.remove(self: KeyDFA, key: string): boolean
  local address: number
  local length = #key
  local state = 0
  
  for index = 1, length do
    address = math_abs(state) * 0x100 + (string_byte(key, index) + 1)
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
