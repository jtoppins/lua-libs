-- SPDX-License-Identifier: LGPL-3.0

--- Route - an ordered sequence of dcsext.ai.Waypoint objects that a
-- DCS unit group will follow. Helps in constructing a DCS mission
-- task, see "DCS task mission" on the Hoggit Wiki.
-- @classmod dcsext.ai.Route

local class = require("dcsext.class")
local setters = require("dcsext.setters")

local Route = class("Route")

--- Constructor.
-- @param airborne boolean set to true for routes applied to air
-- groups; the Hoggit wiki notes this value is required for air
-- groups, otherwise they will not follow the new tasking
-- @param wpts array of dcsext.ai.Waypoint objects making up the
-- route, defaults to an empty list
function Route:__init(airborne, wpts)
	self:_property("airborne", false, setters.setBoolean)
	self.airborne  = airborne
	self.waypoints = wpts or {}
end

--- Add a new waypoint to the route.
-- @param wpt the dcsext.ai.Waypoint object to add
-- @param idx (optional) integer position to insert the waypoint
-- at, later waypoints shift down; appends to the end of the route
-- when omitted
function Route:addWaypoint(wpt, idx)
	if type(idx) == "number" then
		table.insert(self.waypoints, idx, wpt)
	else
		table.insert(self.waypoints, wpt)
	end
end

--- Remove a waypoint from the route.
-- @param idx (optional) integer position of the waypoint to
-- remove, removes the last waypoint when omitted
function Route:removeWaypoint(idx)
	table.remove(self.waypoints, idx)
end

--- Get a raw DCS compatible representation of the route such that
-- it can be passed to a Controller object.
-- @return t DCS mission task table wrapping this route
-- @return number dcsext.enum.TASKTYPE.TASK classification of the
-- returned table
function Route:get()
	local params = {}
	params.airborne = self.airborne
	params.route = {}
	params.route.points = {}
	for _, wypt in ipairs(self.waypoints) do
		table.insert(params.route.points, wypt:get())
	end
	return dcsext.ai.exec.createTaskTbl('Mission', params),
		dcsext.enum.TASKTYPE.TASK
end

return Route
