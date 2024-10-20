#!/usr/bin/lua
require("os")

local utils = require("libs.utils")
local class = require("libs.classnamed")

local function test()
	local A_mt = {}
	function A_mt.__lt(self, other)
		return self.cost < other.cost
	end

	local A = utils.override_ops(class(), A_mt)
	function A:__init(v)
		self.cost = v
	end

	local B_mt = {}
	function B_mt.__eq(self, other)
		return self.cost == other.cost
	end

	local B = utils.override_ops(class(A), B_mt)

	local a = A(3)
	local b = A(5)
	local c = A(-3)
	local d = B(3)

	assert(a < b)
	assert(a >= c)
	assert(a == d)
	assert(b > c)
	assert(type(getmetatable(d).__lt) == "function")
end
os.exit(test())
