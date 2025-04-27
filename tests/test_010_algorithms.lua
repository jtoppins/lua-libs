#!/usr/bin/lua
require 'busted.runner'()
require("os")
local graph = require("libs.containers.graph")
local search_astar = require("libs.algorithms.search_astar")

describe("algorithms", function()
	test("A* search", function()
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

		-- The test graph:
		--
		--             B <-- 1 -- E
		--  A <-- 4 -- B <- 2 -+
		--  |                  |
		--  +-- 3 --> C -------+
		--
		-- D is not in the graph

		assert(G:add_node(a) == graph.errno.ENONE)
		assert(G:add_node(b) == graph.errno.ENONE)
		assert(G:add_node(c) == graph.errno.ENONE)
		assert(G:add_node(c) == graph.errno.ENODEEXTS)
		assert(G:add_node(e) == graph.errno.ENONE)
		assert(G:add_edge(b,a,graph.Edge(4)) == graph.errno.ENONE)
		assert(G:add_edge(a,c,graph.Edge(3)) == graph.errno.ENONE)
		assert(G:add_edge(c,b,graph.Edge(2)) == graph.errno.ENONE)
		assert(G:add_edge(d,c,graph.Edge(2)) == graph.errno.ENODE)
		assert(G:add_edge(e,b,graph.Edge(1)) == graph.errno.ENONE)

		local path, cost = search_astar(G, b, c,
					function() return 1; end)
		assert.is.equal(cost, 7)
		local vpath = { "B", "A", "C" }
		local i = 1
		for _, v in path:iterate() do
			assert(vpath[i] == v.name)
			i = i + 1
		end

		path, cost = search_astar(G, d, c,
				function() return 1; end)
		assert.is_true(path:empty())
		assert.is.equal(cost, nil)
	end)
end)
