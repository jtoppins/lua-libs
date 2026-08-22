-- SPDX-License-Identifier: LGPL-3.0

--- Basic Graph container

local class = require("dcsext.class")

local errno = {
	ENONE     = 0,  -- no error
	ENODEEXTS = 1,  -- node already exists in node table
	ENODE     = 2,  -- node does not exist in node table
}

--- Represents an edge in a graph.
local Edge = class("graph-edge")

--- Constructor.
-- @param cost (optional) weight of the edge used by weighted graph
-- searches, defaults to 1
function Edge:__init(cost)
	self._cost = cost or 1
end

--- Get the cost of the Edge. Needed in weighted graph searches.
-- @return number
function Edge:cost()
	return self._cost
end

--- Represents a node or vertex in a graph.
local Node = class("graph-node")

--- Constructor.
-- Nodes carry no data of their own, callers typically use their own
-- objects as nodes and compare them by identity.
function Node:__init()
end

--- Test if this node satisfies a search goal.
-- @param node the candidate node to test
-- @return boolean, true when node is this node
function Node:found(node)
	return self == node
end

--- Graph.
-- the storage model for adjacency means we can only have 1 edge per
-- node pair. This should be ok as we can just have the edge class
-- have flags for things like domain
local Graph = class("graph")

--- Constructor.
function Graph:__init()
	self.nodes = {}
end

--- Does `x` exist in the graph
-- @param x node to look up, any value usable as a lua table key
-- @return boolean
function Graph:exists(x)
	return self.nodes[x] ~= nil
end

--- Return the list of adjacent nodes for `x`.
-- @param x node whose adjacency list is returned
-- @return list
function Graph:neighbors(x)
	return self.nodes[x]
end

--- Are `x` and `y` adjacent to each other?
-- @param x node tested for adjacency
-- @param y node tested for adjacency
-- @return boolean
function Graph:adjacent(x, y)
	local x_adj = self:neighbors(x)
	return x_adj ~= nil and x_adj[y] ~= nil
end

--- Add a new node `x` to the graph.
-- @param x the node to add, any value usable as a table key
-- @return one of the graph.errno codes
function Graph:add_node(x)
	if self.nodes[x] ~= nil then
		return errno.ENODEEXTS
	end
	local neighbors = {}
	-- make keys weak for neighbors table
	setmetatable(neighbors, { __mode = "k", })
	self.nodes[x] = neighbors
	return errno.ENONE
end

--- Remove node `x` from the graph, including all of its edges.
-- @param x the node to remove
-- @return one of the graph.errno codes
function Graph:remove_node(x)
	if self.nodes[x] == nil then
		return errno.ENONE
	end
	for n in pairs(self:neighbors(x)) do
		local n_adj = self.nodes[n]
		n_adj[x] = nil
	end
	self.nodes[x] = nil
	return errno.ENONE
end

--- Add a new edge between `x` and `y`.
-- will overwrite any edge previously associated with a x-y pair
-- @param x an existing node in the graph
-- @param y the node to connect x to, need not be added yet
-- @param edge the Edge instance stored for the x-y pair
-- @return one of the graph.errno codes
function Graph:add_edge(x, y, edge)
	local x_adj = self:neighbors(x)
	if x_adj == nil then
		return errno.ENODE
	end
	x_adj[y] = edge
	return errno.ENONE
end

--- Remove the edge that exists between nodes `x` and `y`.
-- @param x an existing node in the graph
-- @param y the node connected to x by the edge to remove
-- @return one of the graph.errno codes
function Graph:remove_edge(x, y)
	local x_adj = self:neighbors(x)
	if x_adj == nil then
		return errno.ENONE
	end
	x_adj[y] = nil
	return errno.ENONE
end

local graph = {}
--- Error codes returned by the graph mutation methods, ENONE signals
-- success while ENODEEXTS and ENODE report node already exists and
-- node does not exist respectively.
graph.errno = errno

--- Edge class representing a weighted connection between two nodes.
graph.Edge = Edge

--- Node class representing a vertex in the graph.
graph.Node = Node

--- Graph container class managing nodes and their edges.
graph.Graph = Graph
return graph
