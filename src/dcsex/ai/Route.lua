-- SPDX-License-Identifier: LGPL-3.0

local class = require("dcsex.class")
local setters = require("dcsex.setters")

--- Define a route a DCS unit group will take. Helps in constructing a
-- DCS mission task, see "DCS task mission" on Hoggit Wiki.
-- @classmod dcsex.ai.Route
local Route = class("Route")

--- Constructor.
-- @param airborne set to True for routes applied to air groups.
-- The Hoggit wiki says this value is needed for air groups
-- otherwise the group will not follow the new tasking.
-- @param wpts array of dcsex.ai.Waypoint objects
function Route:__init(airborne, wpts)
	self:_property("airborne", false, setters.setBoolean)
	self.airborne  = airborne
	self.waypoints = wpts or {}
end

--- Add a new waypoint to the route list.
-- @param wpt the Waypoint object to add
-- @param idx (optional) if provided is the integer index to insert
-- the new Waypoint at, otherwise appends to the end of the list
function Route:addWaypoint(wpt, idx)
	if type(idx) == "number" then
		table.insert(self.waypoints, idx, wpt)
	else
		table.insert(self.waypoints, wpt)
	end
end

--- Remove a waypoint from the route list.
-- @param idx (optional) remove Waypoint at idx position, otherwise
-- remove the Waypoint at the end of the list
function Route:removeWaypoint(idx)
	table.remove(self.waypoints, idx)
end

--- Get a raw DCS compatible representation of the route such that
-- it could be passed to a Controller object.
-- @return table, dcsex.enum.TASKTYPE.TASK
function Route:get()
	local params = {}
	params.airborne = self.airborne
	params.route = {}
	params.route.points = {}
	for _, wypt in ipairs(self.waypoints) do
		table.insert(params.route.points, wypt:get())
	end
	return dcsex.ai.exec.createTaskTbl('Mission', params),
		dcsex.enum.TASKTYPE.TASK
end

return Route
