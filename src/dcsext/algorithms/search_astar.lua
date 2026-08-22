-- SPDX-License-Identifier: LGPL-3.0

--- search_astar - performs an A* shortest path search over a graph.
-- The search expands nodes from start towards goal ordered by path
-- cost plus the estimated cost-to-go given by heuristic, so it finds
-- the cheapest path when the heuristic never overestimates.

local check = require("dcsext.check")
local PriorityQueue = require("dcsext.containers.PriorityQueue")
local Queue = require("dcsext.containers.Queue")

--- Run an A* search over graph from start to goal.
-- @function search_astar
-- @param graph a graph that provides a `neighbors(node)` method returning a
-- table keyed by neighboring nodes whose values are edges exposing a
-- `cost()` method.
-- @param start the starting node in graph
-- @param goal the goal node in graph, must provide a `found(node)` predicate
-- used to test whether a candidate node satisfies the goal condition.
-- @param heuristic a function of the form
-- `number heuristic(candidate_node, goal)` where the numerical value
-- represents an estimated cost to reach the goal from candidate_node.
-- @return Queue holding the found path from start to goal.
-- @return number the total cost of the path.
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
