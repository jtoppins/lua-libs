#!/usr/bin/lua

require 'busted.runner'()
require("dcsext")

local say = require("say")

local function same_vector(_state, args)
	if #args < 2 or not (type(args[1]) == "table" and
			     type(args[2]) == "table") then
		return false
	end
	local tolerance = args[3] or 0.00001

	assert.is.near(args[1].x, args[2].x, tolerance)
	assert.is.near(args[1].y, args[2].y, tolerance)
	assert.is.near(args[1].z, args[2].z, tolerance)
	return true
end

say:set("assertion.same_vector.positive", "Expected %s \ngot: %s")
say:set("assertion.same_vector.positive", "Expected %s \ngot: %s")
assert:register("assertion", "same_vector", same_vector,
		"assertion.same_vector.positive",
		"assertion.same_vector.negative")

describe("validate dcsext.vector.Vec2", function()
	local vector
	local a, b, c

	before_each(function()
		vector = dcsext.vector
		a = vector.Vec2({x=5,y=5})
		b = vector.Vec2({x=3,y=3})
		c = vector.Vec2({x=3,y=3})
	end)

	test("tostring", function()
		assert.is.equal(tostring(a), "(5, 5)")
	end)
	test("inequality", function()
		assert.is_not.equal(a, b)
	end)
	test("equality", function()
		assert.is.equal(c, b)
	end)
	test("unitary", function()
		assert.is.same(-c, vector.Vec2({x=-3,y=-3}))
	end)
	test("vector addition", function()
		assert.is.equal((a + b), vector.Vec2({x=8,y=8}))
	end)
	test("vector subtraction", function()
		assert.is.equal((a - b), vector.Vec2({x=2,y=2}))
	end)
	test("scalar product", function()
		assert.is.equal((3 * a), vector.Vec2({x=15,y=15}))
	end)
	test("scalar division", function()
		assert.is.equal((3 * a) / 3, a)
	end)
	test("create/set/get", function()
		local n = vector.Vec2.new(4,7)
		assert.is.equal(n.y, 7)
		n:set(5,10)
		assert.is.equal(n.x, 5)
		assert.is.same(n:get(),{x=5,y=10})
	end)
	test("magnitude", function()
		assert.is.equal(7071, math.floor(1000 * a:magnitude()))
		assert.is.equal(7071, math.floor(1000 * a:length()))
	end)
	test("translate", function()
		local n = a:translate(4,-3)
		assert.is.same(n:get(),{x=9,y=2})
	end)
	test("rotate", function()
		local ra = a:rotate(math.pi)
		assert.is.near(ra.x, -5.0, 0.00001)
	end)
	test("distance", function()
		assert.is.near(vector.distance(a,b), 2.8284, 0.0001)
	end)
	test("dot-product", function()
		assert.is.equal(vector.dot(a,b), 30)
	end)
	test("angle", function()
		assert.is.near(vector.angle(a,b), 0, 0.000001)
	end)
	test("unitvec()", function()
		assert.is.equal(1000,
			math.ceil(vector.unitvec(a):magnitude() * 1000))
	end)
	test("projection", function()
		local A = vector.Vec2.new(3, 4)
		local B = vector.Vec2.new(4, 0)
		assert.is.same({x = 3, y = 0},
			(vector.projection(A, B)):get())
	end)
end)

describe("validate dcsext.vector.Vec3", function()
	local vector
	local a, b, c

	before_each(function()
		vector = dcsext.vector
		a = vector.Vec3.new(1.0, 0.0, 0.0)
		b = vector.Vec3.new(0.0, 1.0, 0.0)
		c = vector.Vec3.new(0.0, 1.0, 0.0)
	end)

	test("tostring", function()
		assert.is.equal(tostring(a), "(1, 0, 0)")
	end)
	test("inequality", function()
		assert.is_not.equal(a, b)
	end)
	test("equality", function()
		assert.is.equal(c, b)
	end)
	test("unitary", function()
		assert.is.same(-c, vector.Vec3.new(0.0, -1.0, 0.0))
	end)
	test("vector addition", function()
		assert.is.equal((a + b), vector.Vec3.new(1.0, 1.0, 0.0))
	end)
	test("vector subtraction", function()
		assert.is.equal((a - b), vector.Vec3.new(1.0, -1.0, 0.0))
	end)
	test("scalar product", function()
		assert.is.equal((a + b * 10), vector.Vec3.new(1.0, 10.0, 0.0))
	end)
	test("scalar division", function()
		assert.is.equal((3 * a) / 3, a)
	end)
	test("cross-product", function()
		assert.is.same(a ^ b, vector.Vec3({x=0,y=0,z=1}))
	end)
	test("create/set/get", function()
		local n = vector.Vec3.new(4,7)
		assert.is.equal(n.y, 7)
		n:set(5,10)
		assert.is.equal(n.x, 5)
		assert.is.same(n:get(),{x=5,y=10,z=0})
	end)
	test("magnitude", function()
		assert.is.equal(1000, math.floor(1000 * a:magnitude()))
		assert.is.equal(1000, math.floor(1000 * a:length()))
	end)
	test("translate", function()
		local n = a:translate(4,-3)
		assert.is.same(n:get(),{x=5,y=-3,z=0})
	end)
	test("rotY", function()
		local ra = a:rotY(math.pi/4)
		assert.is.near(ra.x, 0.707107, 0.00001)
		assert.is.near(ra.y, 0, 0.00001)
		assert.is.near(ra.z, -0.707107, 0.00001)
	end)
	test("distance", function()
		assert.is.near(vector.distance(a,b), 1.4142, 0.0001)
	end)
	test("dot-product", function()
		assert.is.equal(vector.dot(a,b), 0)
	end)
	test("unitvec()", function()
		assert.is.equal(1000,
			math.ceil(vector.unitvec(a):magnitude() * 1000))
	end)
end)

describe("validate dcsext.vector.Vec3:rotAxis", function()
	local test_cases = {
		{
			["name"]   = "Identity",
			["vector"] = dcsext.vector.Vec3.new(1, 0, 0),
			["axis"]   = dcsext.vector.Vec3.new(0, 1, 0),
			["theta"]  = 0,
			["result"] = dcsext.vector.Vec3.new(1, 0, 0)
		}, {
			["name"]   = "Rotate X around Y by 90 -> Should be -Z",
			["vector"] = dcsext.vector.Vec3.new(1, 0, 0),
			["axis"]   = dcsext.vector.Vec3.new(0, 1, 0),
			["theta"]  = math.rad(90),
			["result"] = dcsext.vector.Vec3.new(0, 0, -1)
		}, {
			["name"]   = "Rotate X around Z by 90 -> Should be Y",
			["vector"] = dcsext.vector.Vec3.new(1, 0, 0),
			["axis"]   = dcsext.vector.Vec3.new(0, 0, 1),
			["theta"]  = math.rad(90),
			["result"] = dcsext.vector.Vec3.new(0, 1, 0)
		}, {
			["name"]   = "Parallel",
			["vector"] = dcsext.vector.Vec3.new(0, 0, 5),
			["axis"]   = dcsext.vector.Vec3.new(0, 0, 1),
			["theta"]  = math.rad(45),
			["result"] = dcsext.vector.Vec3.new(0, 0, 5)
		}, {
			["name"]   = "180 flip around diagonal (1, 1, 0)",
			["vector"] = dcsext.vector.Vec3.new(1, 0, 0),
			["axis"]   = dcsext.vector.Vec3.new(1, 1, 0),
			["theta"]  = math.rad(180),
			["result"] = dcsext.vector.Vec3.new(0, 1, 0)
		}
	}

	local function gen_tests(func)
		for k, t in ipairs(test_cases) do
			test(string.format("Test %d: %s", k, t.name),
			     function()
				local r = t.vector[func](t.vector, t.axis, t.theta)
				assert.same_vector(t.result, r)
			end)
		end
	end

	gen_tests("rotAxis")
end)
