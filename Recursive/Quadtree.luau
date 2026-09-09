--!native
--!strict

--[[

  -- Quadtree (Recursive Implementation)

]]


-- -- State

local Capacity: number = 8

local Module = {}
Module.__index = Module

export type Quadtree = typeof(setmetatable({} :: {
  X: number, Y: number,
  HalfLength: number,
  
  Points: {number},
  
  [number]: Quadtree
}, Module))


-- -- Helpers

local function contains(
  self_X: number, self_Y: number,
  self_HalfLength: number,
  x: number, y: number
): boolean
  return (x >= self_X - self_HalfLength and x <= self_X + self_HalfLength)
    and (y >= self_Y - self_HalfLength and y <= self_Y + self_HalfLength)
end

local function intersects(
  self_X: number, self_Y: number,
  self_HalfLength: number,
  other_X: number, other_Y: number,
  other_HalfLength: number
): boolean
  return (other_X - other_HalfLength > self_X + self_HalfLength)
    or (other_X + other_HalfLength < self_X - self_HalfLength)
    or (other_Y - other_HalfLength > self_Y + self_HalfLength)
    or (other_Y + other_HalfLength < self_Y - self_HalfLength)
end

local new: typeof(Module.new)

local function subdivide(self: Quadtree)
  local self_X, self_Y = self.X, self.Y
  local self_HalfLength = self.HalfLength
  self[1] = new(self_X - self_HalfLength, self_Y + self_HalfLength, self_HalfLength)
  self[2] = new(self_X + self_HalfLength, self_Y + self_HalfLength, self_HalfLength)
  self[3] = new(self_X - self_HalfLength, self_Y - self_HalfLength, self_HalfLength)
  self[4] = new(self_X + self_HalfLength, self_Y - self_HalfLength, self_HalfLength)
end

local insert: typeof(Module.insert)

local function insert_into_subdivision(
  self: Quadtree,
  x: number, y: number
)
  for index = 1, 4 do -- unroll for micro-optimization (?)
    local subdivision = self[index]
    local subdivision_X, subdivision_Y = subdivision.X, subdivision.Y
    if contains(subdivision_X, subdivision_Y, subdivision.HalfLength, x, y) then
      insert(subdivision, x, y)
      return
    end
  end
end


-- -- Functions

new = function(x: number, y: number, length: number): Quadtree
  return setmetatable({
    X = x, Y = y,
    HalfLength = length / 2,

    Points = {} :: {number}
  }, Module)
end Module.new = new


-- -- Methods

function Module.contains(self: Quadtree, x: number, y: number): boolean
  return contains(self.X, self.Y, self.HalfLength, x, y)
end

function Module.intersects(self: Quadtree, range_X: number, range_Y: number, range_HalfLength: number): boolean
  return intersects(self.X, self.Y, self.HalfLength, range_X, range_Y, range_HalfLength)
end

insert = function(
  self: Quadtree,
  x: number, y: number
)
  if self[1] then
    insert_into_subdivision(self, x, y)
    return
  end

  local points = self.Points
  local pointCount = #points

  if pointCount < Capacity then
    points[pointCount + 1] = x
    points[pointCount + 2] = y
    return
  end

  subdivide(self)

  for index = 1, pointCount, 2 do
    local x, y = points[index], points[index + 1]
    insert_into_subdivision(self, x, y)
  end

  insert_into_subdivision(self, x, y)
end Module.insert = insert

local function query(self: Quadtree, out: {number}, range_X: number, range_Y: number, range_HalfLength: number)
  local subdivision = self[1]
  if subdivision then
    query(subdivision, out, range_X, range_Y, range_HalfLength)
    query(self[2], out, range_X, range_Y, range_HalfLength)
    query(self[3], out, range_X, range_Y, range_HalfLength)
    query(self[4], out, range_X, range_Y, range_HalfLength)
    return
  end

  local points = self.Points
  for index = 1, #points, 2 do
    local x, y = points[index], points[index + 1]
    if contains(range_X, range_Y, range_HalfLength, x, y) then
      local outSize = #out
      out[outSize + 1] = x
      out[outSize + 2] = y
    end
  end
end Module.query = query


-- -- End

return Module
