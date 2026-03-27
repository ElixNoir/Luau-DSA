--- Author: COMT

--[[

	DoublyLinkedList

]]

--!native
--!optimize 2
--!strict


-- -- State

local Module = {}
Module.__index = Module

export type DoublyLinkedList<T> = typeof(setmetatable({} :: {
	FreeHead: number,
	Head: number,
	Tail: number,
	
	Capacity: number,
	Size: number,
	
	[number]: any,
	
	append: (self: DoublyLinkedList<T>, value: T) -> number,
	prepend: (self: DoublyLinkedList<T>, value: T) -> number,
	insert: (self: DoublyLinkedList<T>, index: number, value: T) -> number
}, Module))


-- -- Helpers

local table_create = table.create


-- -- Functions

function Module.new<T>(capacity: number?): DoublyLinkedList<T>
	local self: any = table_create(3 * (capacity or 0), 0)

	self.FreeHead = 0
	self.Head = 0
	self.Tail = 0

	self.Size = 0
	self.Capacity = 1

	return setmetatable(self, Module)
end


-- -- Metamethods

function Module.__len(self: DoublyLinkedList<any>): number
	return self.Size
end


-- -- Methods

local function allocate(self: DoublyLinkedList<any>): number
	local logicalIndex = self.FreeHead
	if logicalIndex ~= 0 then
		self.FreeHead = self[logicalIndex + 2]
		return logicalIndex
	end
	
	logicalIndex = self.Capacity
	
	self.Capacity += 3
	self.Size += 1
	
	return logicalIndex
end

function Module.append<T>(self: DoublyLinkedList<T>, value: T): number
	local logicalIndex = allocate(self)
	local tail = self.Tail

	self[logicalIndex] = value
	self[logicalIndex + 1] = tail
	self[logicalIndex + 2] = 0

	if tail ~= 0 then
		self[tail + 2] = logicalIndex
	else
		self.Head = logicalIndex
		self[-2] = logicalIndex
	end
	
	self.Tail = logicalIndex
	self[-1] = logicalIndex

	return logicalIndex
end

function Module.prepend<T>(self: DoublyLinkedList<T>, value: T): number
	local logicalIndex = allocate(self)
	local head = self.Head

	self[logicalIndex] = value
	self[logicalIndex + 1] = 0
	self[logicalIndex + 2] = head

	if head ~= 0 then
		self[head + 1] = logicalIndex
	else
		self.Tail = logicalIndex
		self[-1] = logicalIndex
	end
	
	self.Head = logicalIndex
	self[-2] = logicalIndex

	return logicalIndex
end

function Module.insert<T>(self: DoublyLinkedList<T>, index: number, value: T): number
	if index == 1 then
		return self:prepend(value)
	elseif index == self.Size then
		return self:append(value)
	end
	
	local logicalIndex = allocate(self)

	local previousNode = self:seekPrevious(index)
	local nextNode = self[previousNode + 2]
	
	self[logicalIndex] = value
	self[logicalIndex + 1] = previousNode
	self[logicalIndex + 2] = nextNode
	
	self[nextNode + 1] = logicalIndex
	self[previousNode + 2] = logicalIndex

	return logicalIndex
end

function Module.insertAfterLogical<T>(self: DoublyLinkedList<T>, logicalIndex: number, value: T): number
	local newLogicalIndex = allocate(self)

	local nextNode = self[logicalIndex + 2]

	self[newLogicalIndex] = value
	self[newLogicalIndex + 1] = logicalIndex
	self[newLogicalIndex + 2] = nextNode
	
	self[logicalIndex + 2] = newLogicalIndex

	if nextNode ~= 0 then
		self[nextNode + 1] = newLogicalIndex
	else
		self.Tail = newLogicalIndex
		self[-1] = newLogicalIndex
	end

	return newLogicalIndex
end

function Module.insertBeforeLogical<T>(self: DoublyLinkedList<T>, logicalIndex: number, value: T): number
	local newLogicalIndex = allocate(self)

	local prevNode = self[logicalIndex + 1]

	self[newLogicalIndex] = value
	self[newLogicalIndex + 1] = prevNode
	self[newLogicalIndex + 2] = logicalIndex
	
	self[logicalIndex + 1] = newLogicalIndex
	
	if prevNode ~= 0 then
		self[prevNode + 2] = newLogicalIndex
	else
		self.Head = newLogicalIndex
		self[-2] = newLogicalIndex
	end

	return newLogicalIndex
end

function Module.iterate<T>(self: DoublyLinkedList<T>, logicalIndex: number?): () -> T
	if logicalIndex then
		self[-3] = logicalIndex
		logicalIndex = -5
	else
		logicalIndex = -4
	end
	
	return function(): T
		logicalIndex = self[logicalIndex :: number + 2]
		return self[logicalIndex :: number]
	end
end

function Module.iterateReverse<T>(self: DoublyLinkedList<T>, logicalIndex: number?): () -> T
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

function Module.remove(self: DoublyLinkedList<any>, index: number)
	self:removeAtLogical(self:seek(index))
end

function Module.removeAtLogical(self: DoublyLinkedList<any>, logicalIndex: number)
	local prevNode = self[logicalIndex + 1]
	local nextNode = self[logicalIndex + 2]
	
	if prevNode ~= 0 then
		self[prevNode + 2] = nextNode
	else
		self.Head = nextNode
		self[-2] = nextNode
	end
	
	if nextNode ~= 0 then
		self[nextNode + 1] = prevNode
	else
		self.Tail = prevNode
		self[-1] = prevNode
	end
	
	self[logicalIndex + 2] = self.FreeHead
	self.FreeHead = logicalIndex
end

function Module.seek(self: DoublyLinkedList<any>, index: number): number
	local logicalIndex: number
	if index <= self.Size // 2 then
		logicalIndex = self.Head
		for _ = 2, index do
			logicalIndex = self[logicalIndex + 2]
		end
	else
		logicalIndex = self.Tail
		for _ = index + 1, self.Size do
			logicalIndex = self[logicalIndex + 1]
		end
	end

	return logicalIndex
end

function Module.seekPrevious(self: DoublyLinkedList<any>, index: number): number
	local logicalIndex: number
	if index <= self.Size // 2 then
		logicalIndex = self.Head
		for _ = 3, index do
			logicalIndex = self[logicalIndex + 2]
		end
	else
		logicalIndex = self.Tail
		for _ = index + 2, self.Size do
			logicalIndex = self[logicalIndex + 1]
		end
	end

	return logicalIndex
end

function Module.get<T>(self: DoublyLinkedList<T>, logicalIndex: number, value: T)
	return self[logicalIndex]
end

function Module.next(self: DoublyLinkedList<any>, logicalIndex: number): number
	return self[logicalIndex + 2]
end

function Module.previous(self: DoublyLinkedList<any>, logicalIndex: number): number
	return self[logicalIndex + 1]
end

function Module.set<T>(self: DoublyLinkedList<T>, logicalIndex: number, value: T)
	self[logicalIndex] = value
end


-- -- End

return Module
