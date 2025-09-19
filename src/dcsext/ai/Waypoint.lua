-- SPDX-License-Identifier: LGPL-3.0

local class  = require("dcsext.class")

--- Define a waypoint in a DCS route. Helps in constructing a
-- DCS mission task, see "DCS task mission" on Hoggit Wiki.
-- @classmod dcsext.ai.Waypoint
local Waypoint = class("Waypoint")

--- Constructor.
-- @param point Vec2|Vec3 if Vec3 the altitude component will be
-- used to set the altitude of the waypoint
-- @param wtype one of Waypoint.wpType
-- @param action (optional) one of Waypoint.wpAction otherwise an
-- appropriate value will be chosen based on wtype
-- @param speed (optional) speed in meters per second
-- @param name (optional) name of the waypoint
function Waypoint:__init(point, wtype, action, speed, name)
	local vec3 = dcsext.vector.Vec3(point)

	self.name  = name
	self.tasks = {}
	self:setPoint(vec3, wtype, action)
	self:setAlt(vec3.y)
	self:setSpeed(speed or 0)

	self.wpType               = nil
	self.wpAction             = nil
	self.createGround         = nil
	self.createNaval          = nil
	self.createLandingTakeoff = nil
end

--- Waypoint types. Use TURNING_POINT for ships and ground groups.
Waypoint.wpType = {
	["TURNING_POINT"]       = AI.Task.WaypointType.TURNING_POINT,
	["TAKEOFF"]             = AI.Task.WaypointType.TAKEOFF,
	["TAKEOFF_PARKING"]     = AI.Task.WaypointType.TAKEOFF_PARKING,
	["TAKEOFF_PARKING_HOT"] = AI.Task.WaypointType.TAKEOFF_PARKING_HOT,
	["TAKEOFF_GROUND"]      = "TakeOffGround",
	["TAKEOFF_GROUND_HOT"]  = "TakeOffGroundHot",
	["LAND"]                = AI.Task.WaypointType.LAND,
	["LAND_REARM"]          = "LandingReFuAr",
}

--- Waypoint actions. Use TURNING_POINT for ships and ground groups.
Waypoint.wpAction = {
	["TURNING_POINT"]    = AI.Task.WaypointType.TURNING_POINT,
	["FLY_OVER_POINT"]   = AI.Task.TurnMethod.FLY_OVER_POINT,
	["FROM_PARKING"]     = "From Parking Area",
	["FROM_PARKING_HOT"] = "From Parking Area Hot",
	["FROM_GROUND"]      = "From Ground Area",
	["FROM_GROUND_HOT"]  = "From Ground Area Hot",
	["FROM_RUNWAY"]      = "From Runway",
	["LANDING"]          = "Landing",
	["LANDING_REARM"]    = "LandingReFuAr",
}

-- maps waypoint types to actions.
local type2actionmap = {
	[Waypoint.wpType.LAND] =
		Waypoint.wpAction.LANDING,
	[Waypoint.wpType.TAKEOFF] =
		Waypoint.wpAction.FROM_RUNWAY,
	[Waypoint.wpType.TAKEOFF_PARKING] =
		Waypoint.wpAction.FROM_PARKING,
	[Waypoint.wpType.TAKEOFF_PARKING_HOT] =
		Waypoint.wpAction.FROM_PARKING_HOT,
	[Waypoint.wpType.TAKEOFF_GROUND] =
		Waypoint.wpAction.FROM_GROUND,
	[Waypoint.wpType.TAKEOFF_GROUND_HOT] =
		Waypoint.wpAction.FROM_GROUND_HOT,
	[Waypoint.wpType.LAND_REARM] =
		Waypoint.wpAction.LANDING_REARM,
	[Waypoint.wpType.TURNING_POINT] =
		Waypoint.wpAction.TURNING_POINT,
}

-- maps an airbase category to the correct field name to identify
-- the airbase. Useful for takeoff and land waypoints.
local linkmap = {
	[Airbase.Category.AIRDROME] = "airdromeId",
	[Airbase.Category.HELIPAD]  = "helipadId",
	[Airbase.Category.SHIP]     = "linkUnit",
}

--- Class method to create a ground group compatible waypoint.
-- @param point a Vec2
-- @param speed number in meters per second
-- @param formation (optional) one of AI.Task.VehicleFormation
-- @param name (optional) name of waypoint
function Waypoint.createGround(point, speed, formation, name)
	local pt = dcsext.vector.Vec3(point)
	pt.y = land.getHeight(dcsext.vector.Vec2(point):get())

	local wpt = Waypoint(point, Waypoint.wpType.TURNING_POINT,
			dcsext.check.tblkey(formation or
					    AI.Task.VehicleFormation.ON_ROAD,
					    AI.Task.VehicleFormation,
					    "AI.Task.VehicleFormation"),
			speed, name)
	return wpt
end

--- Class method to create a naval group compatible waypoint.
-- @param point a Vec2
-- @param speed number in meters per second
-- @param depth (optional) depth in meters
-- @param name (optional) name of waypoint
function Waypoint.createNaval(point, speed, depth, name)
	local wpt = Waypoint(point,
			     Waypoint.wpType.TURNING_POINT,
			     Waypoint.wpAction.TURNING_POINT,
			     speed, name)
	wpt:setAlt(-math.abs(depth) or 0)
	return wpt
end

--- Class method to create a landing or takeoff waypoint
-- @param airbase a DCS Airbase instance
-- @param wtype one of Waypoint.wpType, required to specify the
-- takeoff type or landing
-- @param speed (optional) speed in meters per second
function Waypoint.createLandingTakeoff(airbase, wtype, speed)
	dcsext.check.table(airbase)
	local point = dcsext.vector.Vec3(airbase:getPoint())
	local item = linkmap[airbase:getDesc().category]
	local wpt = Waypoint(point, wtype, nil, speed, wtype)

	wpt[item] = airbase:getID()
	return wpt
end

--- Set the waypoint location.
-- @param vec2 a Vec2 point
-- @param wptype one of Waypoint.wpType
-- @param action (optional) one of Waypoint.wpAction otherwise an
-- appropriate value will be chosen based on wtype
function Waypoint:setPoint(vec2, wptype, action)
	self.point = dcsext.vector.Vec2(dcsext.check.table(vec2))
	self.type = dcsext.check.tblkey(wptype or
				        Waypoint.wpType.TURNING_POINT,
				        Waypoint.wpType,
				        "Waypoint.wpType")

	local typeaction = type2actionmap[self.type]
	if action ~= nil then
		self.action = action
	elseif typeaction ~= nil then
		self.action = typeaction
	else
		self.action = Waypoint.wpAction.TURNING_POINT
	end
end

--- Set the altitude of the waypoint.
-- @param alt altitude to set for the waypoint
-- @param alttype AI.Task.AltitudeType.* the default is BARO
function Waypoint:setAlt(alt, alttype)
	self.alt      = dcsext.check.number(alt)
	self.alt_type = dcsext.check.tblkey(alttype or
					    AI.Task.AltitudeType.BARO,
					    AI.Task.AltitudeType,
					    "AI.Task.AltitudeType")
end

--- Set the speed of the waypoint.
-- @param spd speed in meters per second
function Waypoint:setSpeed(spd)
	self.speed        = dcsext.check.number(spd)
	self.speed_locked = true
	self.ETA_locked   = false
end

--- Set ETA, this will override the speed and make the group
-- go at the speed necessary to reach the waypoint at the given
-- time.
-- @param time time in seconds since the mission started
function Waypoint:setETA(time)
	self.ETA          = dcsext.check.number(time)
	self.ETA_locked   = true
	self.speed_locked = false
end

--- Add a new task to the task list.
-- @param task task table
-- @param tasktype dcsext.enum.TASKTYPE
-- @param idx (optional) if provided is the integer index to insert
-- the new task at, otherwise appends to the end of the list
function Waypoint:addTask(task, tasktype, idx)
	local tbl = dcsext.ai.exec.wrapTask(task, tasktype)

	if type(idx) == "number" then
		table.insert(self.tasks, idx, tbl)
	else
		table.insert(self.tasks, tbl)
	end
end

--- Remove a waypoint from the task list.
-- @param idx (optional) remove Waypoint at idx position, otherwise
-- remove the Waypoint at the end of the list
function Waypoint:removeTask(idx)
	return table.remove(self.tasks, idx)
end

--- Get a raw DCS compatible representation of the waypoint.
-- @return table
function Waypoint:get()
	local attrs = {
		"name", "type", "action", "alt", "alt_type",
		"speed", "speed_locked", "ETA", "ETA_locked",
		"airdromeId", "helipadId", "linkUnit",
	}
	local tbl = {}
	for _, attr in pairs(attrs) do
		tbl[attr] = self[attr]
	end
	tbl = dcsext.table.merge(tbl, self.point:get())
	if next(self.tasks) then
		local t = {}

		for _, task in ipairs(self.tasks) do
			local data = task.data
			if task.type == dcsext.enum.TASKTYPE.OPTION then
				data = dcsext.ai.options.wrappedOption(
					task.data)
			elseif task.type == dcsext.enum.TASKTYPE.COMMAND then
				data = dcsext.ai.commands.wrappedCommand(
					task.data)
			end
			table.insert(t, data)
		end

		tbl.task = dcsext.ai.tasks.combo(t)
	end
	return tbl
end

return Waypoint
