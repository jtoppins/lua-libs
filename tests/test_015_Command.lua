#!/usr/bin/lua
require 'busted.runner'()
require("dcsext")

describe("Command class", function()
	local cmd

	local foo = function ()
		return 5
	end

	test("has a constructor", function()
		cmd = dcsext.interfaces.Command(5, "foo", foo)
		assert.equal("Command.foo", tostring(cmd))
	end)

	test("is callable", function()
		assert.equal(5, cmd())
	end)

	test("has properties", function()
		cmd.delay = 10
		cmd.priority = 20
		cmd.requeueOnError = true
		assert.equal(10, cmd.delay)
	end)
end)
