--!native
--!strict

--[[

  -- Octree (Recursive Implementation)

]]


-- -- State

local Capacity: number = 4 * 3 -- (points allowed) * (size of points)

local Module = {}
Module.__index = Module

export type Quadtree = typeof(setmetatable({} :: {
  X: number, Y: number, Z: number,
  HalfLength: number,
  
  Points: {number},
  
  [number]: Quadtree
}, Module))


-- -- Helpers

local function contains(
  self_X: number, self_Y: number, self_Z: number,
  self_HalfLength: number,
  x: number, y: number, z: number
): boolean
  return x >= self_X - self_HalfLength and x <= self_X + self_HalfLength
    and y >= self_Y - self_HalfLength and y <= self_Y + self_HalfLength
    and z >= self_Z - self_HalfLength and z <= self_Z + self_HalfLength
end

local function intersects(
  self_X: number, self_Y: number, self_Z: number,
  self_HalfLength: number,
  other_X: number, other_Y: number, other_Z: number,
  other_HalfLength: number
): boolean
  return other_X - other_HalfLength > self_X + self_HalfLength
    or other_X + other_HalfLength < self_X - self_HalfLength
    or other_Y - other_HalfLength > self_Y + self_HalfLength
    or other_Y + other_HalfLength < self_Y - self_HalfLength
    or other_Z - other_HalfLength > self_Z + self_HalfLength
    or other_Z + other_HalfLength < self_Z - self_HalfLength
end

local new: typeof(Module.new)

local function subdivide(self: Quadtree)
  local self_X, self_Y, self_Z = self.X, self.Y, self.Z
  local self_HalfLength = self.HalfLength
  self[1] = new(self_X - self_HalfLength, self_Y + self_HalfLength, self_Z + self_HalfLength, self_HalfLength)
  self[2] = new(self_X + self_HalfLength, self_Y + self_HalfLength, self_Z + self_HalfLength, self_HalfLength)
  self[3] = new(self_X - self_HalfLength, self_Y - self_HalfLength, self_Z + self_HalfLength, self_HalfLength)
  self[4] = new(self_X + self_HalfLength, self_Y - self_HalfLength, self_Z + self_HalfLength, self_HalfLength)
  self[5] = new(self_X - self_HalfLength, self_Y + self_HalfLength, self_Z - self_HalfLength, self_HalfLength)
  self[6] = new(self_X + self_HalfLength, self_Y + self_HalfLength, self_Z - self_HalfLength, self_HalfLength)
  self[7] = new(self_X - self_HalfLength, self_Y - self_HalfLength, self_Z - self_HalfLength, self_HalfLength)
  self[8] = new(self_X + self_HalfLength, self_Y - self_HalfLength, self_Z - self_HalfLength, self_HalfLength)
end

local insert: typeof(Module.insert)

local function insert_into_subdivision(
  self: Quadtree,
  x: number, y: number, z: number
)
  for index = 1, 8 do -- unroll for micro-optimization (?)
    local subdivision = self[index]
    local subdivision_X, subdivision_Y, subdivision_Z = subdivision.X, subdivision.Y, subdivision.Z
    if contains(subdivision_X, subdivision_Y, subdivision_Z, subdivision.HalfLength, x, y, z) then
      insert(subdivision, x, y, z)
      return
    end
  end
end


-- -- Functions

new = function(x: number, y: number, z: number, length: number): Quadtree
  return setmetatable({
    X = x, Y = y, Z = z,
    HalfLength = length / 2,

    Points = {} :: {number}
  }, Module)
end Module.new = new


-- -- Methods

function Module.contains(self: Quadtree, x: number, y: number, z: number): boolean
  return contains(self.X, self.Y, self.Z, self.HalfLength, x, y, z)
end

function Module.intersects(self: Quadtree, range_X: number, range_Y: number, range_Z: number, range_HalfLength: number): boolean
  return intersects(self.X, self.Y, self.Z, self.HalfLength, range_X, range_Y, range_Z, range_HalfLength)
end

insert = function(
  self: Quadtree,
  x: number, y: number, z: number
)
  local subdivision = self[1]
  if subdivision then
    insert_into_subdivision(self, x, y, z)
    return
  end

  local points = self.Points
  local pointCount = #points

  if pointCount < Capacity then
    points[pointCount + 1] = x
    points[pointCount + 2] = y
    points[pointCount + 3] = z
    return
  end

  subdivide(self)

  for index = 1, pointCount, 3 do
    local x, y, z = points[index], points[index + 1], points[index + 2]
    insert_into_subdivision(self, x, y, z)
  end

  insert_into_subdivision(self, x, y, z)
end Module.insert = insert

local function query(self: Quadtree, out: {number}, range_X: number, range_Y: number, range_Z: number, range_HalfLength: number)
  local subdivision_1 = self[1]
  if subdivision_1 then
    query(subdivision_1, out, range_X, range_Y, range_Z, range_HalfLength)
    query(self[2], out, range_X, range_Y, range_Z, range_HalfLength)
    query(self[3], out, range_X, range_Y, range_Z, range_HalfLength)
    query(self[4], out, range_X, range_Y, range_Z, range_HalfLength)
    query(self[5], out, range_X, range_Y, range_Z, range_HalfLength)
    query(self[6], out, range_X, range_Y, range_Z, range_HalfLength)
    query(self[7], out, range_X, range_Y, range_Z, range_HalfLength)
    query(self[8], out, range_X, range_Y, range_Z, range_HalfLength)
    return
  end

  local points = self.Points
  for index = 1, #points, 3 do
    local x, y, z = points[index], points[index + 1], points[index + 2]
    if contains(range_X, range_Y, range_Z, range_HalfLength, x, y, z) then
      local outSize = #out
      out[outSize + 1] = x
      out[outSize + 2] = y
      out[outSize + 3] = z
    end
  end
end Module.query = query


-- -- End

return Module
