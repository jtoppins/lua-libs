-- SPDX-License-Identifier: LGPL-3.0

--- Circle - draw a circle on the F10 map.
-- The radius can be changed at any time through the radius property
-- inherited from DrawObject.
-- @classmod dcsext.ui.Circle
-- @see dcsext.ui.DrawObject

local class = require("dcsext.class")
local DrawObject = require("dcsext.ui.DrawObject")

local Circle = class("Circle", DrawObject)

--- Constructor.
-- @param point center of the circle.
-- @param scope dcsext.enum.coalition, which coalition can see the
--        circle
function Circle:__init(point, scope)
	DrawObject.__init(self, scope)
	self.point = dcsext.vector.Vec3(point)
end

--- Draw the circle.
function Circle:__draw()
	trigger.action.circleToAll(self.scope,
				   self.id,
				   self.point:get(),
				   self.radius,
				   self.color:get(),
				   self.colorfill:get(),
				   self.linetype,
				   self.readonly,
				   self.message)
end

return Circle
