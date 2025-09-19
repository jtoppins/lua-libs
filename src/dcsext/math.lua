-- SPDX-License-Identifier: LGPL-3.0

--- Math - extensions to lua math.

local _t = {}

--- Add a random value between +/- sigma to val.
-- @param val base value
-- @param sigma random value between +/- sigma
-- @return val + random(-sigma,sigma)
function _t.addStdDev(val, sigma)
	return val + math.random(-sigma, sigma)
end

--- Convert a bit position to a value, ex 32 = 2^5 or the 5th bit,
-- indices are zero indexed. So for us humans if you look at 32
-- in binary (0b0010 0000) its really the 6th position from the
-- right.
-- @param bitpos the zero indexed nth bit position to convert to a
--   number
-- @return 2 ^ bitpos
function _t.bit2num(bitpos)
	return 2 ^ bitpos
end

--- Convert a bitset to a numerical value. Since Lua 5.1 doesn't
-- support bit manipulation this is our poor man's attempt to
-- represent a binary number or bitfield/flagset.
-- @param bitset is a table where the keys are integers and any
--   non-false value will result in the bit being counted.
-- @return numerical representation of the bitset
function _t.bitset2num(bitset)
	local num = 0

	for bit, val in pairs(bitset) do
		if val and type(bit) == "number" then
			num = num + _t.bit2num(bit)
		end
	end

	return num
end

--- Calculates the center of a set of points iteratively so that
-- all points do not have to be known initially.
-- @param point the next point to include in the center calculation
-- @param pcenter the center of all previous points calculated, nil
--   if just starting
-- @param n count of all previous points calculated, nil is starting
-- @return two values: updated center, number of points calculated
function _t.centroid2D(point, pcenter, n)
	if pcenter == nil or n == nil then
		return point, 1
	end

	n = tonumber(n)
	local n1 = n + 1
	local p = point
	local pc = pcenter
	local c = {}
	c.x = (p.x + (n * pc.x))/n1
	c.y = (p.y + (n * pc.y))/n1
	return c, n1
end

--- A value, _x_, between min and max inclusive.
-- @param x the value to clamp
-- @param min minimum allowed value
-- @param max maximum allowed value
-- @return clamped value
function _t.clamp(x, min, max)
	return math.min(math.max(x, min), max)
end

--- Linear interpolation between a and b.
-- @param a starting value
-- @param b ending value
-- @param t ratio between a and b
-- @return interpolated value between a and b
function _t.lerp(a, b, t)
	return a + ((b - a) * t)
end

--- Test if a bit is set.
-- @param bit the bit we are looking for
-- @param value the value we want to test
-- @return true when bit is set, false otherwise
function _t.isBitSet(bit, value)
	local bitval = (2^bit) * 2
	return (value % bitval) >= bit
end

--- Is a point inside a circle?
-- @param center The center of the circle, as a Vec2
-- @param radius The radius of the circle
-- @param point The point to test inside circle as a Vec2
-- @return True if point is inside the circle, false otherwise
function _t.isPointInCircle(center, radius, point)
	return dcsext.vector.distance(center, point) < radius
end

--- Returns a random Vec2 in circle of a given center and radius
-- @param center Center of the circle as a Vec2
-- @param maxRadius Radius of the circle
-- @param minRadius (optional) Minimum inner radius circle in which points
--        should not be spawned
-- @return A Vec2
function _t.randomPointInCircle(center, maxRadius, minRadius)
	minRadius = minRadius or 0
	local minr2 = minRadius^2
	local maxr2 = maxRadius^2
	local r = math.sqrt(math.random() * (maxr2 - minr2) + minr2)
	local theta = math.random() * 2 * math.pi
	local obj = { x = center.x + r * math.cos(theta),
		      y = center.y + r * math.sin(theta) }

	return dcsext.vector.Vec2(obj)
end

--- Round num to the nearest whole number.
-- @param num a floating point number
-- @return num rounded to whole number
function _t.round(num)
	return num + (2^52 + 2^51) - (2^52 + 2^51)
end

--- Converts a value to a boolean
-- @param val Value to convert
-- @return A boolean, nil is considered false
function _t.toBoolean(val)
	if val == nil or not val or val == 0 then
		return false
	end
	if type(val) == "string" then
		local v = val:lower()
		if v == "false" or v == "no" or v == "off" then
			return false
		end
	end
	return true
end

return _t
