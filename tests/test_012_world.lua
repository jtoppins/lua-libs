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
end)
