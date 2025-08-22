-- SPDX-License-Identifier: LGPL-3.0

--- functions/classes to manipulate the game environment

local myos    = require("os")
local Logger  = require("dcsex.env.Logger")

local _t = {}

--- Run a lua script block in a different context.
-- @param ctx the context to run `cmd` in
-- @param cmd the lua string to run in `ctx`
-- @param valtype the type of return value
-- @return nil on error otherwise data in the requested type
function _t.doRPC(ctx, cmd, valtype)
	local logger = Logger.getByName("DCSEX")
	local status, errmsg =
		net.dostring_in(ctx, string.format("%q", cmd))

	if not status then
		logger:error("rpc failed in context(%s): %s", ctx, errmsg)
		return
	end

	local val
	if valtype == "number" then
		val = tonumber(status)
	elseif valtype == "boolean" then
		val = dcsex.math.toBoolean(status)
	elseif valtype == "string" then
		val = status
	elseif valtype == "table" then
		local rc, result = pcall(net.json2lua, status)
		if not rc then
			logger:error("rpc json decode failed: %s",
				     tostring(result))
			logger:debug("rpc json decode input: %s",
				     tostring(status))
			val = nil
		else
			val = result
		end
	else
		logger:error("rpc unsupported type(%s)", valtype)
		val = nil
	end
	return val
end

--- Print a stack trace in a well known format, so users know what
-- to copy when reporting errors.
-- @param err error object.
-- @param version version string to output with the stack track.
-- @param lvl level in the call stack to start the traceback or zero.
-- @return string containing the stack trace
function _t.errtraceback(err, version, lvl)
	lvl = lvl or 0
	version = version or ""
	return "\n---[ cut here ]---\n"..
	       string.format("ERROR %s: ", version)..
	       debug.traceback(err, lvl+1)..
	       "\n---[ end trace ]---"
end

--- Logs an error message as a result of a failed pcall context.
-- @param err error object.
-- @param logger a dcsex.env.Logger object to print the trackback to.
-- @param lvl level in the call stack to start the traceback or one.
function _t.errhandler(err, logger, lvl)
	local str = _t.errtraceback(err, lvl or 1)
	logger:error("%s", str)
end

--- Return the start time of the mission converted to seconds.
-- Calling ex.env.getStartTime() + timer.getAbsTime() is an
-- easy way to get the current local time of the map.
-- @param miztbl a mission table entry or env for the currently
--   loaded mission
-- @return number in seconds since the OS epoch
function _t.getStartTime(miztbl)
	miztbl = miztbl or env
	return myos.time(miztbl.mission.date) +	miztbl.mission.start_time
end

--- Get the rough timezone offset.
-- @param abstime local time in seconds
-- @return utc time in seconds
function _t.getZuluTime(abstime)
	--[[ Alternative way to get a rough offset
	local utcOffset = Terrain.GetTerrainConfig("SummerTimeDelta") * 3600
	--]]
	local _, longitude = coord.LOtoLL({x = 0, y = 0, z = 0})
	local utcOffset = math.floor(longitude / 15) * 60 * 60

	return abstime - utcOffset
end

-- expose os.date and os.time functions to the mission environment.
_t.date = myos.date
_t.time = myos.time

--- Load a new mission file.
-- @param fileName Mission filename
function _t.loadMission(fileName)
	local cmd = [[
	a_load_mission("]]..tostring(fileName)..[[")
	]]

	_t.doRPC("mission", cmd, "boolean")
end

_t.Logger = Logger

--- Set the mission briefing for a coalition.
-- @param coaID number
-- @param briefingText string Briefing text, can contain newlines, will be
--    converted formatted properly for DCS
-- @param imagePath string file path, can be a file in the DEFAULT folder
--    inside the .miz
function _t.setBriefing(coaID, briefingText, imagePath)
	local coaName = dcsex.world.getCoalitionString(coaID)
	briefingText = briefingText or ""
	imagePath = imagePath or ""
	local paramstr = string.format("\"%s\", \"%s\", \"%q\"",
					coaName, imagePath, briefingText)
	local cmd = [[
	a_set_brieding(]]..tostring(paramstr)..[[)
	]]

	_t.doRPC("mission", cmd, "boolean")
end

_t.Mission = require("dcsex.env.Mission")
_t.terrain = require("dcsex.env.terrain")
_t.Zone    = require("dcsex.env.Zone")

return _t
