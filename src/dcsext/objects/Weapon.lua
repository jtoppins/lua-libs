-- SPDX-License-Identifier: LGPL-3.0

local class     = require("dcsext.class")
local vector    = require("dcsext.vector")

local warheadtypes = {
	[Weapon.WarheadType.AP] = "mass",
	[Weapon.WarheadType.HE] = "explosiveMass",
	[Weapon.WarheadType.SHAPED_EXPLOSIVE] = "shapedExplosiveMass",
}

-- TODO: move this to another module
local function trimTypeName(typename)
        if typename ~= nil then
                return string.match(typename, "[^.]-$")
        end
end

--- Weapon.
-- Is a representation of a DCS Weapon object.
-- @classmod Weapon
local Weapon = class("Weapon")

--- Constructor.
function Weapon:__init(wpn, initiator, timeout)
	self.start_time  = timer.getTime()
	self.timeout     = false
	self.lifetime    = timeout -- weapons only "live" for timeout seconds
	self.weapon      = wpn
	self.type        = trimTypeName(wpn:getTypeName())
	self.shootername = initiator:getName()
	self.desc        = wpn:getDesc()
	self.power       = self:getWarheadPower()
	self.impactpt    = nil

	self:update(self.start_time, .5)
end

--- Does the DCS weapon object still exist in the game world?
-- A Weapon is considered to 'exist' if it has not taken too long to
-- impact something and the DCS Weapon object still exists.
-- @treturn bool true if the weapon still exists.
function Weapon:exist()
	return self.weapon:isExist() and not self.timeout
end

--- @treturn bool true if the Weapon is believed to have impacted something.
function Weapon:hasImpacted()
	return self.impactpt ~= nil
end

--- Provides the DCS Weapon description table.
-- @treturn table Weapon description.
function Weapon:getDesc()
	return self.desc
end

--- Gets the warhead's explosive power.
-- @treturn number the mass of the explosive used in the warhead.
function Weapon:getWarheadPower()
	return self.desc.warhead[warheadtypes[self.desc.warhead.type]]
end

--- Get the impact point. This is the point where the weapon is predicted
-- to intersect with the ground or was deleted by the game.
-- @treturn Vec3 impact point or nil if the weapon has not impacted yet
function Weapon:getImpactPoint()
	return self.impactpt
end

--- Update the weapon's state.
-- @tparam number time current game time step
-- @tparam number lookahead seconds to predict the weapon's future
--         position
function Weapon:update(time, lookahead)
	dcsext.check.number(time)

	if not self:exist() then
		return
	end

	local pos = self.weapon:getPosition()

	if time - self.start_time > self.lifetime then
		self.timeout = true
	end

	self.pos  = vector.Vec3(pos.p)
	self.dir  = vector.Vec3(pos.x)
	self.vel  = vector.Vec3(self.weapon:getVelocity())

	-- search lookahead seconds into the future
	self.impactpt = land.getIP(self.pos:get(),
	                           self.dir:get(),
	                           self.vel:magnitude() * lookahead)
end

return Weapon
