#!/usr/bin/lua
require("os")
local graph = require("libs.containers.graph")

-- luacheck: ignore 311
local function test()
	local G = graph.Graph()
	local a = graph.Node()
	a.name = "A"
	local b = graph.Node()
	b.name = "B"
	local c = graph.Node()
	c.name = "C"
	local d = graph.Node()
	d.name = "D"
	local e = graph.Node()
	e.name = "E"

	--[[
	-- The test graph:
	--
	--  A -- 5 --> B <-- 1 -- E
	--  A <-- 4 -- B -- 2 -+
	--  |                  |
	--  +-- 3 --> C <------+
	--
	-- D is not in the graph
	--]]

	assert(G:add_node(a) == graph.errno.ENONE)
	assert(G:add_node(b) == graph.errno.ENONE)
	assert(G:add_node(c) == graph.errno.ENONE)
	assert(G:add_node(c) == graph.errno.ENODEEXTS)
	assert(G:add_node(e) == graph.errno.ENONE)
	assert(G:add_edge(a,b,graph.Edge(5)) == graph.errno.ENONE)
	assert(G:add_edge(b,a,graph.Edge(4)) == graph.errno.ENONE)
	assert(G:add_edge(a,c,graph.Edge(3)) == graph.errno.ENONE)
	assert(G:add_edge(b,c,graph.Edge(2)) == graph.errno.ENONE)
	assert(G:add_edge(d,c,graph.Edge(2)) == graph.errno.ENODE)
	assert(G:add_edge(e,b,graph.Edge(1)) == graph.errno.ENONE)
	assert(G:neighbors(d) == nil)
	assert(G:adjacent(d,c) == false)
	assert(G:adjacent(a,b) == true)
	assert(G:adjacent(b,a) == true)
	assert(G:adjacent(a,c) == true)
	assert(G:adjacent(c,a) == false)
	assert(G:adjacent(b,c) == true)
	assert(G:adjacent(c,b) == false)
	local a_adj = G:neighbors(a)
	assert(a_adj[b]:cost() == 5)
	assert(G:remove_edge(c,a) == graph.errno.ENONE)
	assert(G:remove_edge(a,c) == graph.errno.ENONE)
	a_adj = G:neighbors(a)
	assert(a_adj[c] == nil)
	assert(G:exists(b) == true)
	assert(G:adjacent(e,b) == true)
	assert(G:adjacent(b,e) == false)
	assert(G:remove_node(b) == graph.errno.ENONE)
	assert(G:exists(b) == false)
	assert(G:adjacent(a,b) == false)
	b = nil
	-- we collect garbage here and expect the neighbors to be empty
	-- because we expect in practice the graph will be the owner
	-- of all nodes, hences when b = nil above there are no more
	-- references to b, thus the weak reference to b in the neighbor
	-- list for node e should be garbage collected.
	collectgarbage()
	assert(next(G:neighbors(e)) == nil)
	return 0
end
os.exit(test())
