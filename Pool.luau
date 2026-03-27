--- Author: COMT

--[[

	Pool

]]

--!native
--!optimize 2
--!strict


-- -- State

local Module = {}
Module.__index = Module

export type Pool = typeof(setmetatable({} :: {
	FreeList: {number},
	[number]: any
}, Module))


-- -- Helpers

local table_create = table.create
local table_move = table.move


-- -- Functions

function Module.new(): Pool
	return setmetatable({
		FreeList = {} :: {number}
	}, Module)
end


-- -- Methods

function Module.allocate(self: Pool, size: number, value: any?): number
	local freeList = self.FreeList
	local index: number
	local top = #freeList
	
	if top == 0 then
		index = #self + 1
	else
		freeList[top] = nil
	end
	
	table_move(table_create(size, value or false), 1, size, index, self)
	
	return index
end

function Module.deallocate(self: Pool, index: number)
	local freeList = self.FreeList
	freeList[#freeList + 1] = index
end


-- -- End

return Module
