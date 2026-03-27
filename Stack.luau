--- Author: COMT

--[[

	Stack

]]

--!strict


-- -- State

local Module = {}
Module.__index = Module

export type Stack = typeof(setmetatable({} :: {
	[number]: any
}, Module))


-- -- Functions

function Module.new(): Stack
	return setmetatable({}, Module)
end


-- -- Methods

function Module.peek(self: Stack): any
	return self[#self]
end

function Module.pop(self: Stack)
	self[#self] = nil
end

function Module.push(self: Stack, value: any)
	self[#self + 1] = value
end


-- -- End

return Module
