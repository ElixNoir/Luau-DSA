--- Author: COMT

--[[

	LinkedList

]]

--!native
--!optimize 2
--!strict


-- -- State

local Module = {}
Module.__index = Module

export type LinkedList<T> = typeof(setmetatable({} :: {
	FreeHead: number,
	Head: number,
	Tail: number,
	
	Capacity: number,
	Size: number,

	[number]: any,

	append: (self: LinkedList<T>, value: T) -> number,
	prepend: (self: LinkedList<T>, value: T) -> number,
	insert: (self: LinkedList<T>, index: number, value: T) -> number
}, Module))


-- -- Helpers

local table_create = table.create


-- -- Metamethods

function Module.__len(self: LinkedList<any>): number
	return self.Size
end


-- -- Methods

-- -- -- Constructors

function Module.new<T>(capacity: number?): LinkedList<T>
	local self: any = table_create(2 * (capacity or 0), 0)

	self.Head = 0
	self.Tail = 0

	self.FreeHead = 0

	self.Size = 0
	self.Capacity = 1

	return setmetatable(self, Module)
end


-- -- -- Access

local function allocate(self: LinkedList<any>): number
	local logicalIndex = self.FreeHead
	if logicalIndex ~= 0 then
		self.FreeHead = self[logicalIndex + 1]
		return logicalIndex
	end

	logicalIndex = self.Capacity

	self.Size += 1
	self.Capacity += 2

	return logicalIndex
end

function Module.append<T>(self: LinkedList<T>, value: T): number
	local logicalIndex = allocate(self)
	local tail = self.Tail

	self[logicalIndex] = value
	self[logicalIndex + 1] = 0

	if tail ~= 0 then
		self[tail + 1] = logicalIndex
	else
		self.Head = logicalIndex
		self[-1] = logicalIndex
	end

	self.Tail = logicalIndex

	return logicalIndex
end

function Module.prepend<T>(self: LinkedList<T>, value: T): number
	local logicalIndex = allocate(self)
	local head = self.Head

	self[logicalIndex] = value
	self[logicalIndex + 1] = head

	if head == 0 then
		self.Tail = logicalIndex
	end

	self.Head = logicalIndex
	self[-1] = logicalIndex

	return logicalIndex
end

function Module.insert<T>(self: LinkedList<T>, index: number, value: T): number
	if index == 1 then
		return self:prepend(value)
	elseif index == self.Size then
		return self:append(value)
	end
	
	local logicalIndex = allocate(self)
	
	local previousNode = self:seekPrevious(index)
	local nextNode = self[previousNode + 1]
	self[previousNode + 1] = logicalIndex
	self[logicalIndex + 1] = nextNode
	
	self[logicalIndex] = value
	
	return logicalIndex
end

function Module.insertAfterLogical<T>(self: LinkedList<T>, logicalIndex: number, value: T): number
	local newLogicalIndex = allocate(self)

	local nextNode = self[logicalIndex + 1]

	self[newLogicalIndex] = value
	self[newLogicalIndex + 1] = nextNode

	self[logicalIndex + 1] = newLogicalIndex

	if nextNode == 0 then
		self.Tail = newLogicalIndex
	end

	return newLogicalIndex
end

function Module.iterate<T>(self: LinkedList<T>, logicalIndex: number?): () -> T
	if logicalIndex then
		self[-3] = logicalIndex
		logicalIndex = -4
	else
		logicalIndex = -2
	end
	
	return function(): T
		logicalIndex = self[logicalIndex :: number + 1]
		return self[logicalIndex :: number]
	end
end

function Module.remove(self: LinkedList<any>, index: number)
	if index == 1 then
		local oldHead = self.Head
		self.Head = self[oldHead + 1]
		self[-1] = self.Head

		if self.Head == 0 then
			self.Tail = 0
		end

		self[oldHead + 1] = self.FreeHead
		self.FreeHead = oldHead
		self.Size -= 1
		return
	end

	local prev = self:seekPrevious(index)
	local node = self[prev + 1]
	local nextNode = self[node + 1]

	self[prev + 1] = nextNode

	if node == self.Tail then
		self.Tail = prev
	end

	self[node + 1] = self.FreeHead
	self.FreeHead = node

	self.Size -= 1
end

function Module.removeAtLogical(self: LinkedList<any>, logicalIndex: number)
	-- got bored i guess
end

function Module.seek(self: LinkedList<any>, index: number): number
	local logicalIndex = self.Head
	for _ = 2, index do
		logicalIndex = self[logicalIndex + 1]
	end

	return logicalIndex
end

function Module.seekPrevious(self: LinkedList<any>, index: number): number
	local logicalIndex = self.Head
	for _ = 3, index do
		logicalIndex = self[logicalIndex + 1]
	end
	
	return logicalIndex
end

function Module.get<T>(self: LinkedList<T>, logicalIndex: number, value: T)
	return self[logicalIndex]
end

function Module.next(self: LinkedList<any>, logicalIndex: number): number
	return self[logicalIndex + 1]
end

function Module.set<T>(self: LinkedList<T>, logicalIndex: number, value: T)
	self[logicalIndex] = value
end


-- -- End

return Module
