#!/usr/bin/lua
require 'busted.runner'()
require("os")
require("dcsext")

local function sleep(s)
	local n = os.clock() + s
	repeat until os.clock() > n
end

describe("validate Timer", function()
	local a, b

	test("start and update", function()
		a = dcsext.Timer(15, os.clock)
		b = dcsext.Timer(1, os.clock)

		a:start()
		b:start()
		sleep(1.3)
		a:update()
		b:update()
	end)

	test("remain", function()
		assert(a:remain() <= 14)
		assert.is.equal(b:remain(), 0)
	end)

	test("expired", function()
		assert.is_false(a:expired())
		assert.is_true(b:expired())
	end)

	test("reset", function()
		b:reset()
		assert.is.equal(b:remain(), 1)
	end)

	test("extend", function()
		b:extend(2)
		assert.is.equal(b:remain(), 3)
	end)

	pending("test stop method")
end)
