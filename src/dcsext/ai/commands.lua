-- SPDX-License-Identifier: LGPL-3.0

--- DCS AI commands library. A set of helper functions to create
-- command tables which can be passed to Controller:setCommand().
--
-- Every public function returns two values: a DCS task table built
-- with the dcsext.ai.exec.createTaskTbl conventions, ready to be
-- passed to a Controller via Controller:setCommand(), and its
-- classification from dcsext.enum.TASKTYPE (COMMAND for en-route
-- commands or TASK for main tasks).

local enum  = require("dcsext.enum")
local check = require("dcsext.check")
local exec  = require("dcsext.ai.exec")

local _t = {}

--- Wraps an existing action or command table into a 'WrappedAction'
-- task so that raw DCS commands can be embedded in a waypoint task
-- list alongside regular tasks.
-- @param cmdtbl the action or command table to wrap
-- @return table the DCS task table for Controller:setCommand()
-- @return number dcsext.enum.TASKTYPE.TASK classification
function _t.wrappedCommand(cmdtbl)
	local params = {}
	params.action = cmdtbl
	return dcsext.ai.exec.createTaskTbl('WrappedAction', params),
		dcsext.enum.TASKTYPE.TASK
end

--- Activates a radio beacon. Passing nil for unit creates a global
-- beacon that is not tied to a specific unit.
-- @param unit the Unit owning the beacon, or nil for a global beacon
-- @param freq beacon frequency as a number
-- @param bcntype beacon type from dcsext.enum.BEACON.TYPE
-- @param system beacon system from dcsext.enum.BEACON.SYSTEM
-- @param callsign station callsign as a string
-- @param name (optional) beacon name as a string
-- @param extratbl (optional) table of extra command parameters
-- merged over the defaults
-- @return table the DCS task table for Controller:setCommand()
-- @return number dcsext.enum.TASKTYPE.COMMAND classification
function _t.activateBeacon(unit, freq, bcntype, system,
			   callsign, name, extratbl)
	assert(type(extratbl) == "table" or extratbl == nil,
		"value error: extratbl must be a table or nil.")
	extratbl = extratbl or {}
	local params = {
		["type"] = check.tblkey(bcntype, enum.BEACON.TYPE,
					"enum.BEACON.TYPE"),
		["system"] = check.tblkey(system, enum.BEACON.SYSTEM,
					  "enum.BEACON.SYSTEM"),
		["callsign"] = check.string(callsign),
		["frequency"] = check.number(freq),
	}

	if unit then
		params.unitId = unit:getID()
	end

	if name then
		params.name = check.string(name)
	end
	params = dcsext.table.merge(params, extratbl)
	return exec.createTaskTbl('ActivateBeacon', params),
		enum.TASKTYPE.COMMAND
end

--- Deactivates radio beacons.
-- @param bcntype (optional) value from dcsext.enum.BEACON.DEACTIVATE
-- selecting which beacons to switch off, defaults to ALL
-- @return table the DCS task table for Controller:setCommand()
-- @return number dcsext.enum.TASKTYPE.COMMAND classification
function _t.deactivateBeacon(bcntype)
	local bcn = bcntype or enum.BEACON.DEACTIVATE.ALL
	return exec.createTaskTbl(bcn), enum.TASKTYPE.COMMAND
end

--- Activates the Automatic Carrier Landing System for a unit.
-- @param unit the Unit to activate ACLS for
-- @param name airbase or carrier name as a string
-- @return table the DCS task table for Controller:setCommand()
-- @return number dcsext.enum.TASKTYPE.COMMAND classification
function _t.activateACLS(unit, name)
	local params = {}
	params.unitId = unit:getID()
	params.name   = name
	return exec.createTaskTbl('ActivateACLS', params),
		enum.TASKTYPE.COMMAND
end

--- Activates an ICLS glideslope beacon for a unit.
-- @param unit the Unit to activate ICLS for
-- @param chan ICLS channel as a number, validated in [1, 20]
-- @param name airbase or carrier name as a string
-- @return table the DCS task table for Controller:setCommand()
-- @return number dcsext.enum.TASKTYPE.COMMAND classification
function _t.activateICLS(unit, chan, name)
	local params = {}
	params.type    = enum.BEACON.TYPE.ICLS_GLIDESLOPE
	params.channel = check.range(chan, 1, 20)
	params.unitId  = unit:getID()
	params.name    = name

	return exec.createTaskTbl('ActivateICLS', params),
		enum.TASKTYPE.COMMAND
end

--- Activates a Link4 data link for a unit.
-- @param unit the Unit to activate Link4 for
-- @param freq Link4 frequency as a number
-- @param name airbase or carrier name as a string
-- @return table the DCS task table for Controller:setCommand()
-- @return number dcsext.enum.TASKTYPE.COMMAND classification
function _t.activateLink4(unit, freq, name)
	local params = {}
	params.unitId    = unit:getID()
	params.frequency = check.number(freq)
	params.name      = name

	return exec.createTaskTbl('ActivateLink4', params),
		enum.TASKTYPE.COMMAND
end

--- Convenience wrapper that builds a TACAN beacon through
-- activateBeacon(). The matching X/Y system variant is chosen
-- automatically from mode and the aa, bearing and mobile flags.
-- @param unit the Unit owning the beacon, or nil for a global beacon
-- @param callsign station callsign as a string
-- @param channel TACAN channel as a number
-- @param mode channel banding from dcsext.enum.BEACON.TACANMODE
-- (X or Y)
-- @param name (optional) beacon name as a string
-- @param aa true selects air-to-air TACAN systems
-- @param bearing true adds bearing support to the beacon
-- @param mobile true selects mobile ground TACAN systems
-- @return table the DCS task table for Controller:setCommand()
-- @return number dcsext.enum.TASKTYPE.COMMAND classification
function _t.createTACAN(unit, callsign, channel, mode,
			name, aa, bearing, mobile)
	local bcntype = enum.BEACON.TYPE.TACAN
	local system = enum.BEACON.SYSTEM.TACAN
	local freq = dcsext.tacan.frequency(channel, mode)
	local extra = {}

	extra.channel = channel
	extra.modeChannel = mode
	if aa then
		extra.AA = true
	end
	if bearing then
		extra.bearing = true
	end

	if aa and bearing then
		system = enum.BEACON.SYSTEM.TACAN_TANKER_MODE_X
		if mode == enum.BEACON.TACANMODE.Y then
			system = enum.BEACON.SYSTEM.TACAN_TANKER_MODE_Y
		end
	elseif aa then
		system = enum.BEACON.SYSTEM.TACAN_AA_MODE_X
		if mode == enum.BEACON.TACANMODE.Y then
			system = enum.BEACON.SYSTEM.TACAN_AA_MODE_Y
		end
	elseif mobile then
		system = enum.BEACON.SYSTEM.TACAN_MOBILE_MODE_X
		if mode == enum.BEACON.TACANMODE.Y then
			system = enum.BEACON.SYSTEM.TACAN_MOBILE_MODE_Y
		end
	end

	return _t.activateBeacon(unit, freq, bcntype, system,
		callsign, name, extra)
end

--- Toggles the EPLRS datalink for the controlled group.
-- @param enable true to enable EPLRS, false to disable it
-- @return table the DCS task table for Controller:setCommand()
-- @return number dcsext.enum.TASKTYPE.COMMAND classification
function _t.eplrs(enable)
	local task = exec.createTaskTbl('EPLRS')
	task.params.value = check.bool(enable)
	return task, enum.TASKTYPE.COMMAND
end

--- Runs Lua source code as a Script command. The source is compiled
-- up front, so syntactically invalid scripts are rejected
-- immediately.
-- @param scriptstring Lua source code to run as a string
-- @return table the DCS task table for Controller:setCommand()
-- @return number dcsext.enum.TASKTYPE.COMMAND classification
function _t.script(scriptstring)
	assert(loadstring(scriptstring))
	local task = exec.createTaskTbl('Script')
	task.params.command = scriptstring
	return task, enum.TASKTYPE.COMMAND
end

--- Sets the callsign of the controlled group.
-- @param callname callsign identifier as a number in [1, 20]
-- @param num callsign number as a number in [1, 9]
-- @return table the DCS task table for Controller:setCommand()
-- @return number dcsext.enum.TASKTYPE.COMMAND classification
function _t.setCallsign(callname, num)
	local params = {
		["callname"] = check.range(callname, 1, 20),
		["number"]   = check.range(num, 1, 9),
	}
	return exec.createTaskTbl('SetCallsign', params),
		enum.TASKTYPE.COMMAND
end

--- Sets the radio frequency of the controlled group.
-- @param freq radio frequency as a number
-- @param mod modulation from radio.modulation, defaults to AM
-- @param pow transmitter power as a number, defaults to 10
-- @return table the DCS task table for Controller:setCommand()
-- @return number dcsext.enum.TASKTYPE.COMMAND classification
function _t.setFrequency(freq, mod, pow)
	mod = mod or radio.modulation.AM
	pow = pow or 10

	local params = {
		frequency  = check.number(freq),
		modulation = check.tblkey(mod, radio.modulation,
					  "radio.modulation"),
		power      = check.number(pow),
	}
	return exec.createTaskTbl('SetFrequency', params),
		enum.TASKTYPE.COMMAND
end

--- Makes the controlled group immortal.
-- @param enable true to make the group immortal, false otherwise
-- @return table the DCS task table for Controller:setCommand()
-- @return number dcsext.enum.TASKTYPE.COMMAND classification
function _t.setImmortal(enable)
	local task = exec.createTaskTbl('SetImmortal')
	task.params.value = check.bool(enable)
	return task, enum.TASKTYPE.COMMAND
end

--- Makes the controlled group invisible to AI detection.
-- @param enable true to make the group invisible, false otherwise
-- @return table the DCS task table for Controller:setCommand()
-- @return number dcsext.enum.TASKTYPE.COMMAND classification
function _t.setInvisible(enable)
	local task = exec.createTaskTbl('SetInvisible')
	task.params.value = check.bool(enable)
	return task, enum.TASKTYPE.COMMAND
end

--- Starts the engines of the controlled group.
-- @return table the DCS task table for Controller:setCommand()
-- @return number dcsext.enum.TASKTYPE.COMMAND classification
function _t.start()
	return exec.createTaskTbl('Start'), enum.TASKTYPE.COMMAND
end

--- Stops or resumes route following for the controlled group.
-- @param enable true to stop route following, false to resume it
-- @return table the DCS task table for Controller:setCommand()
-- @return number dcsext.enum.TASKTYPE.COMMAND classification
function _t.stopRoute(enable)
	local task = exec.createTaskTbl('StopRoute')
	task.params.value = check.bool(enable)
	return task, enum.TASKTYPE.COMMAND
end

--- Stops any active radio transmission of the controlled group.
-- @return table the DCS task table for Controller:setCommand()
-- @return number dcsext.enum.TASKTYPE.COMMAND classification
function _t.stopTransmission()
	return exec.createTaskTbl('StopTransmission'), enum.TASKTYPE.COMMAND
end

--- Transmits an audio file over the radio, optionally repeating it
-- and showing a subtitle.
-- @param file path of the audio file to transmit as a string
-- @param duration (optional) transmission length in seconds as a
-- number
-- @param loop (optional) true to repeat the transmission until
-- stopped
-- @param subtitle (optional) subtitle text shown during the
-- transmission as a string
-- @return table the DCS task table for Controller:setCommand()
-- @return number dcsext.enum.TASKTYPE.COMMAND classification
function _t.startTransmission(file, duration, loop, subtitle)
	check.string(file)
	assert(type(duration) == "number" or duration == nil,
		"value error: [optional] duration must be a number.")
	assert(type(loop) == "boolean" or loop == nil,
		"value error: [optional] loop must be a boolean.")
	assert(type(subtitle) == "string" or subtitle == nil,
		"value error: [optional] subtitle must be a string.")
	loop = loop or false
	local params = {
		["duration"] = duration,
		["subtitle"] = subtitle,
		["loop"]     = loop,
		["file"]     = file,
	}
	return exec.createTaskTbl('TransmitMessage', params),
		enum.TASKTYPE.COMMAND
end

return _t
