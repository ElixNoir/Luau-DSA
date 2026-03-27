--- Author: COMT

--[[

	Deque

]]

--!native
--!optimize 2
--!strict


-- -- State

local Module = {}
Module.__index = Module

export type Deque = typeof(setmetatable({} :: {
	Back: {any},
	BackBottom: number,
	BackTop: number,
	
	Front: {any},
	FrontBottom: number,
	FrontTop: number,
	
	Size: number
}, Module))


-- -- Helpers

local table_clear = table.clear


-- -- Functions

function Module.new(): Deque
	return setmetatable({
		Back = {},
		Front = {},
		BackBottom = 1,
		BackTop = 1,
		FrontBottom = 1,
		FrontTop = 1,
		Size = 0
	}, Module)
end


-- -- Methods
	
function Module.clear(self: Deque)
	table_clear(self.Back)
	table_clear(self.Front)
	self.BackBottom = 1
	self.BackTop = 1
	self.FrontBottom = 1
	self.FrontTop = 1
	self.Size = 0
end

function Module.peekBack(self: Deque): any
	if self.BackBottom <= self.BackTop then
		return self.Back[self.BackTop]
	end
	return self.Front[self.FrontTop]
end

function Module.peekFront(self: Deque): any
	if self.FrontBottom <= self.FrontTop then
		return self.Front[self.FrontBottom]
	end
	return self.Back[self.BackBottom]
end

function Module.popBack(self: Deque): any
	self.Size -= 1
	
	local backBottom = self.BackBottom
	local backTop = self.BackTop
	if backBottom <= backTop then
		local back = self.Back
		local value = back[backBottom]
		back[backBottom] = nil
		backBottom += 1

		self.BackBottom = backBottom
		if backBottom > backTop then
			table.clear(back)
			self.BackBottom, self.BackTop = 1, 1
		end

		return value
	end

	local frontBottom = self.FrontBottom
	local front = self.Front
	local value = front[frontBottom]
	front[frontBottom] = nil
	frontBottom += 1

	self.FrontBottom = frontBottom
	if frontBottom > self.FrontTop then
		table.clear(front)
		self.FrontBottom, self.FrontTop = 1, 1
	end

	return value
end

function Module.popFront(self: Deque): any
	self.Size -= 1
	
	local frontBottom = self.FrontBottom
	local frontTop = self.FrontTop
	if frontBottom <= frontTop then
		local front = self.Front
		local value = front[frontBottom]
		front[frontBottom] = nil
		frontBottom += 1

		self.FrontBottom = frontBottom
		if frontBottom > frontTop then
			table_clear(front)
			self.FrontBottom, self.FrontTop = 1, 1
		end

		return value
	end

	local backBottom = self.BackBottom
	local back = self.Back
	local value = back[backBottom]
	back[backBottom] = nil
	backBottom += 1

	self.BackBottom = backBottom
	if backBottom > self.BackTop then
		table_clear(back)
		self.BackBottom, self.BackTop = 1, 1
	end

	return value
end

function Module.pushBack(self: Deque, value: any)
	self.BackTop += 1
	self.Back[self.BackTop] = value

	self.Size += 1
end

function Module.pushFront(self: Deque, value: any)
	local front = self.Front
	local frontBottom = self.FrontBottom

	if frontBottom > 1 then
		frontBottom -= 1
		front[frontBottom] = value
		self.FrontBottom = frontBottom
	else
		self.FrontTop += 1
		front[self.FrontTop] = value
	end
	
	self.Size += 1
end


-- -- End

return Module
