-- SPDX-License-Identifier: LGPL-3.0

local class = require("dcsext.class")
local DrawObject = require("dcsext.ui.DrawObject")
local Line = require("dcsext.ui.Line")

--- Draw a poly line on the F10 map.
-- @classmod dcsext.ui.PolyLine
-- @see dcsext.ui.DrawObject
local PolyLine = class("PolyLine", DrawObject)

--- Constructor.
-- @param points lua list of 2d points.
-- @param scope ex.enum.coalition, which coalition can see the polyline
function PolyLine:__init(points, scope)
	assert(type(points) == "table" and #points >= 2,
		"invalid points")
	DrawObject.__init(self, scope)

        self.segments = {}
	for i = 1, #points - 1, 1 do
		table.insert(self.segments,
			     Line({points[i], points[i+1]}, self.scope))
	end

	-- not used in this class so don't carry it around
	self._updateHandlers = nil
end

--- Override draw method to handle calling all line segments.
function PolyLine:draw()
	if self:isDrawn() then
		return
	end

	for _, line in ipairs(self.segments) do
		line:draw()
	end
	self._drawn = true
end

--- Override remove method to handle calling all line segments.
function PolyLine:remove()
	if not self:isDrawn() then
		return
	end

	for _, line in ipairs(self.segments) do
		line:remove()
	end
	self._drawn = false
end

--- Override update method to handle setting the associated property
-- of each line segment.
function PolyLine:update(key, new, old)
	if new == old then
		return
	end

	for _, line in ipairs(self.segments) do
		line[key] = new
	end
end

return PolyLine
