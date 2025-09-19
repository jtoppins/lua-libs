-- SPDX-License-Identifier: LGPL-3.0

local class = require("dcsext.class")

--- Zone class. Class that represents a zone table as defined
-- in a mission table.
-- @classmod dcsext.env.Zone
local Zone = class("Zone")

Zone.types = {
	["CIRCLE"] = 1,
	["QUAD"]   = 2,
}

--- Return a list of Zone objects
-- @param zonelist the list of zone definitions, from the DCS env.mission
--    table this would be `env.mission.triggers.zones`
-- @param logger reference
-- @return a list of Zone objects
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
-- @param zonetbl
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

function Zone:getName()
	return self.name
end

--- Return the center of the zone.
-- @return dcsext.vector.Vec2
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
-- @param name the property name to look up
-- @return value or nil if the property doesn't exist
function Zone:getProperty(name)
	return self.props[name]
end

--- Return the property value converted to a bool.
-- @param name the property name to look up
-- @return boolean
function Zone:getPropertyBoolean(name)
	return dcsext.math.toBoolean(self:getProperty(name))
end

--- Return the property value converted to a number
-- @param name the property name to look up
-- @param min minimum numerical value
-- @param max maximum numerical value
-- @return number clamped between min and max
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
-- @return number clamped between min and max
function Zone:getPropertyInt(name, min, max)
	local val = self:getPropertyFloat(name, min, max)

	if val == nil then
		return nil
	end
	return math.floor(val)
end

return Zone
