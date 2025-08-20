-- SPDX-License-Identifier: LGPL-3.0

local class = require("dcsex.class")
local DrawObject = require("dcsex.ui.DrawObject")

--- Draws a mark object on the DCS F10 map.
-- @classmod dcsex.ui.Mark
-- @see dcsex.ui.DrawObject
local Mark = class("Mark", DrawObject)

--- The scope in which the mark can be viewed.
Mark.scopeType = {
	["COALITION"] = "coa",
	["GROUP"]     = "group",
	["ALL"]       = "all",
}

local mark_funcs = {
	[Mark.scopeType.COALITION] = trigger.action.markToCoalition,
	[Mark.scopeType.GROUP]     = trigger.action.markToGroup,
	[Mark.scopeType.ALL]       = trigger.action.markToAll,
}

--- Constructor.
-- @param point 2d position where the mark should be placed.
-- @param scope Mark.scopeType if the scope can only be seen
--        by a specific coalition or group.
-- @param scopeid the id specifying the scope, example:
--        if scope=coalition then scopeid=coalition.side.RED.
function Mark:__init(point, scope, scopeid)
	DrawObject.__init(self, scope)
	self.point = dcsex.vector.Vec3(point)
	self.scope = scope or Mark.scopeType.ALL
	self.func = mark_funcs[self.scope]
	self.scopeid = scopeid

	self.scopeType = nil
end

--- Draw the mark.
function Mark:__draw()
	if self.scope == Mark.scopeType.ALL then
		self.func(self.id,
			  self.text,
			  self.point:get(),
			  self.readonly,
			  self.message)
	else
		self.func(self.id,
			  self.text,
			  self.point:get(),
			  self.scopeid,
			  self.readonly,
			  self.message)
	end
end

return Mark
