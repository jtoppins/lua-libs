-- SPDX-License-Identifier: LGPL-3.0

--- DCS AI commands library. A set of helper functions to create
-- command tables which can be passed to Controller:setCommand().

local enum  = require("dcsex.enum")
local check = require("dcsex.check")
local exec  = require("dcsex.ai.exec")

local _t = {}

function _t.wrappedCommand(cmdtbl)
	local params = {}
	params.action = cmdtbl
	return dcsex.ai.exec.createTaskTbl('WrappedAction', params),
		dcsex.enum.TASKTYPE.TASK
end

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
	params = dcsex.table.merge(params, extratbl)
	return exec.createTaskTbl('ActivateBeacon', params),
		enum.TASKTYPE.COMMAND
end

function _t.deactivateBeacon(bcntype)
	local bcn = bcntype or enum.BEACON.DEACTIVATE.ALL
	return exec.createTaskTbl(bcn), enum.TASKTYPE.COMMAND
end

function _t.activateACLS(unit, name)
	local params = {}
	params.unitId = unit:getID()
	params.name   = name
	return exec.createTaskTbl('ActivateACLS', params),
		enum.TASKTYPE.COMMAND
end

function _t.activateICLS(unit, chan, name)
	local params = {}
	params.type    = enum.BEACON.TYPE.ICLS_GLIDESLOPE
	params.channel = check.range(chan, 1, 20)
	params.unitId  = unit:getID()
	params.name    = name

	return exec.createTaskTbl('ActivateICLS', params),
		enum.TASKTYPE.COMMAND
end

function _t.activateLink4(unit, freq, name)
	local params = {}
	params.unitId    = unit:getID()
	params.frequency = check.number(freq)
	params.name      = name

	return exec.createTaskTbl('ActivateLink4', params),
		enum.TASKTYPE.COMMAND
end

function _t.createTACAN(unit, callsign, channel, mode,
			name, aa, bearing, mobile)
	local bcntype = enum.BEACON.TYPE.TACAN
	local system = enum.BEACON.SYSTEM.TACAN
	local freq = dct.ai.Tacan.getFrequency(channel, mode)
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

function _t.eplrs(enable)
	local task = exec.createTaskTbl('EPLRS')
	task.params.value = check.bool(enable)
	return task, enum.TASKTYPE.COMMAND
end

function _t.script(scriptstring)
	assert(loadstring(scriptstring))
	local task = exec.createTaskTbl('Script')
	task.params.command = scriptstring
	return task, enum.TASKTYPE.COMMAND
end

function _t.setCallsign(callname, num)
	local params = {
		["callname"] = check.range(callname, 1, 20),
		["number"]   = check.range(num, 1, 9),
	}
	return exec.createTaskTbl('SetCallsign', params),
		enum.TASKTYPE.COMMAND
end

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

function _t.setImmortal(enable)
	local task = exec.createTaskTbl('SetImmortal')
	task.params.value = check.bool(enable)
	return task, enum.TASKTYPE.COMMAND
end

function _t.setInvisible(enable)
	local task = exec.createTaskTbl('SetInvisible')
	task.params.value = check.bool(enable)
	return task, enum.TASKTYPE.COMMAND
end

function _t.start()
	return exec.createTaskTbl('Start'), enum.TASKTYPE.COMMAND
end

function _t.stopRoute(enable)
	local task = exec.createTaskTbl('StopRoute')
	task.params.value = check.bool(enable)
	return task, enum.TASKTYPE.COMMAND
end

function _t.stopTransmission()
	return exec.createTaskTbl('StopTransmission'), enum.TASKTYPE.COMMAND
end

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
