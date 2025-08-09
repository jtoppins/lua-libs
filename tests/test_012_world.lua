#!/usr/bin/lua

require 'busted.runner'()
require("dcsex")

describe("validate dcsex.world", function()
	test("coalition", function()
		assert.is.equal(dcsex.world.getCoalitionEnemy(1), 2)
		assert.is.equal(dcsex.world.getCoalitionString(1), "red")
		assert.is_true(dcsex.world.isEnemy(coalition.side.RED,
						   coalition.side.BLUE))
		assert.is_false(dcsex.world.isEnemy(coalition.side.RED,
						    coalition.side.NEUTRAL))
	end)

	test("markID", function()
		local markid = dcsex.world.getNextMarkID()
		assert.is.equal(dcsex.world.getCurrentMarkID(), markid)
	end)
end)
