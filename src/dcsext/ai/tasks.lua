-- SPDX-License-Identifier: LGPL-3.0

--- DCS AI tasks. Provides helper functions to create task tables
-- that can be passed to Controller:setTask().

local enum   = require("dcsext.enum")
local check  = require("dcsext.check")
local vector = require("dcsext.vector")
local exec   = require("dcsext.ai.exec")

local optionalParams = {
	["weaponType"]  = function(params, op)
		params.weaponType = tonumber(op.weaponType)
	end,
	["expend"]      = function(params, op)
		params.expend = check.tblkey(op.expend,
					     AI.Task.WeaponExpend,
					     "AI.Task.WeaponExpend")
	end,
	["direction"]   = function(params, op)
		params.direction        = check.range(op.direction,
						      0, 2 * math.pi)
		params.directionEnabled = true
	end,
	["altitude"]    = function(params, op)
		params.altitude        = tonumber(op.altitude)
		params.altitudeEnabled = true
	end,
	["attackQty"]   = function(params, op)
		params.attackQty      = tonumber(op.attackQty)
		params.attackQtyLimit = true
	end,
	["groupAttack"] = function(params, op)
		params.groupAttack = dcsext.math.toBoolean(op.groupAttack)
	end,
	["attackType"]  = function(params, op)
		params.attackType = check.tblkey(op.attackType,
						 enum.ATTACKTYPE,
						 "dcsext.enum.ATTACKTYPE")
	end,
	["priority"]    = function(params, op)
		params.priority = tonumber(op.priority)
	end,
}

--- Checks optional parameters.
-- @param params the parameters table
-- @param op optional parameters table that is checked
local function checkOptionalParams(params, op)
	if op == nil then
		return
	end

	for optName, optFunc in pairs(optionalParams) do
		if op[optName] ~= nil and params[optName] == nil then
			optFunc(params, op)
		end
	end
end

local _t = {}

--- Assigns the controlled group to attack a specified group.
-- Note: The targeted group becomes automatically detected for the
-- controlled group.
-- @param group the group to target
-- @param optionalparams optional parameters
function _t.attackGroup(group, optionalparams)
	local params = {}
	params.groupId = group:getID()
	checkOptionalParams(params, optionalparams)
	return exec.createTaskTbl('AttackGroup', params),
		enum.TASKTYPE.TASK
end

--- Assigns the nearest world object to the point for AI to attack.
-- @param point location on map to bomb
-- @param optionalparams optional parameters
function _t.attackMapObject(point, optionalparams)
	local params = {}
	params.point = vector.Vec2(point):get()
	checkOptionalParams(params, optionalparams)
	return exec.createTaskTbl('AttackMapObject', params),
		enum.TASKTYPE.TASK
end

--- Assigns the controlled group to attack a specified unit.
-- Note: The targeted unit becomes automatically detected for the
-- controlled group.
-- @param unit the unit to target
-- @param optionalparams optional parameters
function _t.attackUnit(unit, optionalparams)
	local params = {}
	params.unitId = unit:getID()
	checkOptionalParams(params, optionalparams)
	return exec.createTaskTbl('AttackUnit', params),
		enum.TASKTYPE.TASK
end

--- Assigns the aircraft to act as an AWACS for friendly forces.
function _t.awacs()
	return exec.createTaskTbl('AWACS'), enum.TASKTYPE.TASK
end

--- Assigns a point on the ground for which the AI will attack. Best used
-- for discriminant carpet bombing of a target or having a GBU hit a
-- specific point on the map.
-- @param point location on map to bomb
-- @param optionalparams optional parameters
function _t.bombing(point, optionalparams)
	local params = {}
	params.point = vector.Vec2(point):get()
	checkOptionalParams(params, optionalparams)
	return exec.createTaskTbl('Bombing', params),
		enum.TASKTYPE.TASK
end

--- Assigns the AI a task to bomb an airbases runway. By default the AI
-- will line up along the length of the runway and drop its payload.
-- @param airbase airbase object to target
-- @param optionalparams optional parameters
function _t.bombingRunway(airbase, optionalparams)
	local params = {}
	params.runwayId = airbase:getID()
	checkOptionalParams(params, optionalparams)
	return exec.createTaskTbl('BombingRunway', params),
		enum.TASKTYPE.TASK
end

--- A function which allows a Transport Helicopter to have access to the
-- "All Cargo" radio item. This in turn allows you to select one of the
-- Cargo containers you have placed in the map. A red smoke marker will
-- be spawned when you have selected one and you can then enable the cargo
-- lifting cues to maneuver you into the correct position for attaching
-- said cargo.
-- @param cargo cargo object to target
-- @param zoneid id of the trigger zone
function _t.cargoTransportation(cargo, zoneid)
	local params = {}
	params.groupId = cargo:getID()
	params.zoneId = zoneid
	return exec.createTaskTbl('CargoTransportation', params),
		enum.TASKTYPE.TASK
end

--- Assigns a point on the ground for which the AI will attack. Similar to
-- the bombing task, but with more control over target area. Can be combined
-- with follow big formation task for all participating aircraft to
-- simultaneously bomb a target.
-- In the mission editor this task is call "WW2 Carpet Bombing". This task
-- is not limited to WW2 aircraft.
-- Attack direction is assumed to be from the point where the task is
-- assigned.
-- @param pt location on map to bomb
-- @param len length of the bombing run
-- @param optionalparams optional parameters
function _t.carpetBombing(pt, len, optionalparams)
	local params = {}
	params.attackType   = 'Carpet'
	params.point        = vector.Vec2(pt):get()
	params.carpetLength = check.number(len)

	checkOptionalParams(params, optionalparams)
	return exec.createTaskTbl('CarpetBombing', params),
		enum.TASKTYPE.TASK
end

--- A list of tasks indexed numerically for when the task will be executed
-- in accordance with the AI task queue rules. This is the task that the
-- DCS mission editor will default to using for groups placed in the editor.
-- @param orderedlist
function _t.combo(orderedlist)
	return exec.createTaskTbl('ComboTask', orderedlist),
		enum.TASKTYPE.TASK
end

--- A controlled task is a task that has start and/or stop conditions that
-- will be used as a condition to start or stop the task. Start conditions
-- are executed only once when the task is reached in the task queue. If the
-- conditions are not met the task will be skipped. Stop Conditions are
-- executed at a high rate.
-- Can be used with any task in DCS. Note that options and commands do
-- *NOT* have stopConditions. These tasks are executed immediately and
-- take "no time" to run.
function _t.controlled(task, startcondition, stopcondition)
	local params = {}
	params.task = task
	params.condition = startcondition
	params.stopCondition = stopcondition
	return exec.createTaskTbl('ControlledTask', params),
		enum.TASKTYPE.TASK
end

--- Specifies the location an infantry group that is being transported by
-- helicopters will be unloaded at. Used in conjunction with the embarking
-- task.
-- @param point location
-- @param radius
function _t.disembarkFromTransport(point, radius)
	local params = {}
	params.x = point.x
	params.y = point.y
	params.zoneRadius = radius
	return exec.createTaskTbl('DisembarkFromTransport', params),
		enum.TASKTYPE.TASK
end

--- Used in conjunction with the EmbarkToTransport task for a ground
-- infantry group, the controlled helicopter flight will land at the
-- specified coordinates, pick up boarding troops and transport them
-- to that groups DisembarkFromTransport task.
function _t.embarking(point, groups, duration, distribution)
	local params = {}
	params.x = point.x
	params.y = point.y
	params.groupsForEmbarking = groups
	params.duration = duration

	if distribution ~= nil then
		params.distributionFlag = true
		params.distribution = distribution
	end
	return exec.createTaskTbl('Embarking', params),
		enum.TASKTYPE.TASK
end

--- Used in conjunction with the embarking task for a transport helicopter
-- group. The Ground units will move to the specified location and wait to
-- be picked up by a helicopter. The helicopter will then fly them to their
-- dropoff point defined by another task for the ground forces;
-- DisembarkFromTransport task.
-- @param point location where AI is expecting to be picked up
-- @param radius
function _t.embarkToTransport(point, radius)
	local params = {}
	params.x = point.x
	params.y = point.y
	params.zoneRadius = radius
	return exec.createTaskTbl('EmbarkToTransport', params),
		enum.TASKTYPE.TASK
end

--- Assigns the controlled group to search for and engage a specific group.
-- The target must be detected in order for AI to engage it.
-- @param group group reference to target
-- @param optionalparams
function _t.engageGroup(group, optionalparams)
	local params = {}
	params.groupId = group:getID()
	checkOptionalParams(params, optionalparams)
	return exec.createTaskTbl('EngageGroup', params),
		enum.TASKTYPE.TASK
end

--- Assigns the controlled group to engage targets that have a specific
-- attribute. Group will only engage detected targets.
-- When placing a flight with the role of CAP, CAS, SEAD, Anti-ship, or
-- Fighter Sweep in the mission editor an enroute task of the same name
-- will automatically be generated for said group on their first waypoint.
-- Theses tasks are available as an option in the enroute listing. Within
-- the mission file itself these tasks are actually a engageTargets tasking
-- with pre-defined target attributes.
-- Within the mission editor the task role selection filters the list of
-- valid attributeNames to be relevant to this task. In reality that doesn't
-- matter and you can assign whatever attribute you want for an aircraft to
-- attack.
-- @param tgtlist set of attribute names that are valid targets
-- @param maxdist maximum distance in meters the group will deviate from
-- their route to engage a target
-- @param prio the priority of the tasking, the lower the number the more
-- important. The default value is 0.
function _t.engageTargets(tgtlist, maxdist, prio)
	local params = {}
	params.targetTypes = check.table(tgtlist)

	if maxdist ~= nil then
		params.maxDist = tonumber(maxdist)
		params.maxDistEnabled = true
	end

	if prio ~= nil then
		params.priority = tonumber(prio)
	end

	return exec.createTaskTbl('EngageTargets', params),
		enum.TASKTYPE.TASK
end

--- Assigns the controlled group to engage targets that have a specific
-- attribute. Group will only engage detected targets.
-- @param tgtlist set of attribute names that are valid targets
-- @param pt center of the zone
-- @param radius radius of the zone
-- @param prio the priority of the tasking, the lower the number the more
-- important. The default value is 0.
function _t.engageTargetsInZone(tgtlist, pt, radius, prio)
	local params = {}
	params.targetTypes = check.table(tgtlist)
	params.point       = vector.Vec2(pt):get()
	params.zoneRadius  = tonumber(radius)

	if prio ~= nil then
		params.priority = tonumber(prio)
	end

	return exec.createTaskTbl('EngageTargetsInZone', params),
		enum.TASKTYPE.TASK
end

--- Assigns the controlled group to search for and engage a specific unit.
-- The target must be detected in order for AI to engage it.
-- @param unit the unit to target
-- @param optionalparams optional parameters
function _t.engageUnit(unit, optionalparams)
	local params = {}
	params.unitId = unit:getID()
	checkOptionalParams(params, optionalparams)
	return exec.createTaskTbl('EngageUnit', params),
		enum.TASKTYPE.TASK
end

--- Controlled aircraft will follow the assigned group along their route in
-- formation. If the assigned group is on the ground the AI will orbit
-- overhead. If assigned to a flight lead or group its wingmen will stay
-- in their specified formation.
function _t.follow(group, pos, wptidx)
	local params = {}
	params.groupId = group:getID()
	params.pos     = vector.Vec3(pos):get()

	if wptidx ~= nil then
		params.lastWptIndexFlag = true
		params.listWptIndex     = tonumber(wptidx)
	else
		params.lastWptIndexFlag = false
	end
	return exec.createTaskTbl('Follow', params), enum.TASKTYPE.TASK
end

--- Controlled aircraft will follow the assigned group along their route
-- in formation and will engage threats within a defined distance from
-- the followed group. If the assigned group is on the ground the AI will
-- orbit overhead. If assigned to a flight lead or group its wingmen will
-- stay in their specified formation.
function _t.escort(group, pos, engagedist, tgtlist, wptidx)
	local task, tasktype = _t.follow(group, pos, wptidx)

	task.id                       = 'Escort'
	task.params.engagementDistMax = tonumber(engagedist)
	task.params.targetTypes       = check.table(tgtlist)
	return task, tasktype
end

--- The assigned helicopter group will orbit above the assigned ground
-- group at a low altitude. Any valid detected targets will be engaged.
-- If multiple helicopters are in the group then the aircraft will be
-- distributed throughout the orbit. The orbit pattern is roughly just
-- flying back and forth.
function _t.escortGround(group, pos, orbitdist, tgtlist, wptidx)
	local task, tasktype = _t.escort(group, pos, orbitdist,
					 tgtlist, wptidx)

	task.id = 'GroundEscort'
	return task, tasktype
end

--- Assigns the group to act as an EWR radar for friendly forces.
function _t.ewr()
	return exec.createTaskTbl('EWR'), enum.TASKTYPE.TASK
end

--- Assigns the controlled group to act as a Forward Air Controller or
-- JTAC. Any detected targets will be assigned as targets to the player
-- via the JTAC radio menu. Target designation is set to auto and is
-- dependent on the circumstances.
function _t.fac(freq, mod, callid, callnum, prio)
	local params = {}
	params.frequency  = tonumber(freq)
	params.modulation = check.tblkey(mod, radio.modulation,
					 "radio.modulation")
	params.callname   = check.range(callid, 1, 18)
	params.number     = check.range(callnum, 1, 9)

	if prio ~= nil then
		params.priority = tonumber(prio)
	end

	return exec.createTaskTbl('FAC', params), enum.TASKTYPE.TASK
end

--- Assigns the controlled group to act as a Forward Air Controller or
-- JTAC in attacking the specified group. This task adds the group to
-- the JTAC radio menu and interacts with a player to destroy the target.
function _t.facAttackGroup(group, wpnType, designation, datalink,
			   freq, mod, callid, callnum)
	local task, tasktype = _t.fac(freq, mod, callid, callnum)

	task.id             = "FAC_AttackGroup"
	task.params.groupId = group:getID()

	if wpnType ~= nil then
		task.params.weaponType  = tonumber(wpnType)
	end

	if designation ~= nil then
		task.params.designation = check.tblkey(designation,
				AI.Task.Designation,
				"AI.Task.Designation")
	end

	if datalink ~= nil then
		task.params.datalink = dcsext.math.toBoolean(datalink)
	end

	return task, tasktype
end

--- Assigns the controlled group to act as a Forward Air Controller or
-- JTAC and engage the specified group as a JTAC target once it is detected.
-- This task adds the group to the JTAC radio menu and interacts with a
-- player to destroy the target.
function _t.facEngageGroup(group, wpnType, designation, datalink,
			   freq, mod, callid, callnum, prio)
	local task, tasktype = _t.facAttackGroup(group, wpnType, designation,
					datalink, freq, mod, callid, callnum)

	task.id = "FAC_EngageGroup"

	if prio ~= nil then
		task.params.priority = tonumber(prio)
	end

	return task, tasktype
end

--- Assigns a point on the ground for which the AI will shoot at. Most
-- commonly used with artillery to shell a target. Can also be used to
-- simulate a firefight by making AI shoot in the general direction of
-- other AI but not likely hitting anything. Either way it is the easiest
-- way to make AI use up all of their ammo.
-- It takes approximately 3 minutes for artillery positions to prepare and
-- fire at the specified target.
function _t.fireAtPoint(aimPoint, tgtRad, ctrBtryRad, optionalparams)
	local params = {}
	params.point = vector.Vec2(aimPoint):get()

	if tgtRad ~= nil then
		params.radius = tonumber(tgtRad)
	end

	if ctrBtryRad ~= nil then
		params.counterbatteryRadius = tonumber(ctrBtryRad)
	end

	checkOptionalParams(params, optionalparams)
	return exec.createTaskTbl('FireAtPoint', params),
		enum.TASKTYPE.TASK
end

--- Advanced version of the follow task. Primary difference is it can be
-- used with the Carpet Bombing task to allow large bomber formations to
-- simultaneously bomb a given target. Within the mission editor this task
-- also has tools for placing units in historic bomber formations.
-- This task is also labeled as "WW2: Big Formation" in the editor, but it
-- is functional with any aircraft assigned the ground attack task.
function _t.followBig(group, pos, wptidx)
	local task, tasktype = _t.follow(group, pos, wptidx)
	task.id = 'FollowBigFormation'
	return task, tasktype
end

--- Stops a ground force in its current position.
function _t.hold()
	return exec.createTaskTbl('Hold'), enum.TASKTYPE.TASK
end

--- Assigns the aircraft to land at a specific point on the ground. Useful
-- for troop transport with helicopters. Currently only applies to
-- Helicopters because I have no clue what at V-22 would be defined as
-- within the sim.
-- For landing at airbases, farps, or ships see the mission task page.
function _t.land(point, duration)
	local params = {}
	params.point = vector.Vec2(point):get()

	if duration ~= nil then
		params.duration     = tonumber(duration)
		params.durationFlag = true
	end

	return exec.createTaskTbl('Land', params), enum.TASKTYPE.TASK
end

--- Orders an aircraft group to orbit at the waypoint.
function _t.orbit(pat, options)
	local params = {}
	params.pattern  = check.tblkey(pat, dcsext.enum.ORBITPATTERN,
					"dcsext.enum.ORBITPATTERN")

	if options.point ~= nil then
		params.point = vector.Vec2(options.point):get()
	end

	if options.point2 ~= nil then
		params.point2 = vector.Vec2(options.point2):get()
	end

	if options.speed ~= nil then
		params.speed = tonumber(options.speed)
	end

	if options.altitude ~= nil then
		params.altitude = tonumber(options.altitude)
	end

	if params.pattern == enum.ORBITPATTERN.ANCHORED then
		if options.hotLegDir ~= nil then
			params.hotLegDir = tonumber(options.hotLegDir)
		end

		if options.legLength ~= nil then
			params.legLength = tonumber(options.legLength)
		end

		if options.width ~= nil then
			params.width = tonumber(options.width)
		end

		if options.clockWise ~= nil then
			params.clockWise =
				dcsext.math.toBoolean(options.clockWise)
		end
	end
	return exec.createTaskTbl('Orbit', params), enum.TASKTYPE.TASK
end

--- Assigns the aircraft to follow a ship group and perform a racetrack
-- orbit along the current heading of the fleet at the set altitude and
-- speed.
function _t.recoverytanker(group, speed, alt)
	local params = {}
	params.groupId = group:getID()
	params.speed = tonumber(speed)
	params.altitude = tonumber(alt)
	return exec.createTaskTbl('RecoveryTanker', params),
		enum.TASKTYPE.TASK
end

--- Assigns the controlled aircraft to refuel from the nearest airborne
-- tanker aircraft. Currently helicopters can't refuel in mid-air, but who
-- knows maybe someday they will.
function _t.refueling()
	return exec.createTaskTbl('Refueling'), enum.TASKTYPE.TASK
end

--- Assigns a point on the ground for which the AI will do a strafing run
-- with guns or rockets.
function _t.strafing(point, length, optionalparams)
	local task, tasktype = _t.bombing(point, optionalparams)

	if length ~= nil then
		task.params.length = tonumber(length)
	end
	task.id = 'Strafing'
	return task, tasktype
end

--- Assigns the aircraft to act as an Airborne tanker for friendly forces.
-- The aircraft must be a certified tanker aircraft, otherwise it would be
-- really awkward trying to hook up with it.
function _t.tanker()
	return exec.createTaskTbl('Tanker'), enum.TASKTYPE.TASK
end

return _t
