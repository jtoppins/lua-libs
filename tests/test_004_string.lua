#!/usr/bin/lua
require 'busted.runner'()
require("dcsex")

describe("validate string.", function()
	test("firstToUpper", function()
		assert.is.equal(
			dcsex.string.firstToUpper("test"),
			"Test")
		assert.is.equal(
			dcsex.string.firstToUpper("Foo"),
			"Foo")
	end)

	test("interp", function()
		local tbl = {
			["RE1"] = "hello",
			["RE2"] = "joe",
		}

		assert.is.equal(
			dcsex.string.interp("%RE1% %RE2%", tbl),
			"hello joe")
	end)

	test("join", function()
		local tbl = {"how", "now", "brown", "cow"}
		assert.is.equal(
			dcsex.string.join(tbl, "-"),
			"how-now-brown-cow")
	end)
	test("split", function()
		assert.is.same(
			dcsex.string.split("a,b,c", ','),
			{'a', 'b', 'c'})
	end)
	test("startsWith", function()
		assert.is_true(
			dcsex.string.startsWith("thisIsmyString", "this"))
	end)
	test("trim", function()
		assert.is.equal(
			dcsex.string.trim("  shaveme   "),
			"shaveme")
	end)
end)
