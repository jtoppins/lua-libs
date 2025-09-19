-- SPDX-License-Identifier: LGPL-3.0

--- Vector math library.

require("math")
local class = require("dcsext.class")
local mytable = require("dcsext.table")

--- Calculate the unit vector of `vec`.
-- @param vec vector to calculate the unit vector of.
-- @return unit vector of vec
local function unitvec(vec)
	local l = vec:magnitude()

	if l == 0 then
		return nil
	end

	return vec / l
end

--- 2D Vector Math.
-- Metamethods support scalar addition, subtraction, multiplication,
-- and division. There is also support for strict equality and string
-- serialization.
local Vec2 = class("Vec2")
local mt2d = {}

-- String representation of vector
function mt2d.__tostring(vec)
	return string.format("(%g, %g)", vec.x, vec.y)
end

-- Strict equality.
function mt2d.__eq(self, rhs)
	return (type(rhs) == "table") and (self.x == rhs.x) and
		(self.y == rhs.y)
end

-- Unitary minus
function mt2d.__unm(self)
	local v = {}
	v.x = -self.x
	v.y = -self.y
	return Vec2(v)
end

-- Vector addition.
function mt2d.__add(self, rhs)
	assert(type(rhs) == "table" and rhs.x ~= nil and rhs.y ~= nil,
		"value error: illegal addition rhs not a 2D vector")
	local v = {}
	v.x = self.x + rhs.x
	v.y = self.y + rhs.y
	return Vec2(v)
end

-- Vector subtraction.
function mt2d.__sub(self, rhs)
	assert(type(rhs) == "table" and rhs.x ~= nil and rhs.y ~= nil,
		"value error: illegal subtraction rhs not a 2D vector")
	local v = {}
	v.x = self.x - rhs.x
	v.y = self.y - rhs.y
	return Vec2(v)
end

-- Scalar multiplication.
function mt2d.__mul(self, s)
	local v = {}

	if type(self) == "number" and type(s) == "table" then
		v.x = self * s.x
		v.y = self * s.y
	elseif type(self) == "table" and type(s) == "number" then
		v.x = self.x * s
		v.y = self.y * s
	else
		return nil
	end

	return Vec2(v)
end

-- Scalar division
function mt2d.__div(self, rhs)
	assert(type(rhs) == "number",
		"value error: illegal division rhs not a number")
	local v = {}
	v.x = self.x / rhs
	v.y = self.y / rhs
	return Vec2(v)
end

--- Constructor. Create Vec2 object from `obj`. The constructor
-- never fails and if no coordinate elements are detected all values
-- will be zero.
-- @param obj can be a 2d or 3d object of DCS or Vector class origin
--     the constructor will select the correct fields to convert to
--     a normal 2d object based on some DCS particulars.
function Vec2:__init(obj)
	obj = obj or {x = 0, y = 0}
	self.x = obj.x or 0
	if obj.z then
		self.y = obj.z
	else
		self.y = obj.y or 0
	end
	local curmt = getmetatable(self) or {}
	curmt = mytable.merge(curmt, mt2d)
	setmetatable(self, curmt)
	self.new = nil
end

--- Constructor. Create Vec2 object from `x` and `y` coordinates.
-- The constructor never fails and if no coordinate elements are detected
-- all values will be zero.
function Vec2.new(x, y)
	local t = { ["x"] = x, ["y"] = y, }
	return Vec2(t)
end

--- Reset the current Vec2 to the specified x & y values.
function Vec2:set(x, y)
	self.x = x or 0
	self.y = y or 0
end

--- Create a raw lua table with 'x' and 'y' keys. Used for passing to
-- DCS functions.
function Vec2:get()
	return { ["x"] = self.x, ["y"] = self.y }
end

--- Calculate the vector magnitude.
function Vec2:magnitude()
	return math.sqrt(self.x * self.x + self.y * self.y)
end

--- Alias to get the magnitude of the vector.
Vec2.length = Vec2.magnitude

--- Translate a Vec2.
function Vec2:translate(dx, dy)
	local v = {}
	v.x = self.x + (dx or 0)
	v.y = self.y + (dy or 0)
	return Vec2(v)
end

--- Rotate the 2D vector. Using standard right-hand rule rotation,
-- counter-clockwise for positive values of theta.
function Vec2:rotate(theta)
	local sint = math.sin(theta)
	local cost = math.cos(theta)
	local v = {}
	v.x = self.x * cost - self.y * sint
	v.y = self.x * sint + self.y * cost
	return Vec2(v)
end

--- 3D Vector Math
-- Metamethods support scalar addition, subtraction, multiplication,
-- and division. There is also support for strict equality and string
-- serialization.
local Vec3 = class("Vec3")
local mt3d = {}

-- String representation of vector
function mt3d.__tostring(vec)
	return string.format("(%g, %g, %g)", vec.x, vec.y, vec.z)
end

-- Strict equality.
function mt3d.__eq(self, rhs)
	return (type(rhs) == "table") and (self.x == rhs.x) and
	       (self.y == rhs.y) and (self.z == rhs.z)
end

-- Unitary minus
function mt3d.__unm(self)
	local v = {}
	v.x = -self.x
	v.y = -self.y
	v.z = -self.z
	return Vec3(v)
end

-- Vector addition.
function mt3d.__add(self, rhs)
	assert((type(rhs) == "table") and rhs.x ~= nil and
		rhs.y ~= nil and rhs.z ~= nil,
		"value error: illegal addition rhs not a 3D vector")
	local v = {}
	v.x = self.x + rhs.x
	v.y = self.y + rhs.y
	v.z = self.z + rhs.z
	return Vec3(v)
end

-- Vector subtraction.
function mt3d.__sub(self, rhs)
	assert((type(rhs) == "table") and rhs.x ~= nil and
		rhs.y ~= nil and rhs.z ~= nil,
		"value error: illegal subtraction rhs not a 3D vector")
	local v = {}
	v.x = self.x - rhs.x
	v.y = self.y - rhs.y
	v.z = self.z - rhs.z
	return Vec3(v)
end

-- Scalar multiplication.
function mt3d.__mul(self, s)
	local v = {}

	if type(self) == "number" and type(s) == "table" then
		v.x = self * s.x
		v.y = self * s.y
		v.z = self * s.z
	elseif type(self) == "table" and type(s) == "number" then
		v.x = self.x * s
		v.y = self.y * s
		v.z = self.z * s
	else
		return nil
	end

	return Vec3(v)
end

-- Scalar division
function mt3d.__div(self, rhs)
	assert(type(rhs) == "number",
		"value error: illegal division rhs not a number")
	local v = {}
	v.x = self.x / rhs
	v.y = self.y / rhs
	v.z = self.z / rhs
	return Vec3(v)
end

-- Cross product '^'
function mt3d.__pow(self, rhs)
	assert((type(rhs) == "table") and rhs.x ~= nil and
		rhs.y ~= nil and rhs.z ~= nil,
		"value error: illegal cross-product rhs not a 3D vector")
	local v = {}
	v.x = self.y * rhs.z - self.z * rhs.y
	v.y = self.z * rhs.x - self.x * rhs.z
	v.z = self.x * rhs.y - self.y * rhs.x
	return Vec3(v)
end

--- Constructor. Create Vec3 object from `obj`. The constructor never
-- fails and if no coordinate elements are detected all values will be
-- zero.
-- @param obj can be a 2d or 3d object of DCS or Vector class origin
--     the constructor will select the correct fields to convert to
--     a normal 3d object based on some DCS particulars.
function Vec3:__init(obj)
	obj = obj or {x = 0, y = 0, z = 0}
	self.x = obj.x or 0

	if obj.z then
		self.y = obj.y or 0
		self.z = obj.z
	else
		self.y = obj.alt or 0
		self.z = obj.y or 0
	end
	local curmt = getmetatable(self) or {}
	curmt = mytable.merge(curmt, mt3d)
	setmetatable(self, curmt)
	self.new = nil
end

--- Constructor. Create Vec3 object from `x`, `y`, and `z` values.
-- The constructor never fails and if no coordinate elements are detected
-- all values will be zero.
function Vec3.new(x, y, z)
	local t = { ["x"] = x or 0, ["y"] = y or 0, ["z"] = z or 0, }
	return Vec3(t)
end

--- Reset the current Vec3 to the specified x, y, & z values.
function Vec3:set(x, y, z)
	self.x = x or 0
	self.y = y or 0
	self.z = z or 0
end

--- Create a raw lua table with 'x', 'y', and 'z' keys. Used for passing
-- to DCS functions.
function Vec3:get()
	return { ["x"] = self.x, ["y"] = self.y, ["z"] = self.z }
end

--- Calculate the vector magnitude.
function Vec3:magnitude()
	return math.sqrt(self.x^2 + self.y^2 + self.z^2)
end

--- Alias to get the magnitude of the vector.
Vec3.length = Vec2.magnitude

--- Translate a Vec3.
function Vec3:translate(dx, dy, dz)
	local v = {}
	v.x = self.x + (dx or 0)
	v.y = self.y + (dy or 0)
	v.z = self.z + (dz or 0)
	return Vec3(v)
end

--- Rotate Vec3 about the Z axis.
function Vec3:rotZ(theta)
	local sint = math.sin(theta)
	local cost = math.cos(theta)
	local v = {}
	v.x = self.x * cost - self.y * sint
	v.y = self.x * sint + self.y * cost
	v.z = self.z
	return Vec3(v)
end

--- Alias to rotZ so the same API exists for Vec2 & Vec3 classes.
Vec3.rotate = Vec3.rotZ

--- Rotate Vec3 about the X axis.
function Vec3:rotX(theta)
	local sint = math.sin(theta)
	local cost = math.cos(theta)
	local v = {}
	v.x = self.x
	v.y = self.y * cost - self.z * sint
	v.z = self.y * sint + self.z * cost
	return Vec3(v)
end

--- Rotate Vec3 about the Y axis.
function Vec3:rotY(theta)
	local sint = math.sin(theta)
	local cost = math.cos(theta)
	local v = {}
	v.x = self.z * sint + self.x * cost
	v.y = self.y
	v.z = self.z * cost - self.x * sint
	return Vec3(v)
end

--- Rotate Vec3 about an arbitrary axis.
function Vec3:rotAxis(axis, theta)
	local ax = unitvec(axis)
	local cosa = math.cos(theta)
	local sina = math.sin(theta)
	local versa = 1.0 - cosa
	local xy = ax.x * ax.y
	local yz = ax.y * ax.z
	local zx = ax.z * ax.x
	local sinx = ax.x * sina
	local siny = ax.y * sina
	local sinz = ax.z * sina
	local m10 = ax.x * ax.x * versa + cosa
	local m11 = xy * versa + sinz
	local m12 = zx * versa - siny
	local m20 = xy * versa - sinz
	local m21 = ax.y * ax.y * versa + cosa
	local m22 = yz * versa + sinx
	local m30 = zx * versa + siny
	local m31 = yz * versa - sinx
	local m32 = ax.z * ax.z * versa + cosa
	return Vec3.new(m10 * self.x + m20 * self.y + m30 * self.z,
			m11 * self.x + m21 * self.y + m31 * self.z,
			m12 * self.x + m22 * self.y + m32 * self.z)
end

local _t = {}
_t.Vec2 = Vec2
_t.Vec3 = Vec3

--- Get the bearing or azmith between two points.
-- @param vec1
-- @param vec2 optional will be assumed to be zero,zero
-- @return bearing in radians
-- @within vector
function _t.bearing(vec1, vec2)
	local v
	vec1 = _t.Vec2(vec1)
	vec2 = _t.Vec2(vec2)

	v = vec1 - vec2
	return math.atan2(v.y, v.x)
end

--- Calculate the distance between `vec1` and `vec2`.
-- @param vec1 first vector.
-- @param vec2 second vector.
-- @return distance between vec1 and vec2
-- @within vector
function _t.distance(vec1, vec2)
	local v = vec2 - vec1
	return v:magnitude()
end

--- @within vector
_t.unitvec = unitvec

--- Dot product of vectors U and V. The vectors must be of the same
-- order.
-- @param U vector
-- @param V vector
-- @return scalar value
-- @within vector
function _t.dot(U, V)
	assert((U:isa(Vec2) and V:isa(Vec2)) or
		   (U:isa(Vec3) and V:isa(Vec3)),
		   "vectors are not of the same order")
	local sum = 0

	for _, n in ipairs({'x', 'y', 'z'}) do
		if U[n] and V[n] then
			sum = sum + (U[n] * V[n])
		end
	end
	return sum
end

--- Angle between 2D vectors A and B in radians
-- @param A
-- @param B
-- @return angle in radians
-- @within vector
function _t.angle(A, B)
	local dot = _t.dot(A, B)
	return math.acos(dot / (A:magnitude() * B:magnitude()))
end

return _t
