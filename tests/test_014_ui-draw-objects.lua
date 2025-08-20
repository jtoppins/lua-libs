#!/usr/bin/lua
require('busted.runner')()
require("dcsex")

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
				color = dcsex.ui.Color.colors.BLACK,
				test = {0,0,0,1}
			}, {
				color = dcsex.ui.Color.colors.GRAY,
				test = {128/255,128/255,128/255,1}
			}, {
				color = dcsex.ui.Color.colors.RED,
				test = {1,0,0,1}
			}, {
				color = dcsex.ui.Color.colors.GREEN,
				test = {0,1,0,1}
			}, {
				color = dcsex.ui.Color.colors.BLUE,
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
				ctor = dcsex.ui.Arrow,
				arg = points,
				stub = "arrorToAll",
			}, {
				ctor = dcsex.ui.Circle,
				arg = points[1],
				stub = "circleToAll",
			}, {
				ctor = dcsex.ui.Line,
				arg = points,
				stub = "lineToAll",
			}, {
				ctor = dcsex.ui.Mark,
				arg = points[1],
				stub = "markToAll",
			}, {
				ctor = dcsex.ui.PolyLine,
				arg = points,
				stub = "lineToAll",
			}, {
				ctor = dcsex.ui.Quad,
				arg = points,
				stub = "quadToAll",
			}, {
				ctor = dcsex.ui.Rect,
				arg = points,
				stub = "rectToAll",
			}, {
				ctor = dcsex.ui.Text,
				arg = points[1],
				stub = "textToAll",
			}, {
				ctor = dcsex.ui.Triangle,
				arg = points,
				stub = "markupToAll",
			},
		}

		for _, t in ipairs(objs) do
			local obj = t.ctor(t.arg)
			obj:draw()
		end
	end)
end)
