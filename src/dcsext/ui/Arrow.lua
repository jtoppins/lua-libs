-- SPDX-License-Identifier: LGPL-3.0

--- Arrow - draw an arrow on the F10 map.
-- The arrow is drawn from the first to the second point of the given
-- point list.
-- @classmod dcsext.ui.Arrow
-- @see dcsext.ui.Line

local class = require("dcsext.class")
local Line = require("dcsext.ui.Line")

local Arrow = class("Arrow", Line)

--- Constructor.
-- @param points lua list of 3d points, only the first 2 points will
--        be used.
-- @param scope dcsext.enum.coalition, which coalition can see the
--        arrow
function Arrow:__init(points, scope)
	Line.__init(self, points, scope)
end

--- Draw the arrow.
function Arrow:__draw()
	trigger.action.arrowToAll(self.scope,
				  self.id,
				  dcsext.vector.Vec3(self.points[1]):get(),
				  dcsext.vector.Vec3(self.points[2]):get(),
				  self.color:get(),
				  self.colorfill:get(),
				  self.linetype,
				  self.readonly,
				  self.message)
end

return Arrow
