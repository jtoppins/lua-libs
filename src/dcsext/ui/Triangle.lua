-- SPDX-License-Identifier: LGPL-3.0

local class = require("dcsext.class")
local DrawObject = require("dcsext.ui.DrawObject")
local enum  = require("dcsext.enum")

--- Draw a triangle on the F10 map.
-- @classmod dcsext.ui.Triangle
-- @see dcsext.ui.DrawObject
local Triangle = class("Triangle", DrawObject)

--- Constructor.
-- @param points list of points representing the three corners of the
--        triangle.
-- @param scope ex.enum.coalition, which coalition can see the line
function Triangle:__init(points, scope)
	assert(type(points) == "table" and #points >= 3,
		"invalid points, need 3")
	DrawObject.__init(self, scope)
	self.points = points
end

--- Draw the triangle.
function Triangle:__draw()
	trigger.action.markupToAll(enum.MARKUP.SHAPE.FREEFORM,
				   self.scope,
				   self.id,
				   dcsext.vector.Vec3(self.points[1]):get(),
				   dcsext.vector.Vec3(self.points[2]):get(),
				   dcsext.vector.Vec3(self.points[3]):get(),
				   self.color:get(),
				   self.colorfill:get(),
				   self.linetype,
				   self.readonly,
				   self.message)
end

return Triangle
