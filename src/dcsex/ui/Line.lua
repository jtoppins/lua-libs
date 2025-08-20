-- SPDX-License-Identifier: LGPL-3.0

local class = require("dcsex.class")
local DrawObject = require("dcsex.ui.DrawObject")

--- Draw a line on the F10 map.
-- @classmod dcsex.ui.Line
-- @see dcsex.ui.DrawObject
local Line = class("Line", DrawObject)

--- Constructor.
-- @param points lua list of 3d points, only the first 2 points will
--        be used.
-- @param scope ex.enum.coalition, which coalition can see the line
function Line:__init(points, scope)
	assert(type(points) == "table" and #points >= 2,
		"invalid points")
	DrawObject.__init(self, scope)
	self.points = points
end

--- Draw the line.
function Line:__draw()
	trigger.action.lineToAll(self.scope,
				 self.id,
				 dcsex.vector.Vec3(self.points[1]):get(),
				 dcsex.vector.Vec3(self.points[2]):get(),
				 self.color:get(),
				 self.linetype,
				 self.readonly,
				 self.message)
end

return Line
