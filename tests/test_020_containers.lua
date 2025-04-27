#!/usr/bin/lua
require 'busted.runner'()
require "os"


describe("containers.Queue", function()
	local Queue = require("libs.containers.queue")
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
