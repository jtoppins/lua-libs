-- SPDX-License-Identifier: LGPL-3.0

local class = require("dcsext.class")
local DrawObject = require("dcsext.ui.DrawObject")

--- Draw a quadrilateral on the F10 map.
-- @classmod dcsext.ui.Quad
-- @see dcsext.ui.DrawObject
local Quad = class("Quad", DrawObject)

--- Constructor.
-- @param points list of points representing the four corners of the
--        quadrilateral.
-- @param scope ex.enum.coalition, which coalition can see the line
function Quad:__init(points, scope)
	assert(type(points) == "table" and #points == 4,
		"invalid points")
	DrawObject.__init(self, scope)
	self.points = points
end

--- Draw the quadrangle.
function Quad:__draw()
	trigger.action.quadToAll(self.scope,
				 self.id,
				 dcsext.vector.Vec3(self.points[1]):get(),
				 dcsext.vector.Vec3(self.points[2]):get(),
				 dcsext.vector.Vec3(self.points[3]):get(),
				 dcsext.vector.Vec3(self.points[4]):get(),
				 self.color:get(),
				 self.colorfill:get(),
				 self.linetype,
				 self.readonly,
				 self.message)
end

return Quad
