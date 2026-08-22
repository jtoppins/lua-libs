-- SPDX-License-Identifier: LGPL-3.0

--- PolyLine - draw a poly line on the F10 map.
-- The polyline is drawn as a sequence of Line segments connecting
-- consecutive points.
-- @classmod dcsext.ui.PolyLine
-- @see dcsext.ui.DrawObject

local class = require("dcsext.class")
local DrawObject = require("dcsext.ui.DrawObject")
local Line = require("dcsext.ui.Line")

local PolyLine = class("PolyLine", DrawObject)

--- Constructor.
-- Raises an error when fewer than two points are supplied.
-- @param points lua list of 2d points.
-- @param scope dcsext.enum.coalition, which coalition can see the
--        polyline
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
-- Draws every segment and then marks the polyline as drawn.
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
-- Removes every segment and then clears the drawn state.
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
-- @param key name of the updated property.
-- @param new the new property value.
-- @param old the previous property value.
function PolyLine:update(key, new, old)
	if new == old then
		return
	end

	for _, line in ipairs(self.segments) do
		line[key] = new
	end
end

return PolyLine
