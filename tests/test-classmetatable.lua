#!/usr/bin/lua
require("os")

local utils = require("libs.utils")
local class = require("libs.classnamed")

local function test()
	local A_mt = {}
	function A_mt.__lt(a, other)
		return a.cost < other.cost
	end

	function A_mt.__eq(a, other)
		return a.cost == other.cost
	end

	local A = utils.override_ops(class("A"), A_mt)
	function A:__init(v)
		self.cost = v
	end

	local B = class("B", A)

	local a = A(3)
	local b = A(5)
	local c = A(-3)
	local d = B(3)

	assert(a < b)
	assert(a >= c)
	assert(b > c)
	assert(a == d)
	assert(type(getmetatable(d).__lt) == "function")
	assert(type(getmetatable(d).__eq) == "function")
	assert(type(getmetatable(a).__eq) == "function")
end
os.exit(test())
