--[[
-- SPDX-License-Identifier: LGPL-3.0
--]]

local utils = require("libs.utils")
local class = require("libs.classnamed")

local curveTypes = {
	["LINEAR"]    = 1,
	["QUADRATIC"] = 2,
	["LOGISTIC"]  = 3,
}

local function linear(self, x)
	x = utils.clamp(x, 0, 1)
	local y = self.m * ((x - self.c) ^ self.k) + self.b
	return utils.clamp(y, 0, 1)
end

local function logistic(self, x)
	x = utils.clamp(x, 0, 1)
	local e = 1000 * math.exp(1) * self.m ^ (-1 * x + self.c)
	local y = (self.k / (1 + e)) + self.b
	return utils.clamp(y, 0, 1)
end

--- @class Axis
-- Describes a response curve with a clamped input range of [0,1] and
-- a clamped output of [0,1].
local Axis = class("Axis")
function Axis:__init(input, curve, m, k, b, c)
	self.inputfunc = input
	self.curvetype = curve
	self.m = m
	self.k = k
	self.b = b
	self.c = c

	if self.curvetype == curveTypes.LINEAR or
	   self.curvetype == curveTypes.QUADRATIC then
		self.calc = linear
	elseif self.curvetype == curveTypes.LOGICTIC then
		self.calc = logistic
	end
end

--- @class IAUS
-- Infinite Axis Utility System (IAUS). Describes a set of axes used to
-- generate a utility score.
local IAUS = class("IAUS")
function IAUS:__init(...)
	self.axes = {}
	for _, a in ipairs({select(1, ...)}) do
		table.insert(self.axes, a)
	end
end

--- Add an axis to the utility system.
function IAUS:addAxis(axis)
	table.insert(self.axes, axis)
end

--- Score the utility for a given agent.
function IAUS:score(agent)
	local score = 1

	for _, axis in ipairs(self.axes) do
		local x = axis.inputfunc(agent)
		score = score * axis:calc(x)
	end
	return score
end

local _t = {}
_t.curveTypes = curveTypes
_t.Axis = Axis
_t.IAUS = IAUS

return _t
