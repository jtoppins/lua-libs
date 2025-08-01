#!/usr/bin/lua
require('busted.runner')()
require("os")
require("dcsex")

local utils = dcsex.utils
local class = dcsex.class
local classnamed = dcsex.classnamed

describe("libs", function()
	test("verify", function()
		assert(_G["dcsex"] ~= nil)
		assert(dcsex.class ~= nil)
	end)
end)

describe("validate class", function()
	test("verify basic operation", function()
		local A = class()
		function A:__init(v)
			self.val = v
			self.__name = "A"
		end
		function A:exec()
			self.val = self.val + 1
			return "A"
		end

		local B = class(A)
		function B:__init(v)
			A.__init(self, v)
			self.__name = "B"
		end
		function B:exec()
			local s = ""
			s = s .. A.exec(self)
			s = s .. "B"
			return s
		end

		local C = class(B)
		function C:__init(v)
			B.__init(self, v)
			self.__name = "C"
		end
		function C:exec()
			local s = ""
			s = s .. B.exec(self)
			s = s .. "C"
			return s
		end

		local J = class()

		local a = A(2)
		assert.is.equal(a:exec(), "A")
		assert.is.equal(a.val, 3)

		local b = B(3)
		assert.is.equal(b:exec(), "AB")
		assert.is.equal(b.val, 4)
		assert.is.equal(a.val, 3)

		local c = C(5)
		assert.is.equal(c:exec(), "ABC")
		assert(c:isa(C))
		assert(c:isa(A))
		assert(not c:isa(J))
	end)

	test("verify metatable", function()
		local A_mt = {}
		function A_mt.__lt(a, other)
			return a.cost < other.cost
		end

		function A_mt.__eq(a, other)
			return a.cost == other.cost
		end

		local A = utils.override_ops(classnamed("A"), A_mt)
		function A:__init(v)
			self.cost = v
		end

		local B = classnamed("B", A)

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
	end)

	test("callable", function()
		local function callable(cls)
			local inst = {}
			setmetatable(inst, { __index = cls })
			return inst
		end

		local A = {
			__call = callable,
		}
		setmetatable(A, A)

		local B = {}
		setmetatable(B, { __call = callable })

		A()
		B()
	end)
end)
