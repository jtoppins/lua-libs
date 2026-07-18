#!/usr/bin/lua

require 'busted.runner'()
require("dcsext")

describe("validate dcsext.world", function()
	test("coalition", function()
		assert.is.equal(dcsext.world.getCoalitionEnemy(1), 2)
		assert.is.equal(dcsext.world.getCoalitionString(1), "red")
		assert.is_true(dcsext.world.isEnemy(coalition.side.RED,
						   coalition.side.BLUE))
		assert.is_false(dcsext.world.isEnemy(coalition.side.RED,
						    coalition.side.NEUTRAL))
	end)

	test("markID", function()
		local markid = dcsext.world.getNextMarkID()
		assert.is.equal(dcsext.world.getCurrentMarkID(), markid)
	end)

	test("", function()
		local position = {
			p = {x = 0, y = 0, z = 0},
			x = {x = 0, y = 0.34, z = 1},
			y = {x = 1, y = 1, z = 1},
			z = {x = 1, y = 1, z = 1},
		}

		assert.is.near(dcsext.world.unit.getHeading(position),
				1.571, 0.001)
		assert.is.near(dcsext.world.unit.getPitch(position),
				0.347, 0.001)
	end)
end)
