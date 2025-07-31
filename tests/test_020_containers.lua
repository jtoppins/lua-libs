#!/usr/bin/lua
require('busted.runner')()
require("os")
require("dcsex")

describe("containers.Queue", function()
	local Queue = dcsex.containers.Queue
	local tests = {
		{
			name = "storage",
			input = {1, 2, 3, 4},
			size = 4,
		}
	}

	test("initialization", function()
		local rb = Queue()

		assert.is.equal(rb:size(), 0)
		assert.is_true(rb:empty())
		assert.is.equal(rb:peekhead(), nil)
		rb:pushhead(nil)
		assert.is.equal(rb:pophead(), nil)
		assert.is.equal(rb:peektail(), nil)
		rb:pushtail(nil)
		assert.is.equal(rb:poptail(), nil)
		assert.is.equal(rb:size(), 0)
		assert.is_true(rb:empty())
	end)

	local function test_store(pushmethod, itermethod)
		for _, t in ipairs(tests) do
			local rb = Queue()

			for _, i in ipairs(t.input) do
				rb[pushmethod](rb, i)
			end

			assert.is_false(rb:empty())
			assert.is.equal(rb:size(), t.size)

			local i = 1
			for _, v in rb[itermethod](rb) do
				assert.is.equal(v, t.input[i])
				i = i + 1
			end
		end
	end

	test("pushtail", function()
		test_store("pushtail", "iterate")
	end)

	test("pushhead", function()
		test_store("pushhead", "riterate")
	end)

	test("push tail and head", function()
		local expected = {4, 2, 1, 30}
		local rb = Queue()

		rb:pushtail(1)
		rb:pushhead(2)
		rb:pushhead(4)
		rb:pushtail(30)
		assert.is.equal(rb:size(), 4)
		local i = 1
		while rb:empty() ~= true do
			assert.is.equal(rb:pophead(), expected[i])
			i = i + 1
		end
		assert.is.equal(rb:size(), 0)
	end)
end)

describe("containers.PQueue", function()
	local PriorityQueue = dcsex.containers.PriorityQueue

	local input = {
		{3, "Clear drains"},
		{4, "Feed cat"},
		{5, "Make tea"},
		{1, "Solve RC tasks"},
		{2, "Tax return"},
		{2, "Ford"},
		{2, "Toyota"},
	}

	local verify = {
		{1, "Solve RC tasks"},
		{2, "Toyota"},
		{2, "Tax return"},
		{2, "Ford"},
		{3, "Clear drains"},
		{4, "Feed cat"},
		{5, "Make tea"},
	}

	test("test methods", function()
		local pq = PriorityQueue()
		for _, task in ipairs(input) do
			pq:push(unpack(task))
		end

		assert.is.equal(pq:size(), #verify)

		local i = pq:peek()
		assert.is.equal(i, verify[1][2])

		i = 0
		for t, p in pq.pop, pq do
			i = i + 1
			local v = verify[i]
			assert(v[1] == p and v[2] == t,
				"pq, ordering not as expected")
		end
		assert.is_true(pq:empty())
	end)
end)

describe("containers.RingBuffer", function()
	local RingBuffer = dcsex.containers.RingBuffer
	local tests = {
		{
			name = "storage",
			size = 4,
			input = {1, 2, 3, 4},
			verify = {1, 2, 3, 4},
		}, {
			name = "overflow",
			size = 4,
			input = {33, 22, 3, 5, 31, 2, 9, 10, 23, 45},
			verify = {9, 10, 23, 45},
		}, {
			name = "min",
			size = 10,
			input = {1, 2, 3, 4},
			verify = {1, 2, 3, 4},
		},
	}

	test("test methods", function()
		local rb = RingBuffer()

		assert.is.equal(rb:size(), 0)
		assert.is.equal(rb:peek(), nil)
		assert.is_false(rb:full())
		assert.is_true(rb:empty())

		for _, t in ipairs(tests) do
			rb = RingBuffer(t.size)
			for _, i in ipairs(t.input) do
				rb:push(i)
			end

			assert.is_false(rb:empty())
			assert.is.equal(rb:peek(), t.verify[1])

			for _, i in ipairs(t.verify) do
				assert.is.equal(rb:peek(), i)
				assert.is.equal(rb:pop(), i)
			end
		end
	end)
end)

describe("containers.Graph", function()
	local graph = dcsex.containers.graph

	-- luacheck: ignore 311
	test("test", function()
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
		--  A -- 5 --> B <-- 1 -- E
		--  A <-- 4 -- B -- 2 -+
		--  |                  |
		--  +-- 3 --> C <------+
		--
		-- D is not in the graph

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
		-- of all nodes, hence when b = nil above there are no more
		-- references to b, thus the weak reference to b in the neighbor
		-- list for node e should be garbage collected.
		collectgarbage()
		assert(next(G:neighbors(e)) == nil)
	end)
end)
