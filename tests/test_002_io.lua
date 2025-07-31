#!/usr/bin/lua
require('busted.runner')()
require("os")
require("dcsex")

describe("validate io", function()
	test("isDir", function()
		assert.is_true(dcsex.io.isDir("."))
	end)

	test("joinPaths", function()
		local a = "foo"
		local b = "bar"
		local expected = a .. dcsex.io.pathSeperator .. b

		assert.is.equal(expected, dcsex.io.joinPaths(a, b))
	end)
end)
