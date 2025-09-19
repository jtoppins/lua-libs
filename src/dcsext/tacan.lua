-- SPDX-License-Identifier: LGPL-3.0

local check = require("dcsext.check")
local enum = require("dcsext.enum")
local MHZ = 1000 * 1000
local tacan = {}

--- Provide a couple of TACAN related functions.

--- Determine the TACAN frequency for the given channel and mode.
-- @param chan the TACAN channel
-- @param mode the TACAN mode
-- @return frequency in hertz
function tacan.frequency(chan, mode)
	local base
	chan = check.range(chan, enum.TACAN.CHANNEL.MIN,
			   enum.TACAN.CHANNEL.MAX)
	check.tblkey(mode, enum.BEACON.TACANMODE, "BEACON.TACANMODE")

	if chan < enum.TACAN.GND.BASE_INV then
		if mode == enum.BEACON.TACANMODE.X then
			base = enum.TACAN.GND.BASE_X
		elseif mode == enum.BEACON.TACANMODE.Y then
			base = enum.TACAN.GND.BASE_Y
		end
	else
		-- starting from channel 64, X and Y bases are swapped
		if mode == enum.BEACON.TACANMODE.X then
			base = enum.TACAN.GND.BASE_Y
		elseif mode == enum.BEACON.TACANMODE.Y then
			base = enum.TACAN.GND.BASE_X
		end
	end

	return (chan + base) * MHZ
end

--- Decode a TACAN channel description string of the form:
--    [channel][mode] [callsign]
--
-- @param desc the channel description string
-- @return table
function tacan.decode(desc)
	local chan, mode = string.match(desc, "^(%d+)(%a)")
	local callsign = string.match(desc, "^%d+%a%s+(%w.+)$")

	if chan then
		chan = tonumber(chan)
	end

	if mode then
		mode = mode:upper()
	end

	local valid = enum.BEACON.TACANMODE[mode] ~= nil and
		      chan >= enum.TACAN.CHANNEL.MIN and
		      chan <= enum.TACAN.CHANNEL.MAX

	if not valid then
		return nil
	end

	return {
		["channel"]   = chan,
		["mode"]      = mode,
		["callsign"]  = callsign,
		["frequency"] = tacan.frequency(chan, mode)
	}
end

return tacan
