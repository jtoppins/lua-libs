-- SPDX-License-Identifier: LGPL-3.0

local utils = require("dcsex.utils")
local class = require("dcsex.class")
local graph = require("dcsex.containers.graph")
local astar = require("dcsex.algorithms.search_astar")

--- Goal-Oriented Action Planning system.
-- Provides the basic building blocks to create an action planner.
-- The unit tests serves as an example of its usage.

local ANYHANDLE = {}

local propmt = {}
function propmt.__eq(self, other)
	return self.id == other.id and (self.value == other.value or
		self.value == ANYHANDLE or other.value == ANYHANDLE)
end

--- Provides a common interface for representing an agent centric
-- symbolic state.
local Property = utils.override_ops(class("world-property"), propmt)

--- Constructor.
-- @param __id a globally unique ID of the symbol
-- @param value the value of the symbol
function Property:__init(__id, value)
	self.id      = __id
	self.value   = value
	self.ANYHANDLE = nil
end

Property.ANYHANDLE = ANYHANDLE

--- A copy constructor for Property.
function Property:copy()
	return Property(self.id, self.value)
end

--- Is a set of Property objects with the set representing a particular
-- state.
local WorldState = class("WorldState")

--- Constructor.
-- @param props set of properties, where the key is the property ID,
-- thus only one unique property may exist in a given state.
function WorldState:__init(props)
	self.props = {}
	for _, p in pairs(props or {}) do
		self.props[p.id] = p
	end
end

--- Iterate over all properties contained in a WorldState.
function WorldState:iterate()
	return next, self.props, nil
end

--- A copy constructor for WorldState.
function WorldState:copy()
	local newprops = {}
	for k, prop in pairs(self.props) do
		newprops[k] = prop:copy()
	end
	return WorldState(newprops)
end

--- Retrieve Property for the given _id_.
function WorldState:get(id)
	return self.props[id]
end

--- Add a new Property to the WorldState.
function WorldState:add(newprop)
	self.props[newprop.id] = newprop
end

--- Remove a Property from the WorldState.
function WorldState:remove(id)
	self.props[id] = nil
end

--- Given _state_ determine how many symbols we have are not satisfied
-- by _state_. Thus we loop over our symbols and test if _state_ has
-- our symbol and if the two symbols are equal.
--
-- @param state the state to check against
-- @return list of property ids not satisfied by _state_
function WorldState:unsatisfied(state)
	local ids = {}
	for _, myprop in self:iterate() do
		local sprop = state:get(myprop.id)
		if sprop == nil or sprop ~= myprop then
			table.insert(ids, myprop.id)
		end
	end
	return ids
end

--- Distance of this state from the given _state_, distance is measured
-- in the number of unsatisfied properties in self. This allows us to
-- know we have x number of properties to become a sub-state of _state_.
-- Remember our equality allows self to have fewer properties than _state_
-- as long as all properties in self equal to properties in _state_, thus
-- self is a sub-state of _state_.
--
-- @param state the state to calculate the distance to
-- @return distance from _state_
function WorldState:distance(state)
	local dist = self:unsatisfied(state)
	return #(dist)
end

--- Represents an activity in a plan to be executed by some agent.
local Action = class("Action", graph.Edge)

--- Constructor.
-- @param cost the cost of the action, used in finding the least cost
-- path.
-- @param precond a set of properties representing states that
-- need to be true before the action can be executed.
-- @param effects a set of properties representing states that the
-- action purports to be able to achieve.
function Action:__init(cost, precond, effects)
	graph.Edge.__init(self, cost)
	self.preconditions = WorldState(precond)
	self.effects = WorldState(effects)
end

--- Is called during planning and is a way for actions to check states
-- that are not easily represented as symbols, such as is there a path
-- to the goal.
--
-- @param goalsofar goal the action is trying to satisify
-- @return bool true if the action should be considered in planning
function Action:checkProceduralPreconditions(--[[goalsofar]])
	return true
end

--- Represents a WorldState in a graph.
local StateNode = class("StateNode", graph.Node)

--- Constructor.
function StateNode:__init(state, goal, action)
	graph.Node.__init(self)
	self.state = state
	self.goal = goal
	self.action = action
end

--- Tests if we have found our goal state.
function StateNode:found(node)
	return node.goal:distance(node.state) == 0 and
		self.goal:distance(node.state) == 0
end

--- Tests if the state node has unstaisified properties.
function StateNode:unsatisfied()
	return self.goal:unsatisfied(self.state)
end

--- Describes the association between States (nodes) and Actions (edges)
-- allowing graph traversal algorithms to reason about these objects.
local GOAPGraph = class("GOAPGraph", graph.Graph)

--- Constructor.
function GOAPGraph:__init(agent, actions)
	self.agent = agent
	self.effect2actions = {}

	for _, action in pairs(actions) do
		self:add_action(action)
	end
end

--- Adds an Action object (edge) for consideration when planning.
function GOAPGraph:add_action(action)
	for _, effect in action.effects:iterate() do
		if self.effect2actions[effect.id] == nil then
			self.effect2actions[effect.id] = {}
		end
		table.insert(self.effect2actions[effect.id], action)
	end
end

--- Handles determining if an action produces an edge from the current
-- node (_node_) to a new state.
function GOAPGraph:handle_action(node, symbol, action)
	if action.effects:get(symbol) ~= node.goal:get(symbol) then
		return nil
	end

	local goal = node.goal:copy()
	local state = node.state:copy()

	-- if preconditions are not satisfied add them to a new goal
	-- this action might be a solution as long as other actions
	-- can solve the now new conditions of the goal.
	if action.preconditions:distance(state) ~= 0 then
		for _, precond in action.preconditions:iterate() do
			goal:add(precond:copy())
		end
	end

	-- further prune actions based on a function result provided
	-- by the action
	if not action:checkProceduralPreconditions(goal) then
		return nil
	end

	-- apply effects of the action to the current state
	for _, effect in action.effects:iterate() do
		state:add(effect:copy())
	end

	return StateNode(state, goal, action)
end

--- Finds neighbor nodes for _node_ by traversing the set of Actions
-- the graph knows about.
function GOAPGraph:neighbors(node)
	local neighbors = {}
	for _, symbol in ipairs(node:unsatisfied()) do
		local actions = self.effect2actions[symbol]
		for _, action in pairs(actions or {}) do
			local neigh = self:handle_action(node, symbol, action)
			if neigh ~= nil then
				neighbors[neigh] = neigh.action
			end
		end
	end
	return neighbors
end

--- Default A* heuristic for determining the next state to investigate
-- further when planning.
local function goap_distance(node, goal)
	return goal.goal:distance(node.state)
end

--- Converts the list of nodes returned by A* into an ordered plan
-- of Action objects.
-- @param G an instance of GOAPGraph
-- @param worldstate the starting world state of an agent
-- @param goal the desired world state
-- @param h the heuristic function to use, default is a state distance
-- calculation
-- @param search the search algorithm to use, default is A*
-- @param order boolean if true will sort the plan, this requires all
-- actions to have the __lt methmethod set so table.sort can be used.
-- @return: goal, plan, cost; where
--   goal is the desired world state after including action preconditions
--   plan the set of actions to accomplish goal
--   cost of the plan
--   otherwise if no plan found return nil
local function find_plan(G, worldstate, goal, h, search, order)
	local path, cost, plan
	local start = StateNode(worldstate, goal, nil)
	local gnode = StateNode(nil, goal, nil)
	h = h or goap_distance
	search = search or astar

	path, cost = search(G, start, gnode, h)
	-- pop off the goal as we don't need that in the plan
	path:pophead()
	if path:empty() == true then
		return nil
	end

	plan = {}
	for _, node in path:iterate() do
		table.insert(plan, node.action)
	end
	if order == true then
		table.sort(plan)
	end
	return path:peektail().goal, plan, cost
end

local _goap = {}
_goap.Property = Property
_goap.WorldState = WorldState
_goap.Action = Action
_goap.Node = StateNode
_goap.Graph = GOAPGraph
_goap.find_plan = find_plan

return _goap
