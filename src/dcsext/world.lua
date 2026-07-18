-- SPDX-License-Identifier: LGPL-3.0

--- World - functions related to the game world.
-- All the functions in this module take a DCS
-- object instance.

local mytable = require("dcsext.table")
local MARKID_START = 500
local curMarkID    = MARKID_START

local _t = {}

--- enemy map.
local enemymap = {
	[coalition.side.NEUTRAL] = false,
	[coalition.side.BLUE]    = coalition.side.RED,
	[coalition.side.RED]     = coalition.side.BLUE,
}

--- Get the enemy of `side`.
-- @param side coalition we want the enemy of
-- @return enemy coalition id from `coalition.side` table.
function _t.getCoalitionEnemy(side)
	return enemymap[side]
end

--- Returns the name of the coalition, as a lowercase string.
-- @param coaID coalition ID
-- @return string or nil if invalid coaID provided
function _t.getCoalitionString(coaID)
	local key = mytable.getKey(coalition.side, coaID)

	if key ~= nil then
		return key:lower()
	end
	return nil
end

--- Return the last map marker ID generated.
-- @return number or nil
function _t.getCurrentMarkID()
	if curMarkID <= MARKID_START then
		return nil
	end
	return curMarkID
end

--- Generate the next marker ID.
-- @return number
function _t.getNextMarkID()
	curMarkID = curMarkID + 1
	return curMarkID
end

--- Are `side1` and `side2` enemies?
-- @return true means `side1` and `side2` are enemies
function _t.isEnemy(side1, side2)
	if side1 == side2 then
		return false
	end
	if _t.getCoalitionEnemy(side1) ~= side2 then
		return false
	end
	return true
end

--- Notify all of DCS of a custom event.
-- @param eventdata Event data.
function _t.notify(eventdata)
	world.onEvent(eventdata)
end

--- Spawn a template.
-- @param tpl template table having members countryid, category, and data
-- @return a reference to the spawned object or nil if unsuccessful
function _t.spawn(tpl)
	local obj

	if tpl.category == Unit.Category.STRUCTURE then
		obj = coalition.addStaticObject(tpl.countryid, tpl.data)
	else
		obj = coalition.addGroup(tpl.countryid, tpl.category, tpl.data)
	end
	return obj
end

_t.unit = {}

--- Is `unit` controlled by a player?
-- @param unit DCS Unit instance
-- return true if the unit is controlled by a player
function _t.unit.isPlayer(unit)
	return (unit ~= nil and unit:getPlayerName() ~= nil)
end

--- Trigger an explosion on `unit`.
-- @param unit DCS Unit instance
-- @param amount power factor of the explosion
function _t.unit.explode(unit, amount)
	local cmd = [[
	a_explosion_unit(%d, %f)
	return true
	]]

	dcsext.env.doRPC("mission",
			string.format(cmd, unit:getID(), amount),
			"boolean")
end

--- Return the life remaining of a unit normalized between zero and
-- one.
-- @param unit DCS Unit instance
-- return normalized health of unit
function _t.unit.getLifeNormalized(unit)
	if unit == nil then
		return 0
	end

	local life0 = unit:getLife0() or 1
	return dcsext.math.clamp(unit:getLife() / life0, 0, 1)
end

--- Set the carrier illumination mode.
-- @param unit DCS Unit instance
-- @param mode one of the values from table ex.enum.CARRIER_ILLUM_MODE
function _t.unit.setCarrierIllumination(unit, mode)
	local cmd = [[
	a_set_carrier_illumination_mode(%d, %d)
	return true
	]]

	dcsext.env.doRPC("mission",
			string.format(cmd, unit:getID(), mode),
			"boolean")
end

--- Set the life of the unit.
-- @param unit DCS Unit instance
-- @param life normalized float
function _t.unit.setLife(unit, life)
	life = dcsext.math.clamp(life, 0, 1)
	local cmd = [[
	a_unit_set_life_percentage(%d, %f)
	return true
	]]

	dcsext.env.doRPC("mission",
			string.format(cmd, unit:getID(), life),
			"boolean")
end

--- Heading is the angle between the x and z components of the nose position
-- vector.
-- @param unitpos the table of vectors returned by Unit:getPosition()
-- @return number in radians [0, 2*pi] relative to true north.
function _t.unit.getHeading(unitpos)
	local heading = math.atan2(unitpos.x.z, unitpos.x.x)

	if heading < 0 then
		heading = heading + 2 * math.pi
	end
	return heading
end

--- Pitch is the angle between the horizon and the nose position vector.
-- @param unitpos the table of vectors returned by Unit:getPosition()
-- @return number in radians [-pi/2, pi/2].
function _t.unit.getPitch(unitpos)
	return math.asin(unitpos.x.y)
end

--- Calculate the roll angle of the object.
-- First, find a normal to y-axis and unitpos.x. Next, get the angle
-- between vectors normal and unitpos.z.
-- @param unitpos the table of vectors returned by Unit:getPosition()
-- @return number in radians [-pi, pi]. Right roll positive.
function _t.unit.getRoll(unitpos)
	local Y = dcsext.vector.Vec3.new(0, 1, 0)
	local normal = dcsext.vector.Vec3(unitpos.x) ^ Y
	local roll = dcsext.vector.angle(dcsext.vector.Vec3(unitpos.z), normal)

	-- For right roll, y component is negative.
	if unitpos.z.y > 0 then
		roll = -roll
	end
	return roll
end

--- Yaw is the angle between unitpos.x and the x and z axial velocities.
-- @param unitpos the table of vectors returned by Unit:getPosition()
-- @param unitvel the vector returned by Unit:getVelocity()
-- @return number in radians [-pi, pi], right yaw is positive
function _t.unit.getYaw(unitpos, unitvel)
	unitvel = dcsext.vector.Vec3(unitvel)

	if unitvel:magnitude() == 0 then
		return 0
	end

	local X = dcsext.vector.Vec3.new(1, 0, 0)
	local axialvel = {}

	-- transform velocity components in direction of aircraft axes.
	axialvel.x = dcsext.vector.dot(dcsext.vector.Vec3(unitpos.x), unitvel)
	axialvel.z = dcsext.vector.dot(dcsext.vector.Vec3(unitpos.z), unitvel)

	local AxialXZ = dcsext.vector.Vec3.new(axialvel.x, 0, axialvel.z)
	local yaw = dcsext.vector.angle(X, AxialXZ)

	if axialvel.z > 0 then
		yaw = -yaw
	end
	return yaw
end

--- AoA is angle between unitpos.x and the x and y velocities.
-- @param unitpos the table of vectors returned by Unit:getPosition()
-- @param unitvel the vector returned by Unit:getVelocity()
-- @return number in radians [-pi, pi]
function _t.unit.getAoA(unitpos, unitvel)
	unitvel = dcsext.vector.Vec3(unitvel)

	if unitvel:magnitude() == 0 then
		return 0
	end

	local X = dcsext.vector.Vec3.new(1, 0, 0)
	local axialvel = {}

	-- transform velocity components in direction of aircraft axes.
	axialvel.x = dcsext.vector.dot(dcsext.vector.Vec3(unitpos.x), unitvel)
	axialvel.y = dcsext.vector.dot(dcsext.vector.Vec3(unitpos.y), unitvel)

	local AxialXY = dcsext.vector.Vec3.new(axialvel.x, axialvel.y, 0)
	local aoa = dcsext.vector.angle(X, AxialXY)

	if axialvel.y > 0 then
		aoa = -aoa
	end
	return aoa
end

--- Climb angle is simply the angle formed by the components of the velocity
-- vector.
-- @param unitvel the vector returned by Unit:getVelocity()
-- @return number in radians [-pi/2, pi/2], positive nose up
function _t.unit.getClimbAngle(unitvel)
	unitvel = dcsext.vector.Vec3(unitvel)
	local mag = unitvel:magnitude()

	if mag == 0 then
		return 0
	end

	return math.asin(unitvel.y / mag)
end

--- Equations derived from:
-- https://aviation.stackexchange.com/questions/64735/
--  how-to-calculate-equivalent-airspeed-immediately-from-calibrated-airspeed
-- -and-
-- https://en.wikipedia.org/wiki/Equivalent_airspeed
local R_gas = 287.05 -- units: J/K/Kg
local rho0  = 1.225 -- units: Kg / m^3
local a0    = 340.2778 -- units: meters per sec
local P0    = 101325 -- units: Pascals (Pa)

--- Calculate the local mach number for a given calibrated airspeed (CAS)
-- and static pressure at the altitude desired.
-- @param cas desired calibrated airspeed
-- @param ps static pressure
function _t.unit.getMach(cas, ps)
	local q = (((cas / a0)^2 / 5) + 1)^3.5 - 1
	local M = math.sqrt(5 * (((q / ps) + 1)^(2/7) - 1))
	return M
end

--- Calculate the equivalent airspeed (EAS) and static pressure at the
-- altitude desired.
-- @param cas desired calibrated airspeed
-- @param ps static pressure
function _t.unit.getEAS(cas, ps)
	local mach = _t.unit.getMach(cas, ps)
	local eas = a0 * mach * math.sqrt(ps / P0)
	return eas
end

--- Calculate the ground speed for an aircraft given the desired
-- calibrated airspeed (CAS) along a path defined by two points. This will
-- take into account wind along the path. It is assumed CAS is equivalent
-- to indicated airspeed (IAS).
-- @param cas desired calibrated airspeed
-- @param pointA start point
-- @param pointB end point
function _t.unit.CAStoGS(cas, pointA, pointB)
	local temp, pressure, windvel, midpoint, rho, tas, gs, eas

	pointA = dcsext.vector.Vec3(pointA)
	pointB = dcsext.vector.Vec3(pointB)
	midpoint = (pointA + pointB) / 2
	windvel = atmosphere.getWind(midpoint:get())
	temp, pressure = atmosphere.getTemperatureAndPressure(midpoint:get())
	rho = pressure / (R_gas * temp)

	eas = _t.unit.getEAS(cas, pressure)
	tas = eas / math.sqrt(rho / rho0)
	tas = tas * dcsext.vector.unitvec(pointB - pointA)
	gs = tas + windvel

	return gs:magnitude()
end

_t.group = {}

--- Is `grp` alive according to DCS?
-- A more refined but heavier version of this function is to
-- check that there exists at least one unit with a life value
-- greater than or equal to one.
-- @param grp a DCS Group instance
-- @return true the group is alive
function _t.group.isAlive(grp)
	return (grp ~= nil and grp:isExist() and grp:getSize() > 0)
end

--- Does `grp` have at least one player unit in the group?
-- @param grp a DCS Group instance
-- @return true if at least one unit in the group is a player
function _t.group.isPlayer(grp)
	if grp == nil then
		return false
	end

	for _, u in pairs(grp:getUnits()) do
		if _t.unit.isPlayer(u) then
			return true
		end
	end
	return false
end

return _t
