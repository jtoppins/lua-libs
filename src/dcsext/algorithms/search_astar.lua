-- SPDX-License-Identifier: LGPL-3.0

local check = require("dcsext.check")
local PriorityQueue = require("dcsext.containers.PriorityQueue")
local Queue = require("dcsext.containers.Queue")

--- Defines an A* search algorithm
-- @param graph a graph that provides a `neighbors(node)` method.
-- @param start the starting node in graph
-- @param goal the goal node in graph
-- @param heuristic a function of the form
-- `number heuristic(candidiate_node, goal)` where the numerical value
-- represents a cost to go to the candidiate_node.
local function search_astar(graph, start, goal, heuristic)
	-- check inputs
	check.func(heuristic)
	local frontier = PriorityQueue()
	local from = { [start] = true, }
	local cost = { [start] = 0, }
	local current

	frontier:push(0, start)
	while not frontier:empty() do
		current = frontier:pop()

		if goal:found(current) then
			goal = current
			break
		end

		for node, edge in pairs(graph:neighbors(current) or {}) do
			local newcost = cost[current] + edge:cost()
			if cost[node] == nil or newcost < cost[node] then
				cost[node] = newcost
				local prio = newcost + heuristic(node, goal)
				frontier:push(prio, node)
				from[node] = current
			end
		end
	end

	local path = Queue()
	current = goal
	while from[current] ~= nil do
		path:pushhead(current)
		current = from[current]
	end
	return path, cost[goal]
end

return search_astar
