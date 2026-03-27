--- Author: COMT

--[[

	Queue

]]

--!native
--!optimize 2
--!strict


-- -- State

local Module = {}
Module.__index = Module

export type Queue<T> = typeof(setmetatable({} :: {
	Bottom: number,
	Top: number,
	
	[number]: T
}, Module))


-- -- Functions

function Module.new<T>(): Queue<T>
	return setmetatable({
		Bottom = 0,
		Top = 0
	}, Module)
end


-- -- Methods

function Module.dequeue<T>(self: Queue<T>): T
	local bottom = self.Bottom + 1
	self.Bottom = bottom
	if bottom == self.Top then
		self.Bottom = 1
		self.Top = 1
	end
	return self[bottom]
end

function Module.enqueue<T>(self: Queue<T>, value: T)
	self.Top += 1
	self[self.Top] = value
end

function Module.peek<T>(self: Queue<T>): T
	return self[self.Bottom]
end


-- -- End

return Module
