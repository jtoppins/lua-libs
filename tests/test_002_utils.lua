#!/usr/bin/lua
require('busted.runner')()
require("os")
require("dcsex")

local utils = dcsex.utils

describe("validate utils", function()
	test("sortedpairs", function()
		local test = {
			["input"] = {
				a = 1,
				c = 3,
				b = 2,
				d = 4,
			},
			["expected"] = {
				"a = 1",
				"b = 2",
				"c = 3",
				"d = 4",
			},
		}

		local newout = {}
		for k, v in utils.sortedpairs(test.input) do
			table.insert(newout, string.format("%s = %d", k, v))
		end
		assert.is.equal(table.concat(newout, ", "),
				table.concat(test.expected, ", "))
	end)

	test("join_paths", function()
		local a = "foo"
		local b = "bar"
		local expected = a..utils.sep..b

		assert.is.equal(expected, utils.join_paths(a, b))
	end)

	test("isDir", function()
		assert.is_true(utils.isDir("."))
	end)

	test("split", function()
		local expected = { "my", "test", "string" }

		assert.are.same(utils.split("my.test.string", "."), expected)
	end)

	test("getkey", function()
		local t = {
			a = 3,
			b = 2,
		}

		assert.is.equal(utils.getkey(t, 2), 'b')
	end)

	test("clamp", function()
		assert.is.equal(utils.clamp(5, 2, 4), 4)
		assert.is.equal(utils.clamp(1, 2, 4), 2)
		assert.is.equal(utils.clamp(2.4, 2, 4), 2.4)
	end)

	test("addstddev", function()
		math.randomseed(12345)
		assert.is.equal(utils.addstddev(1, 5), -3)
	end)
end)
