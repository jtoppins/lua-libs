#!/usr/bin/lua
require('busted.runner')()
require("dcsext")

local points = {
	{x = 25, y = 30},
	{x = -23, y = 50},
	{x = 200, y = 300},
	{x = 500, y = 600},
}

describe("Color", function()
	test("is correct", function()
		local colors = {
			{
				color = dcsext.ui.Color.colors.BLACK,
				test = {0,0,0,1}
			}, {
				color = dcsext.ui.Color.colors.GRAY,
				test = {128/255,128/255,128/255,1}
			}, {
				color = dcsext.ui.Color.colors.RED,
				test = {1,0,0,1}
			}, {
				color = dcsext.ui.Color.colors.GREEN,
				test = {0,1,0,1}
			}, {
				color = dcsext.ui.Color.colors.BLUE,
				test = {0,0,1,1}
			}
		}

		for _, v in ipairs(colors) do
			assert.is.same(v.test, v.color:get())
		end
	end)
end)

describe("ui objects", function()
	test("are drawable", function()
		local objs = {
			{
				ctor = dcsext.ui.Arrow,
				arg = points,
				stub = "arrowToAll",
			}, {
				ctor = dcsext.ui.Circle,
				arg = points[1],
				stub = "circleToAll",
			}, {
				ctor = dcsext.ui.Line,
				arg = points,
				stub = "lineToAll",
			}, {
				ctor = dcsext.ui.Mark,
				arg = points[1],
				stub = "markToAll",
			}, {
				ctor = dcsext.ui.PolyLine,
				arg = points,
				stub = "lineToAll",
			}, {
				ctor = dcsext.ui.Quad,
				arg = points,
				stub = "quadToAll",
			}, {
				ctor = dcsext.ui.Rect,
				arg = points,
				stub = "rectToAll",
			}, {
				ctor = dcsext.ui.Text,
				arg = points[1],
				stub = "textToAll",
			}, {
				ctor = dcsext.ui.Triangle,
				arg = points,
				stub = "markupToAll",
			},
		}

		for _, t in ipairs(objs) do
			local obj = t.ctor(t.arg)
			stub(trigger.action, t.stub)
			obj:draw()
			assert.stub(trigger.action[t.stub]).was.called()
			trigger.action[t.stub]:revert()
		end
	end)
end)
