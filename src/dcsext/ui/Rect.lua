-- SPDX-License-Identifier: LGPL-3.0

local class = require("dcsext.class")
local Line = require("dcsext.ui.Line")

--- Draw a rectangle on the F10 map.
-- @classmod dcsext.ui.Rect
-- @see dcsext.ui.Line
local Rect = class("Rectangle", Line)

--- Constructor.
-- @param points lua list of 3d points, only the first 2 points will
--        be used.
-- @param scope ex.enum.coalition, which coalition can see the line
function Rect:__init(points, scope)
	Line.__init(self, points, scope)
end

--- Draw the rectangle.
function Rect:__draw()
	trigger.action.rectToAll(self.scope,
				 self.id,
				 dcsext.vector.Vec3(self.points[1]):get(),
				 dcsext.vector.Vec3(self.points[2]):get(),
				 self.color:get(),
				 self.colorfill:get(),
				 self.linetype,
				 self.readonly,
				 self.message)

end

return Rect
