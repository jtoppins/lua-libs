#!/usr/bin/lua
require 'busted.runner'()
require("dcsext")

local testcentroid = {
	{
		["points"] = {
			[1] = {
				["x"] = 10, ["y"] = -4, ["z"] = 15,
			},
			[2] = {
				["x"] = 5, ["y"] = 2,
			},
			[3] = {
				["y"] = 7, ["x"] = 4,
			},
		},
		["expected"] = {
			["x"] = 6.333333, ["y"] = 1.66666,
		},
	}, {
		["points"] = {
			[1] = {
				["x"] = 10, ["y"] = 15,
			},
			[2] = {
				["x"] = 4, ["y"] = 2,
			},
			[3] = {
				["x"] = 7, ["y"] = 4,
			},
		},
		["expected"] = {
			["x"] = 7, ["y"] = 7,
		},
	}, {
		["points"] = {
			{ ["y"] = -172350.64739488, ["x"] = -26914.832345419, },
			{ ["y"] = -172782.23876319, ["x"] = -26886.142122476, },
			{ ["y"] = -172576.47430698, ["x"] = -27159.936678189, },
		},
		["expected"] = {
			["x"] = -26986.970382028, ["y"] = -172569.786821683,
		},
	},
}

describe("validate math.", function()
	test("bitset2num", function()
		local bitset = {
			[1] = true,
			[4] = true,
		}

		assert.is.equal(dcsext.math.bitset2num(bitset), 18)
	end)

	test("centroid2D", function()
		for _, v in ipairs(testcentroid) do
			local centroid, n
			for _, pt in ipairs(v.points) do
				centroid, n = dcsext.math.centroid2D(pt,
					centroid, n)
			end

			assert.is.near(centroid.x, v.expected.x, 0.00001)
			assert.is.near(centroid.y, v.expected.y, 0.00001)
		end
	end)

	test("clamp", function()
		assert.is.equal(dcsext.math.clamp(4,3,5), 4)
		assert.is.equal(dcsext.math.clamp(6,3,5), 5)
		assert.is.equal(dcsext.math.clamp(2,3,5), 3)
		assert.is.equal(dcsext.math.clamp(5, 2, 4), 4)
		assert.is.equal(dcsext.math.clamp(1, 2, 4), 2)
		assert.is.equal(dcsext.math.clamp(2.4, 2, 4), 2.4)
	end)

	test("lerp", function()
		assert.is.equal(dcsext.math.lerp(1, 2, .5), 1.5)
	end)

	test("isBitSet", function()
		assert.is_true(dcsext.math.isBitSet(3, 8))
	end)

	test("toBoolean", function()
		assert.is_false(dcsext.math.toBoolean("off"))
	end)

	test("addStdDev", function()
		math.randomseed(12345)
		assert.is.equal(dcsext.math.addStdDev(1, 5), -3)
	end)
end)
