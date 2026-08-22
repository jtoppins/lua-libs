-- SPDX-License-Identifier: LGPL-3.0

--- Zone. Represents a zone table as defined in a mission file and
-- provides access to its geometry and custom properties.
-- @classmod dcsext.env.Zone

local class = require("dcsext.class")

local Zone = class("Zone")

--- Zone geometry types.
-- Maps the zone type strings found in mission file zone definitions
-- to their numeric ids.
Zone.types = {
	["CIRCLE"] = 1,
	["QUAD"]   = 2,
}

--- Return a list of Zone objects
-- @param zonelist the list of zone definitions, from the DCS env.mission
--    table this would be `env.mission.triggers.zones`
-- @param logger optional Logger instance used to report duplicate
--    zone names
-- @return a table of Zone objects keyed by zone name
function Zone.getZones(zonelist, logger)
	local zones = {}
	for _, z in pairs(zonelist) do
		local zone = Zone(z)
		local name = zone:getName()

		if zones[name] ~= nil and logger ~= nil then
			logger:error("previous zone('%s') overwriting", name)
		end
		zones[name] = zone
	end
	return zones
end

--- Zone constructor.
-- @param zonetbl zone definition table from the mission file, one
--    entry of `env.mission.triggers.zones`
function Zone:__init(zonetbl)
	self.id      = zonetbl.zoneId
	self.name    = zonetbl.name:lower()
	self.type    = zonetbl.type
	self.point   = dcsext.vector.Vec2(zonetbl)
	self.radius  = zonetbl.radius
	self.heading = zonetbl.heading
	self.hidden  = zonetbl.hidden
	self.props = {}

	if zonetbl.verticies ~= nil then
		self.verticies = {}
		for _, v in ipairs(zonetbl.verticies) do
			table.insert(self.verticies, dcsext.vector.Vec2(v))
		end
	end

	for _, prop in ipairs(zonetbl.properties) do
		local lkey = prop.key:lower()
		if self.props[lkey] == nil then
			self.props[lkey] = prop.value
		else
			if type(self.props[lkey]) == "table" then
				table.insert(self.props[lkey], prop.value)
			else
				local oldval = self.props[lkey]
				self.props[lkey] = {}
				table.insert(self.props[lkey], oldval)
				table.insert(self.props[lkey], prop.value)
			end
		end
	end
end

--- Return the name of the zone.
-- @return the zone name in lower case
function Zone:getName()
	return self.name
end

--- Return the center of the zone.
-- For quad zones the center is the average of the zone vertices.
-- @return the zone center point as a dcsext.vector.Vec2
function Zone:getPoint()
	local point = self.point or dcsext.vector.Vec2()

	if self.type == Zone.types.QUAD then
		for _, v in ipairs(self.verticies) do
			point = point + v
		end
		point = point / #self.verticies
	end
	return point
end

--- Return the value of zone property by name.
-- Property names are matched in lower case.
-- @param name the property name to look up
-- @return value or nil if the property doesn't exist
function Zone:getProperty(name)
	return self.props[name]
end

--- Return the property value converted to a bool.
-- Conversion follows dcsext.math.toBoolean, nil, false, 0 and the
-- strings "false", "no" and "off" become false, everything else true.
-- @param name the property name to look up
-- @return boolean interpretation of the property value
function Zone:getPropertyBoolean(name)
	return dcsext.math.toBoolean(self:getProperty(name))
end

--- Return the property value converted to a number
-- @param name the property name to look up
-- @param min minimum numerical value
-- @param max maximum numerical value
-- @return the property value clamped between min and max, or nil if
--    the property is missing or not numeric
function Zone:getPropertyFloat(name, min, max)
	local val = tonumber(self:getProperty(name))

	if val == nil then
		return nil
	end
	return dcsext.math.clamp(val, min, max)
end

--- Return the property value converted to an integer
-- @param name the property name to look up
-- @param min minimum numerical value
-- @param max maximum numerical value
-- @return the property value rounded down and clamped between min
--    and max, or nil if the property is missing or not numeric
function Zone:getPropertyInt(name, min, max)
	local val = self:getPropertyFloat(name, min, max)

	if val == nil then
		return nil
	end
	return math.floor(val)
end

return Zone
