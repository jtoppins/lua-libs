-- SPDX-License-Identifier: LGPL-3.0

--- Represents a mission table. Handles loading a mission table and
-- provides some common ways of accessing the data. Also provides a
-- class method to extract the mission table from a zip.
-- @classmod dcsext.env.Mission

local class   = require("dcsext.class")
local Zone    = require("dcsext.env.Zone")

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
-- @return a Mission instance otherwise nil and an error string
function Mission.loadfile(zfile)
	local tbl, err = dcsext.io.extract(zfile, "mission",
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
-- @return a group table with data, countryid and category entries
function Mission.groupTable(grp, countryID, dcscategory)
	if dcscategory == Unit.Category.STRUCTURE then
		local dead = grp.dead
		grp = dcsext.table.deepCopy(grp.units[1])
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

--- A nil filter function.
-- @return true always
function Mission.noFilter()
	return true
end

--- Test if a mission unit table is player or client controlled.
-- @param unit unit table from a mission group definition
-- @return true when the unit skill is CLIENT or PLAYER
function Mission.isPlayerUnit(unit)
	if unit.skill == AI.Skill.CLIENT or
	   unit.skill == AI.Skill.PLAYER then
		return true
	end
	return false
end

--- Reads a DCS mission group definition and determines if there
-- are any player/client units defined in the group.
-- @param grp the mission group table to read.
-- @return true when any unit of the group is player/client controlled
function Mission.isPlayerGroup(grp)
	for _, unit in ipairs(grp.data.units) do
		if Mission.isPlayerUnit(unit) == true then
			return true
		end
	end
	return false
end

--- Constructor.
-- @param miztbl mission table as returned by `loadfile` or the DCS
--     `env.mission` table
-- @param logger optional Logger instance, defaults to the shared
--     DCSEXT logger
function Mission:__init(miztbl, logger)
	self._logger = logger or dcsext.env.Logger.getByName("DCSEXT")
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
-- Duplicate zone names replace the existing zone and log an error.
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

--- Get the zones defined in the mission.
-- @return table of Zone objects keyed by zone name
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

--- Get the groups defined in the mission.
-- @return table of group tables keyed by group name
function Mission:getGroups()
	return self.groups
end

--- Iterate over the groups defined in the mission.
-- @param filter optional predicate applied to each group table,
--     groups where it returns false or nil are skipped
-- @return iterator function yielding index and group table pairs
-- @return the groups table used as iterator state
-- @return nil initial index
function Mission:iterateGroups(filter)
	filter = filter or Mission.noFilter
	local function fnext(state, index)
		local idx = index
		local grp
		repeat
			idx, grp = next(state, idx)
			if grp == nil then
				return nil
			end
		until(filter(grp))
		return idx, grp
	end
	return fnext, self.groups, nil
end

--- Iterate over every unit of every group defined in the mission.
-- Units are collected from all groups before iterating so units
-- added during iteration are not visited.
-- @param filter optional predicate applied to each unit table,
--     units where it returns false or nil are skipped
-- @return iterator function yielding index and unit table pairs
-- @return the collected units list used as iterator state
-- @return nil initial index
function Mission:iterateUnits(filter)
	filter = filter or Mission.noFilter
	local units = {}
	local function fnext(state, index)
		local idx = index
		local unit
		repeat
			idx, unit = next(state, idx)
			if unit == nil then
				return nil
			end
		until(filter(unit))
		return idx, unit
	end

	for _, grp in self:iterateGroups() do
		for _, unit in ipairs(grp.data.units or {}) do
			table.insert(units, unit)
		end
	end
	return fnext, units, nil
end

return Mission
