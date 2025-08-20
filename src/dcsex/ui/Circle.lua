-- SPDX-License-Identifier: LGPL-3.0

local class = require("dcsex.class")
local DrawObject = require("dcsex.ui.DrawObject")

--- Draw a circle on the F10 map.
-- @classmod dcsex.ui.Circle
-- @see dcsex.ui.DrawObject
local Circle = class("Circle", DrawObject)

--- Constructor.
-- @param point center of the circle.
-- @param scope ex.enum.coalition, which coalition can see the circle
function Circle:__init(point, scope)
	DrawObject.__init(self, scope)
	self.point = dcsex.vector.Vec3(point)
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
