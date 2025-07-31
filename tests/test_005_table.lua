#!/usr/bin/lua
require 'busted.runner'()
require("dcsex")

local t = {
	a = 4,
	b = 6,
	c = 10,
}

describe("validate table.", function()
	test("iterators.sortedPairs", function()
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
		for k, v in dcsex.table.iterators.sortedPairs(test.input) do
			table.insert(newout, string.format("%s = %d", k, v))
		end
		assert.is.equal(table.concat(newout, ", "),
				table.concat(test.expected, ", "))
	end)

	test("contains", function()
		assert.is_true(dcsex.table.contains(t, 6))
		assert.is_false(dcsex.table.contains(t, 100))

		local _, key = dcsex.table.contains(t, 4)
		assert.is.equal(key, "a")
	end)

	test("deepCopy", function()
		local mcopy = dcsex.table.deepCopy(t)
		assert.is.same(t, mcopy)
	end)

	test("foreachCall", function()
		local v = 0
		local tbl = {
			thing1 = {
				sum = function()
					v = v + 1
				end,
			},
			thing2 = {
				sum = function()
					v = v + 1
				end,
			},
		}

		dcsex.table.foreachCall(tbl, pairs, "sum")
		assert.is.equal(v, 2)
	end)

	test("getKey", function()
		assert.is.equal(dcsex.table.getKey(t, 6), "b")
		assert.is.equal(dcsex.table.getKey(t, 100), nil)
	end)

	test("getKeys", function()
		local v = dcsex.table.getKeys(t)
		table.sort(v)
		assert.is.same(v, {"a", "b", "c"})
	end)

	test("merge", function()
		local v = dcsex.table.merge({}, t)
		dcsex.table.merge(v, {b = 20, d = 40})
		assert.is.same(v, {a=4, b=20, c=10, d=40})
	end)
end)
