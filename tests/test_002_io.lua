#!/usr/bin/lua
require('busted.runner')()
require("os")
require("dcsext")

describe("validate io", function()
	test("isDir", function()
		assert.is_true(dcsext.io.isDir("."))
	end)

	test("joinPaths", function()
		local a = "foo"
		local b = "bar"
		local expected = a .. dcsext.io.pathSeperator .. b

		assert.is.equal(expected, dcsext.io.joinPaths(a, b))
	end)
end)
