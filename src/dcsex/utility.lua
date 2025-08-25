-- SPDX-License-Identifier: LGPL-3.0

--- Utility - describes an extensible utility system

local class = require("dcsex.class")

local curveTypes = {
	["LINEAR"]    = 1,
	["QUADRATIC"] = 2,
	["LOGISTIC"]  = 3,
}

--- Linear response curve described by the values set the in Axis
-- class.
-- @param self reference to an Axis instance
-- @param x a number
-- @return a float clamped between the values 0 and 1 inclusive
local function linear(self, x)
	x = dcsex.math.clamp(x, 0, 1)
	local y = self.m * ((x - self.c) ^ self.k) + self.b
	return dcsex.math.clamp(y, 0, 1)
end

--- Logistic response curve described by the values set the in Axis
-- class.
-- @param self reference to an Axis instance
-- @param x a number
-- @return a float clamped between the values 0 and 1 inclusive
local function logistic(self, x)
	x = dcsex.math.clamp(x, 0, 1)
	local e = 1000 * math.exp(1) * self.m ^ (-1 * x + self.c)
	local y = (self.k / (1 + e)) + self.b
	return dcsex.math.clamp(y, 0, 1)
end

--- Describes a response curve with a clamped input range of [0,1]
-- and a clamped output of [0,1].
local Axis = class("Axis")

--- Constructor.
-- @param input a function reference where the signature is of the
--    form: value input(object), thus input known how to obtain
--    some value from object.
-- @param curve on of enum dcsex.utility.curveTypes
-- @param m response curve coefficent
-- @param k response curve coefficent
-- @param b response curve coefficent
-- @param c response curve coefficent
function Axis:__init(input, curve, m, k, b, c)
	self.inputfunc = dcsex.check.func(input)
	self.curvetype = dcsex.check.tblkey(curve, curveTypes, "curveTypes")
	self.m = m or 1
	self.k = k or 1
	self.b = b or 1
	self.c = c or 1

	if self.curvetype == curveTypes.LINEAR or
	   self.curvetype == curveTypes.QUADRATIC then
		self.calc = linear
	elseif self.curvetype == curveTypes.LOGISTIC then
		self.calc = logistic
	end
end

--- Score the axis.
-- @param agent object passed to inputfunc to determine the X value.
-- @return returns the Y value or result of the Axis
function Axis:score(agent)
	return self:calc(self.inputfunc(agent))
end

--- Infinite Axis Utility System (IAUS). Describes a set of axes used
-- to generate a utility score.
local IAUS = class("IAUS")

--- Constructor.
-- @param ... varadioc param list of the Axis classes
function IAUS:__init(...)
	self.axes = {}
	for _, a in ipairs({select(1, ...)}) do
		table.insert(self.axes, a)
	end
end

--- Add an axis to the utility system.
-- @param axis an Axis reference
function IAUS:addAxis(axis)
	table.insert(self.axes, axis)
end

--- Score the utility for a given agent.
-- @param agent the game object each Axis' input function can query
--    to obtain its 'x' input value.
-- @return a utility score between 0 and 1
function IAUS:score(agent)
	local score = 1

	for _, axis in ipairs(self.axes) do
		score = score * axis:score(agent)
	end
	return score
end

-- export public functions
local _t = {}
_t.curveTypes = curveTypes
_t.Axis = Axis
_t.IAUS = IAUS

return _t
