-- SPDX-License-Identifier: LGPL-3.0

--- goap - Goal-Oriented Action Planning system.
-- Provides the basic building blocks to create an action planner:
-- agents describe the world through symbolic world states built
-- from Property objects, Actions declare preconditions and effects,
-- and the planner searches the space of world states to find the
-- least cost plan of actions reaching a goal world state.
-- The unit tests serve as an example of its usage.

local overrideOps = require("dcsext.overrideOps")
local class = require("dcsext.class")
local graph = require("dcsext.containers.graph")
local astar = require("dcsext.algorithms.search_astar")

local ANYHANDLE = {}

local propmt = {}
function propmt.__eq(self, other)
	return self.id == other.id and (self.value == other.value or
		self.value == ANYHANDLE or other.value == ANYHANDLE)
end

--- Provides a common interface for representing an agent centric
-- symbolic state. Two Property objects are equal when their ids
-- match and either their values match or one of the values is the
-- ANYHANDLE wildcard, which matches any value.
local Property = overrideOps(class("world-property"), propmt)

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
-- @return a new Property with the same id and value
function Property:copy()
	return Property(self.id, self.value)
end

--- Represents a set of Property objects, the set as a whole
-- describing a particular world state.
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
-- @return an iterator function for use in a for-in loop, yielding
-- the property id and Property object of each entry
function WorldState:iterate()
	return next, self.props, nil
end

--- A copy constructor for WorldState.
-- @return a new WorldState containing copies of the original
-- properties
function WorldState:copy()
	local newprops = {}
	for k, prop in pairs(self.props) do
		newprops[k] = prop:copy()
	end
	return WorldState(newprops)
end

--- Retrieve Property for the given _id_.
-- @param id the property id to look up
-- @return the Property object or nil when the state holds no
-- property with that id
function WorldState:get(id)
	return self.props[id]
end

--- Add a new Property to the WorldState.
-- @param newprop the Property to insert, replacing any existing
-- property with the same id
function WorldState:add(newprop)
	self.props[newprop.id] = newprop
end

--- Remove a Property from the WorldState.
-- @param id the property id to remove
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
-- @param goalsofar goal the action is trying to satisfy
-- @return bool true if the action should be considered in planning
function Action:checkProceduralPreconditions(--[[goalsofar]])
	return true
end

--- Represents a WorldState in a graph.
local StateNode = class("StateNode", graph.Node)

--- Constructor.
-- @param state the world state reached at this node
-- @param goal the goal world state the plan is trying to reach
-- @param action the action whose application produced state, nil
-- for the start and terminal nodes
function StateNode:__init(state, goal, action)
	graph.Node.__init(self)
	self.state = state
	self.goal = goal
	self.action = action
end

--- Tests if we have found our goal state.
-- @param node the candidate node to test
-- @return bool, true when the node state satisfies both the node
-- goal and the overall planning goal
function StateNode:found(node)
	return node.goal:distance(node.state) == 0 and
		self.goal:distance(node.state) == 0
end

--- Tests if the state node has unsatisfied properties.
-- @return list of property ids in the node goal that are not
-- satisfied by the node state
function StateNode:unsatisfied()
	return self.goal:unsatisfied(self.state)
end

--- Describes the association between States (nodes) and Actions (edges)
-- allowing graph traversal algorithms to reason about these objects.
-- Actions are indexed by the property ids of their effects so the
-- planner can quickly find the actions able to produce an
-- unsatisfied symbol.
local GOAPGraph = class("GOAPGraph", graph.Graph)

--- Constructor.
-- @param agent the agent the plan is being made for
-- @param actions list of Action objects available to the planner
function GOAPGraph:__init(agent, actions)
	self.agent = agent
	self.effect2actions = {}

	for _, action in pairs(actions) do
		self:add_action(action)
	end
end

--- Adds an Action object (edge) for consideration when planning.
-- @param action the Action to add, indexed by the property ids of
-- its effects
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
--
-- @param node the current planning graph node
-- @param symbol the unsatisfied property id being solved
-- @param action a candidate action producing _symbol_
-- @return a new StateNode with the action effects applied to a copy
-- of the node state or nil when the action does not produce
-- _symbol_ or is pruned by its procedural preconditions
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
-- @param node the node to expand
-- @return table keyed by neighboring StateNode objects with the
-- Action producing each neighbor as values
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
-- actions to have the \_\_lt method set so table.sort can be used.
-- @return the desired world state after including action
-- preconditions or nil if no plan was found
-- @return the set of actions to accomplish the goal
-- @return the cost of the plan
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
