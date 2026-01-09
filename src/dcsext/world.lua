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
