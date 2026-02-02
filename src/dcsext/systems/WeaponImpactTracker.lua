-- SPDX-License-Identifier: LGPL-3.0

local myos    = require("os")
local class   = require("dcsext.class")
local Command = require("dcsext.interfaces.Command")
local EventHandler = require("dcsext.interfaces.Command")
local LOOKAHEAD = 2 -- scales update rate to determine how many seconds
		    -- ahead to predict a weapon's impact point

local allowedmsltypes = {
	[Weapon.MissileCategory.CRUISE] = true,
	[Weapon.MissileCategory.OTHER]  = true,
}

local function buildImpactEvent(id, wpn)
	local event = {}
	event.id = id
	event.initiator = wpn
	event.point = wpn:getImpactPoint()
	return event
end

--- WeaponImpactTracker.
-- Tracks DCS Weapon objects to impact. Only weapons conforming to
-- isWpnValid will be tracked. Will emit a custom impact event to all
-- of DCS upon impact detection.
-- @type WeaponImpactTracker
local WeaponImpactTracker = class("WeaponImpactTracker", Command,
				  EventHandler)

--- Constructor.
function WeaponImpactTracker:__init(updateRate, eventID, weaponLifetime)
	Command.__init(self, updateRate)
	EventHandler.__init(self)
	self.requeueOnError = true
	self.eventID = eventID
	self.lookahead = self.delay * LOOKAHEAD
	self.weaponLifetime = weaponLifetime
	self.trackedwpns = {}

	self:_overridehandlers({
		[world.event.S_EVENT_SHOT] = self.handleShot,
	})
end

--- Only DCS Weapon objects where this function returns true will be
-- considered. Only consider Weapons not fired from air defence units
-- and have HE warheads. This method is intended to be overriden so
-- that mission builders can customize which weapons should be tracked.
-- @param event A DCS Shot event.
-- @treturn bool true if the weapon should be tracked.
function WeaponImpactTracker:isWpnValid(event)
	if event.initiator:hasAttribute("Air Defence") then
		return false
	end

	local wpndesc = event.weapon:getDesc()
	if wpndesc.category == Weapon.Category.MISSILE and
	   allowedmsltypes[wpndesc.missileCategory] == nil then
		return false
	end

	if wpndesc.warhead == nil or
	   wpndesc.warhead.type ~= Weapon.WarheadType.HE then
		return false
	end
	return true
end

--- Listens for DCS Shot events and tracks weapons the system is
-- interested in according to isWpnValid.
function WeaponImpactTracker:handleShot(event)
	if not self:isWpnValid(event) then
		self._logger:debug("weapon not valid typename: %s; initiator: %s",
			self.__clsname,
			event.weapon:getTypeName(),
			event.initiator:getName())
		return
	end
	self.trackedwpns[event.weapon.id_] =
		dcsext.objects.Weapon(event.weapon,
				      event.initiator,
				      self.weaponLifetime)
end

--- Update each tracked weapon and emit an impact event for each weapon
-- that has been determined to have impacted something.
function WeaponImpactTracker:run(time)
	local tstart = myos.clock()
	local impacts = {}
	for id, wpn in pairs(self.trackedwpns) do
		wpn:update(time, self.lookahead)
		if wpn:hasImpacted() and not wpn:exist() then
			table.insert(impacts, wpn)
			self.trackedwpns[id] = nil
		elseif not wpn:exist() then
			self.trackedwpns[id] = nil
		end
	end

	for _, wpn in pairs(impacts) do
		dcsext.world.notify(buildImpactEvent(self.eventID, wpn))
	end

	if _G.DCSEXT_PROFILE == true then
		self._logger:debug("'%s.update' exec time: %5.2fms",
			tostring(self), (myos.clock()-tstart)*1000)
	end
end

return WeaponImpactTracker
