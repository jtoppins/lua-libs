#!/usr/bin/lua
require('busted.runner')()
require("dcsex")

local utility = dcsex.utility

local function inputx(agent)
	return agent.x
end

local function inputy(agent)
	return agent.y
end

describe("utility", function()
	test("IAUS", function()
		local agent = { x = .35, y = .67, }
		local axis_x = utility.Axis(inputx, utility.curveTypes.LINEAR,
					2, 1, 1, 1)
		local axis_y = utility.Axis(inputy, utility.curveTypes.LOGISTIC,
					50, 2, -1, -2)
		local iaus = utility.IAUS(axis_x, axis_y)

		assert.is.near(axis_x:score(agent), 0, 0.001)
		assert.is.near(axis_y:score(agent), 0.85343, 0.001)
		assert.is.equal(iaus:score(agent), 0)
	end)
end)
