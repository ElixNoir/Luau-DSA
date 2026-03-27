--- Author: COMT

--[[

	RedBlackTree

]]

--!native
--!optimize 2
--!strict


-- -- State

local Module = {}
Module.__index = Module

export type RedBlackTree = typeof(setmetatable({} :: {
	Capacity: number,
	FreeHead: number,
	Length: number,
	Root: number,
	Size: number,
	[number]: any | number,
}, Module))


-- -- Helpers

local table_clear = table.clear
local table_create = table.create
local table_move = table.move

local KEY    = 0
local LEFT   = 1
local RIGHT  = 2
local PARENT = 3
local COLOR  = 4
local VALUE  = 5

local function allocate(self: RedBlackTree): number
	local logicalIndex = self.FreeHead
	if logicalIndex ~= 0 then
		self.FreeHead = self[logicalIndex + LEFT]
		return logicalIndex
	end
	
	logicalIndex = 6 * self.Capacity + 1
	self.Capacity += 1
	
	local length = self.Length
	if logicalIndex > length then
		table_move(table_create(length, 0), 1, length, logicalIndex, self)
	end
	
	return logicalIndex
end

--[[
	Rotate the subtree rooted at logicalIndex to the left.
]]
local function rotateLeft(self: RedBlackTree, logicalIndex: number)
	local parent = self[logicalIndex + PARENT]
	local right = self[logicalIndex + RIGHT]
	local rightLeft = self[right + LEFT]

	self[logicalIndex + RIGHT] = rightLeft
	if rightLeft ~= 0 then
		self[rightLeft + PARENT] = logicalIndex
	end

	self[right + PARENT] = parent
	if parent == 0 then
		self.Root = right
	elseif logicalIndex == self[parent + LEFT] then
		self[parent + LEFT] = right
	else
		self[parent + RIGHT] = right
	end

	self[right + LEFT] = logicalIndex
	self[logicalIndex + PARENT] = right
end

--[[
	Rotate the subtree rooted at logicalIndex to the right.
]]
local function rotateRight(self: RedBlackTree, logicalIndex: number)
	local parent = self[logicalIndex + PARENT]
	local left = self[logicalIndex + LEFT]
	local leftRight = self[left + RIGHT]

	self[logicalIndex + LEFT] = leftRight
	if leftRight ~= 0 then
		self[leftRight + PARENT] = logicalIndex
	end

	self[left + PARENT] = parent
	if parent == 0 then
		self.Root = left
	elseif logicalIndex == self[parent + LEFT] then
		self[parent + LEFT] = left
	else
		self[parent + RIGHT] = left
	end

	self[left + RIGHT] = logicalIndex
	self[logicalIndex + PARENT] = left
end

local function deleteFixup(self: RedBlackTree, logicalIndex: number)
	while logicalIndex ~= self.Root and (logicalIndex == 0 or self[logicalIndex + COLOR] == 0) do
		local xp = self[logicalIndex + PARENT]

		if logicalIndex == self[xp + LEFT] then
			local w = self[xp + RIGHT]

			if self[w + COLOR] == 1 then
				self[w + COLOR] = false
				self[xp + COLOR] = true
				rotateLeft(self, xp)
				w = self[xp + RIGHT]
			end

			if (self[self[w + LEFT] + COLOR] == 0) and (self[self[w + RIGHT] + COLOR] == 0) then
				self[w + COLOR] = true
				logicalIndex = xp
			else
				if self[self[w + RIGHT] + COLOR] == 0 then
					self[self[w + LEFT] + COLOR] = false
					self[w + COLOR] = true
					rotateRight(self, w)
					w = self[xp + RIGHT]
				end

				self[w + COLOR] = self[xp + COLOR]
				self[xp + COLOR] = false
				self[self[w + RIGHT] + COLOR] = false
				rotateLeft(self, xp)
				logicalIndex = self.Root
			end

		else
			local w = self[xp + LEFT]

			if self[w + COLOR] == 1 then
				self[w + COLOR] = false
				self[xp + COLOR] = true
				rotateRight(self, xp)
				w = self[xp + LEFT]
			end

			if (self[self[w + LEFT] + COLOR] == 0) and (self[self[w + RIGHT] + COLOR] == 0) then
				self[w + COLOR] = true
				logicalIndex = xp
			else
				if self[self[w + LEFT] + COLOR] == 0 then
					self[self[w + RIGHT] + COLOR] = false
					self[w + COLOR] = true
					rotateLeft(self, w)
					w = self[xp + LEFT]
				end

				self[w + COLOR] = self[xp + COLOR]
				self[xp + COLOR] = false
				self[self[w + LEFT] + COLOR] = false
				rotateRight(self, xp)
				logicalIndex = self.Root
			end
		end
	end

	if logicalIndex ~= 0 then
		self[logicalIndex + COLOR] = false
	end
end

local function insertFixup(self: RedBlackTree, logicalIndex: number)
	while logicalIndex ~= self.Root and self[self[logicalIndex + PARENT] + COLOR] do
		local parent = self[logicalIndex + PARENT]
		local grandparent = self[parent + PARENT]

		if parent == self[grandparent + LEFT] then
			local uncle = self[grandparent + RIGHT]
			if uncle ~= 0 and self[uncle + COLOR] then
				self[parent + COLOR] = false
				self[uncle + COLOR] = false
				self[grandparent + COLOR] = true
				logicalIndex = grandparent
			else
				if logicalIndex == self[parent + RIGHT] then
					logicalIndex = parent
					rotateLeft(self, logicalIndex)
					parent = self[logicalIndex + PARENT]
					grandparent = self[parent + PARENT]
				end
				self[parent + COLOR] = false
				self[grandparent + COLOR] = true
				rotateRight(self, grandparent)
			end
		else
			local uncle = self[grandparent + LEFT]
			if uncle ~= 0 and self[uncle + COLOR] then
				self[parent + COLOR] = false
				self[uncle + COLOR] = false
				self[grandparent + COLOR] = true
				logicalIndex = grandparent
			else
				if logicalIndex == self[parent + LEFT] then
					logicalIndex = parent
					rotateRight(self, logicalIndex)
					parent = self[logicalIndex + PARENT]
					grandparent = self[parent + PARENT]
				end
				self[parent + COLOR] = false
				self[grandparent + COLOR] = true
				rotateLeft(self, grandparent)
			end
		end
	end
	self[self.Root + COLOR] = false
end

--[[
	Space complexity: O(1)
	Time complexity: O(log(n))
]]
local function insert(self: RedBlackTree, logicalIndex: number, key: number | string, value: any)
	local current = self.Root
	if current == 0 then
		self.Root = logicalIndex
		self[logicalIndex] = key
		self[logicalIndex + LEFT] = 0
		self[logicalIndex + RIGHT] = 0
		self[logicalIndex + PARENT] = 0
		self[logicalIndex + COLOR] = false
		self[logicalIndex + VALUE] = value
		
		return
	end

	local parent = 0
	while current ~= 0 do
		parent = current
		if key < self[current] then
			current = self[current + LEFT]
		else
			current = self[current + RIGHT]
		end
	end

	self[logicalIndex] = key
	self[logicalIndex + LEFT] = 0
	self[logicalIndex + RIGHT] = 0
	self[logicalIndex + PARENT] = parent
	self[logicalIndex + COLOR] = true
	self[logicalIndex + VALUE] = value
	
	self[logicalIndex + COLOR] = false
	if key < self[parent] then
		self[parent + LEFT] = logicalIndex
	else
		self[parent + RIGHT] = logicalIndex
	end

	insertFixup(self, logicalIndex)
end

local function transplant(self: RedBlackTree, u: number, v: number)
	local up = self[u + PARENT]
	if up == 0 then
		self.Root = v
	elseif u == self[up + LEFT] then
		self[up + LEFT] = v
	else
		self[up + RIGHT] = v
	end
	if v ~= 0 then
		self[v + PARENT] = up
	end
end


-- -- Functions

--[[
	Space complexity: O(1)
	Time complexity: O(n)
]]
function Module.new(initialCapacity: number?): RedBlackTree
	initialCapacity = initialCapacity or 16
	local length = 6 * initialCapacity
	
	local self: any = setmetatable(table_create(6 * initialCapacity, 0), Module)
	
	self.Capacity = initialCapacity
	self.FreeHead = 1
	self.Length = length
	self.Root = 0
	self.Size = 0
	
	for logicalIndex = 1, 6 * initialCapacity - 7, 6 do
		self[logicalIndex + LEFT] = logicalIndex
	end
	
	return self
end


-- -- Methods

--[[
	Space complexity: O(1)
	Time complexity: O(1)
]]
function Module.clear(self: RedBlackTree)
	table_clear(self)
	self.Capacity = 16
	self.FreeHead = 1
	self.Length = 96
	self.Root = 0
	self.Size = 0
	
	local last = 0
	for logicalIndex = 1, 90, 6 do
		self[logicalIndex + LEFT] = logicalIndex
	end
end

--[[
	Space complexity: O(1)
	Time complexity: O(log(n))
]]
function Module.erase(self: RedBlackTree, key: number | string)
	local nodeToDelete = self:find(key)
	if not nodeToDelete then
		return
	end

	local logicalIndex = nodeToDelete
	local originalColor = self[logicalIndex + COLOR]
	local childNode

	if self[nodeToDelete + LEFT] == 0 then
		childNode = self[nodeToDelete + RIGHT]
		transplant(self, nodeToDelete, self[nodeToDelete + RIGHT])
	elseif self[nodeToDelete + RIGHT] == 0 then
		childNode = self[nodeToDelete + LEFT]
		transplant(self, nodeToDelete, self[nodeToDelete + LEFT])
	else
		logicalIndex = self[nodeToDelete + RIGHT]
		while self[logicalIndex + LEFT] ~= 0 do
			logicalIndex = self[logicalIndex + LEFT]
		end
		originalColor = self[logicalIndex + COLOR]
		childNode = self[logicalIndex + RIGHT]
		if self[logicalIndex + PARENT] == nodeToDelete then
			self[childNode + PARENT] = logicalIndex
		else
			transplant(self, logicalIndex, self[logicalIndex + RIGHT])
			self[logicalIndex + RIGHT] = self[nodeToDelete + RIGHT]
			self[self[logicalIndex + RIGHT] + PARENT] = logicalIndex
		end
		transplant(self, nodeToDelete, logicalIndex)
		self[logicalIndex + LEFT] = self[nodeToDelete + LEFT]
		self[self[logicalIndex + LEFT] + PARENT] = logicalIndex
		self[logicalIndex + COLOR] = self[nodeToDelete + COLOR]
	end

	if originalColor == 0 then
		deleteFixup(self, childNode)
	end

	self[logicalIndex + LEFT] = self.FreeHead
	self.FreeHead = logicalIndex
	
	self.Size -= 1
end

--[[
	Space complexity: O(1)
	Time complexity: O(log(n))
]]
function Module.find(self: RedBlackTree, key: number | string): number?
	local logicalIndex = self.Root
	while logicalIndex ~= 0 do
		local nodeKey = self[logicalIndex]
		if key < nodeKey then
			logicalIndex = self[logicalIndex + LEFT]
		elseif key > nodeKey then
			logicalIndex = self[logicalIndex + RIGHT]
		else
			return logicalIndex
		end
	end
	return nil
end

--[[
	Space complexity: O(1)
	Time complexity: O(log(n))
]]
function Module.get(self: RedBlackTree, key: number | string): any?
	local logicalIndex = self:find(key)
	return logicalIndex and self[logicalIndex + VALUE] or nil
end

--[[
	Space complexity: O(1)
	Time complexity: O(1)
]]
function Module.getAtLogical(self: RedBlackTree, logicalIndex: number, value: any)
	return self[logicalIndex + VALUE]
end

--[[
	Space complexity: O(1)
	Time complexity: O(log(n))
]]
function Module.insert(self: RedBlackTree, key: number | string, value: any): number
	local logicalIndex = allocate(self)
	
	insert(self, logicalIndex, key, value)
	self.Size += 1
	
	return logicalIndex
end

--[[
	Space complexity: O(1)
]]
function Module.iterate(self: RedBlackTree): () -> any
	local node = self.Root
	if node ~= 0 then
		while self[node + LEFT] ~= 0 do
			node = self[node + LEFT]
		end
	end

	return function(): any
		if node == 0 then
			return
		end

		local current = node

		if self[node + RIGHT] ~= 0 then
			node = self[node + RIGHT]
			while self[node + LEFT] ~= 0 do
				node = self[node + LEFT]
			end
		else
			local p = self[node + PARENT]
			while p ~= 0 and node == self[p + RIGHT] do
				node = p
				p = self[p + PARENT]
			end
			node = p
		end

		return self[current + VALUE]
	end
end

--[[
	Space complexity: O(1)
	Time complexity: O(log(n))
]]
function Module.set(self: RedBlackTree, key: number | string, value: any)
	local logicalIndex = self:find(key)
	if logicalIndex then
		self[logicalIndex + VALUE] = value
	end
end

--[[
	Space complexity: O(1)
	Time complexity: O(1)
]]
function Module.setAtLogical(self: RedBlackTree, logicalIndex: number, value: any)
	self[logicalIndex + VALUE] = value
end

--[[
	Space complexity: O(1)
	Time complexity: O(log(n))
]]
function Module.upsert(self: RedBlackTree, key: number | string, value: any): number
	local logicalIndex = self:find(key)
	if logicalIndex then
		self[logicalIndex + VALUE] = value
	else
		logicalIndex = allocate(self)
		
		insert(self, logicalIndex, key, value)
		self.Size += 1
	end
	return logicalIndex :: number
end


-- -- End

return Module
