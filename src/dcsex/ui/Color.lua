-- SPDX-License-Identifier: LGPL-3.0

local class  = require("dcsex.class")
local mymath = require("dcsex.math")
local overrideOps = require("dcsex.overrideOps")

local function setColor(_, _, new, old)
	local v = tonumber(new)

	if v == nil then
		return old
	end
	return mymath.clamp(v, 0, 1)
end

local colormt = {}
function colormt.__eq(self, other)
	return self.red == other.red and self.green == other.green and
		self.blue == other.blue and self.alpha == other.alpha
end

--- Color class, represents a DCS color table.
-- @classmod dcsex.ui.Color
local Color = overrideOps(class("Color"), colormt)

--- Copy constructor.
-- @param obj the object to copy color information from.
function Color:__init(obj)
	self:_property("red",   0, setColor)
	self:_property("green", 0, setColor)
	self:_property("blue",  0, setColor)
	self:_property("alpha", 0, setColor)

	if obj == nil then obj = {} end

	self.red   = obj.red   or obj[1]
	self.green = obj.green or obj[2]
	self.blue  = obj.blue  or obj[3]
	self.alpha = obj.alpha or obj[4]

	self.colors = nil
	self.new = nil
end

--- Constructor.
-- @param red decimal number from 0 to 1
-- @param green decimal number from 0 to 1
-- @param blue decimal number from 0 to 1
-- @param alpha decimal number from 0 to 1
function Color.new(red, green, blue, alpha)
	return Color({
		["red"]   = red,
		["green"] = green,
		["blue"]  = blue,
		["alpha"] = alpha,
	})
end

--- Get the color formatted in DCS color RGBA format.
-- @param alpha optionally set the alpha channel to `alpha` otherwise
--    the alpha channel will be whatever was originally set.
function Color:get(alpha)
	if alpha ~= nil then
		alpha = mymath.clamp(tonumber(alpha), 0, 1)
	end

	return {self.red, self.green, self.blue, alpha or self.alpha}
end

--- List of common colors
-- The list has to be the last thing in the file otherwise not all
-- methods will be applied.
Color.colors = {
	["BLACK"]  = Color({0,0,0,1}),
	["GRAY"]   = Color({128/255, 128/255, 128/255, 1}),
	["RED"]    = Color({1,0,0,1}),
	["GREEN"]  = Color({0,1,0,1}),
	["BLUE"]   = Color({0,0,1,1}),
	["BLUFOR"] = Color({0, 73/255, 144/255, 1}),
	["REDFOR"] = Color({204/255, 0, 0, 1}),
}

return Color
