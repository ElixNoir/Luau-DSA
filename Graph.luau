--- Author: COMT

--[[

  Graph

]]

--!native
--!strict


-- -- State

local Module = {}
Module.__index = Module

export type Graph = typeof(setmetatable({} :: {
  Value: any,
  [number]: Graph
}, Module))


-- -- Helpers

local math_Huge = math.huge

local table_create = table.create
local table_insert = table.insert
local table_move = table.move
local table_remove = table.remove


-- -- Functions

function Module.new(value: any): Graph
  return setmetatable({
    Value = value
  }, Module)
end


-- -- Methods

function Module.breadthFirstSearch(self: Graph, value: any): {Graph}
  local path: {Graph} = {self}
  if self.Value == value then
    return path
  end
  
  local bottom, top = 1, 1
  local queue: {Graph} = {self}
  local visited: {[Graph]: true} = {}

  while top - bottom >= 0 do
    local previousTop = top
    for index = bottom, top do
      for _, graph in ipairs(queue[index]) do
        if visited[graph] then
          continue
        end
        table_insert(path, graph)
        if graph.Value == value then
          return path
        end
        top += 1
        queue[top] = graph
        visited[graph] = true
      end
    end
    bottom = previousTop
  end

  return path
end

function Module.depthFirstSearch(self: Graph, value: any): {Graph}
  local path: {Graph} = {self}
  if self.Value == value then
    return path
  end
  
  local stack: {Graph} = {self}
  local visited: {[Graph]: true} = {}

  while #stack > 0 do
    local graph = table_remove(stack) :: Graph

    if not visited[graph] then
      visited[graph] = true
      table_insert(path, graph)
      if graph.Value == value then
        return path
      end
      
      for index = #graph, 1, -1 do
        local neighbor = graph[index]
        if not visited[neighbor] then
          table_insert(stack, neighbor)
        end
      end
    end
  end
  
  return path
end


-- -- End

return Module
