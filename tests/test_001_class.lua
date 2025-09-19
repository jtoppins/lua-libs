#!/usr/bin/lua
require('busted.runner')()
require("dcsext")

describe("dcsext library", function()
	test("exports correctly", function()
		assert(_G["dcsext"] ~= nil)
		assert(dcsext.class ~= nil)
	end)
end)

local class = dcsext.class

describe("class() function", function()
	test("has some default methods", function()
		local A = class()
		assert.is_function(A.super)
		assert.is_function(A.isa)
		assert.is_function(A._property)
	end)

	test("can name the class", function()
		local A = class("A")
		assert.equal("A", A.__clsname)
		assert.equal("class(A)", tostring(A))
	end)
end)

describe("instances", function()
	test("can be created with __call()", function()
		local A = class()
		local a = A()
		assert.is_table(a)
	end)

	test("are equal", function()
		local A = class()
		local a = A()
		local b = A()
		assert.same(a, b)
	end)

	test("are independent", function()
		local A = class("A", {key = "value"})
		local a = A()
		local b = A()
		b.key = "other value"
		assert.equal("other value", b.key)
		assert.equal("value", a.key)
	end)
end)

describe("constructors", function()
	test("can be defined by __init()", function()
		local A = class("A", { value = 0 })
		function A:__init(val)
			self.value = val
		end

		local a = A(3)
		assert.equal(3, a.value)
	end)
end)

describe("inheritance", function()
	test("provides an is-a relationship", function()
		local A = class("A")
		local B = class("B", A)
		local b = B()

		assert.is_true(b:isa(A))
	end)

	test("gets methods from super", function()
		local A = class("A")
		function A:foo()
			return "foo"
		end

		local B = class("B", A)
		local b = B()
		assert.is_function(b.foo)
		assert.equal("foo", b:foo())
	end)

	test("provides multiple inheritance", function()
		local A = class("A")
		function A:foo()
			return "foo"
		end

		local B = class("B", A)
		function B:bar()
			return "bar"
		end

		local C = class("C", A, B)
		local c = C()
		assert.is_function(c.foo)
		assert.is_function(c.bar)
		assert.equal("bar", c:bar())
	end)

	test("supports overriding methods", function()
		local A = class("A")
		function A:foo()
			return 1
		end

		local B = class("B", A)
		function B:foo()
			return 1 + A.foo(self)
		end

		local b = B()
		assert.equal(2, b:foo())
	end)
end)

describe("property getters", function()
	test("return values", function()
		local A = class("A")
		function A:__init()
			self:_property("a", 1)
		end

		local a = A()
		assert.equal(1, a.a)
		-- verify 'a' doesn't exist as a key in the table
		assert.equal(nil, rawget(a, "a"))
	end)
end)

describe("property setters", function()
	test("use values", function()
		local A = class("A")
		function A:__init()
			self:_property("foo", 2)
		end

		local a = A()
		a.foo = "something else"
		assert.equal("something else", a.foo)
	end)

	test("use results of set function", function()
		local A = class("A")
		function A:__init()
			self:_property("foo", 2, function() return "bar" end)
		end

		local a = A()
		a.foo = "something else"
		assert.equal("bar", a.foo)
	end)

	test("pass new value, `value` to set function", function()
		local A = class("A")
		function A:__init()
			self:_property("foo", 2,
				function(_, _, new, old)
					return new .. old
				end)
		end

		local a = A()
		a.foo = "bar"
		assert.equal("bar2", a.foo)
	end)

	test("sets 'value'", function()
		local A = class("A")
		function A:__init()
			self:_property("foo", 2,
				function(_, _, new) return new end)
		end

		local a = A()
		a.foo = "bar2"
		assert.equal("bar2", a.foo)
	end)

	test("can use a callback", function()
		local b = 1
		local A = class("A")
		function A:__init()
			self:_property("foo", 2,
				function(_, _, new) return new end,
				function() b = 2 end)
		end

		local a = A()
		a.foo = "bar2"
		assert.equal("bar2", a.foo)
		assert.equal(2, b)
	end)

end)

describe("instance metamethods", function()
	test("can set/override", function()
		local A_mt = {}
		function A_mt.__lt(a, other)
			return a.cost < other.cost
		end

		function A_mt.__eq(a, other)
			return a.cost == other.cost
		end

		local A = dcsext.overrideOps(class("A"), A_mt)
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
		assert.is_function(getmetatable(d).__lt)
		assert.is_function(getmetatable(d).__eq)
		assert.is_function(getmetatable(a).__eq)
	end)
end)
