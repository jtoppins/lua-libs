-- SPDX-License-Identifier: LGPL-3.0

local class = require("dcsext.class")
local Color = require("dcsext.ui.Color")
local setters = require("dcsext.setters")
local enum  = require("dcsext.enum")

local function setColor(_, _, new)
	return Color(new)
end

local function setLineType(self, key, new, old)
	return setters.setValFromTable(enum.MARKUP.LINETYPE, self,
				       key, new, old)
end

--- Base class for a drawable object.
-- This class must be inherited by a concrete class that needs to
-- draw objects in DCS.
-- @classmod dcsext.ui.DrawObject
local DrawObject = class("DrawObject")

--- Constructor.
function DrawObject:__init(scope)
	self._drawn = false
	self.scope = scope or dcsext.enum.coalition.ALL
	self:_property("color", Color.colors.BLACK, setColor,
			self.update)
	self:_property("colorfill", Color.colors.BLACK, setColor,
			self.update)
	self:_property("linetype", enum.MARKUP.LINETYPE.SOLID,
			setLineType, self.update)
	self:_property("text", "", setters.setString, self.update)
	self:_property("fontsize", 12, setters.setNumber, self.update)
	self:_property("radius", 100, setters.setNumber, self.update)
	self:_property("readonly", true, setters.setBoolean)

	self._updateHandlers = {
		["color"]     = trigger.action.setMarkupColor,
		["colorfill"] = trigger.action.setMarkupColorFill,
		["linetype"]  = trigger.action.setMarkupTypeLine,
		["text"]      = trigger.action.setMarkupText,
		["fontsize"]  = trigger.action.setMarkupFontSize,
		["radius"]    = trigger.action.setMarkupRadius,
	}
end

--- Pure abstract method. Inheriting objects must override this
-- method to draw the object.
function DrawObject:__draw()
	assert(false, "not implemented error")
end

--- Tests if this object has been drawn to the screen.
function DrawObject:isDrawn()
	return self._drawn
end

--- Public method to draw the object.
function DrawObject:draw()
	if self:isDrawn() then
		return
	end

	self.id = dcsext.world.getNextMarkID()
	self:__draw()
	self._drawn = true
end

--- Remove the drawn object from DCS.
function DrawObject:remove()
	if not self:isDrawn() or self.id == nil then
		return
	end

	trigger.action.removeMark(self.id)
	self.id = nil
	self._drawn = false
end

--- Updates an attribute of the object when its associated class
-- property is updated.
function DrawObject:update(key, new, old)
	local updater = self._updateHandlers[key]

        if not self:isDrawn() or new == old or
           type(updater) ~= "function" then
		return
	end

	if key == "color" or key == "colorfill" then
		new = new:get()
	end
	updater(self.id, new)
end

return DrawObject
