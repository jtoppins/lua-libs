-- SPDX-License-Identifier: LGPL-3.0

local class   = require("dcsex.class")
local Zone    = require("dcsex.env.Zone")

--- Represents a mission table. Handles loading a mission table and
-- provides some common ways of accessing the data. Also provides a
-- class method to extract the mission table from a zip.
-- @classmod dcsex.env.Mission
local Mission = class("Mission")

--- maps category to the table entry in a mission table.
-- The keys are the mission table entries in lower case and the values
-- map the Unit.Category[<key>] keys.
Mission.categorymap = {
	["HELICOPTER"] = 'HELICOPTER',
	["SHIP"]       = 'SHIP',
	["VEHICLE"]    = 'GROUND_UNIT',
	["PLANE"]      = 'AIRPLANE',
	["STATIC"]     = 'STRUCTURE',
}

--- Load a .miz file into a lua table. It is assumed the mission is zip
-- compressed.
-- @param zfile string zip compressed file path
-- @return a Mission instance ortherwise nil and an error string
function Mission.loadfile(zfile)
	local tbl, err = dcsex.io.extract(zfile, "mission",
					  "l10n/DEFAULT/dictionary",
					  "warehouses")
	if not tbl then
		return nil, err
	end

	tbl.file = zfile
	local sortie = tbl.dictionary[tbl.mission.sortie]
	if sortie then
		tbl.mission.sortie = sortie
	end
	return Mission(tbl)
end

--- Create a group table.
-- @param grp the group definition
-- @param countryID the country the group belongs to, will determine
-- which coalition the group belongs to in game
-- @param dcscategory the Unit.Category the group belongs to
-- @return a table
function Mission.groupTable(grp, countryID, dcscategory)
	if dcscategory == Unit.Category.STRUCTURE then
		local dead = grp.dead
		grp = dcsex.table.deepCopy(grp.units[1])
		grp.dead = dead
	end

	return {
		["data"]      = grp,
		["countryid"] = countryID,
		["category"]  = dcscategory,
	}
end

--- Process category table and extract all defined groups.
-- @param grplist [output] list of groups found, indexed by group name
-- @param cattbl category table from a mission.coalition table
-- @param cntryid country id
-- @param dcscategory category from Unit.Category
-- @param logger a Logger instance
function Mission.processCategory(grplist, cattbl, cntryid, dcscategory, logger)
	if type(cattbl) ~= 'table' or cattbl.group == nil then
		return
	end

	for _, grp in ipairs(cattbl.group) do
		local grptbl = Mission.groupTable(grp, cntryid, dcscategory)
		if grplist[grptbl.data.name] ~= nil and logger ~= nil then
			logger:error("group(%s) duplicate replacing with newer",
				     grptbl.data.name)
		end
		grplist[grptbl.data.name] = grptbl
	end
end

--- Get all groups defined in `tbl.mission.coalition`.
-- @param coatbl coalition table, example `env.mission.coalition`
-- @param logger reference to an env.Logger instance
-- @return table keyed on group names.
function Mission.processCoalition(coatbl, logger)
	local groups = {}
	for _, coa_data in pairs(coatbl) do
		for _, cntrytbl in ipairs(coa_data.country) do
			for cat, unitcat in pairs(Mission.categorymap) do
				Mission.processCategory(groups,
					cntrytbl[string.lower(cat)],
					cntrytbl.id,
					Unit.Category[unitcat],
					logger)
			end
		end
	end
	return groups
end

--- Constructor.
function Mission:__init(miztbl, logger)
	self._logger = logger or dcsex.env.Logger.getByName("DCSEX")
	self.requiredModules = miztbl.mission.requiredModules
	self.theatre = miztbl.mission.theatre
	self.sortie  = miztbl.mission.sortie
	self.file    = miztbl.file
	self.zones   = Zone.getZones(miztbl.mission.triggers.zones,
				     self._logger)
	self.groups  = Mission.processCoalition(miztbl.mission.coalition)

	-- remove class methods
	self.categorymap = nil
	self.loadfile = nil
	self.groupTable = nil
	self.processCategory = nil
	self.processCoalition = nil
end

--- Add a new Zone to the zones table.
-- @param zonetbl the zone definition to process
function Mission:addZone(zonetbl)
	if zonetbl == nil then return end

	local zone = Zone(zonetbl)
	local name = zone:getName()

	if self.zones[name] ~= nil then
		self._logger:error(
			"zone(%s): duplicate zone name in file(%s)",
			name, tostring(self.file))
	end
	self.zones[name] = zone
end

function Mission:getZones()
	return self.zones
end

--- Add a group definition to the Mission instance.
-- @param grp the group definition
-- @param countryID the country the group belongs to, will determine
--     which coalition the group belongs to in game
-- @param dcscategory the Unit.Category the group belongs to
function Mission:addGroup(grp, countryID, dcscategory)
	local grptbl = Mission.groupTable(grp, countryID, dcscategory)

	if self.groups[grptbl.data.name] ~= nil then
		self._logger:error(
			"group(%s) duplicate group name in file(%s)",
			grptbl.data.name, tostring(self.file))
	end
	self.groups[grptbl.data.name] = grptbl
end

function Mission:getGroups()
	return self.groups
end

return Mission
