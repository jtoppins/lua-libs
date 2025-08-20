-- SPDX-License-Identifier: LGPL-3.0

local class = require("dcsex.class")
local DrawObject = require("dcsex.ui.DrawObject")

--- Draw text on the F10 map.
-- @classmod dcsex.ui.Text
-- @see dcsex.ui.DrawObject
local Text = class("Text", DrawObject)

--- Constructor.
-- @param point start point of the text.
-- @param scope ex.enum.coalition, which coalition can see the line
function Text:__init(point, scope)
	DrawObject.__init(self, scope)
	self.point = dcsex.vector.Vec3(point)
end

--- draw the text.
function Text:__draw()
	trigger.action.textToAll(self.scope,
				 self.id,
				 self.point:get(),
				 self.color:get(),
				 self.colorfill:get(),
				 self.fontsize,
				 self.readonly,
				 self.text)
end

return Text
