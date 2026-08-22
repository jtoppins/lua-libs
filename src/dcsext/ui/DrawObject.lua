-- SPDX-License-Identifier: LGPL-3.0

--- DrawObject - base class for a drawable object.
-- This class must be inherited by a concrete class that needs to
-- draw objects in DCS.
-- @classmod dcsext.ui.DrawObject

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

local DrawObject = class("DrawObject")

--- Constructor.
-- Initializes the drawable with the properties listed below. Every
-- property can be reassigned later; while the object is drawn the
-- change is pushed to DCS immediately.
--
-- * color - outline color, a Color instance (default black)
-- * colorfill - fill color, a Color instance (default black)
-- * linetype - line style from enum.MARKUP.LINETYPE (default SOLID)
-- * text - label text (default empty string)
-- * fontsize - font size in points (default 12)
-- * radius - radius in meters, used by circles (default 100)
-- * readonly - whether the mark can be edited by players
--   (default true)
--
-- @param scope dcsext.enum.coalition, which coalition can see the
--        drawn object; defaults to all coalitions.
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
-- @return true if the object is currently drawn, false otherwise.
function DrawObject:isDrawn()
	return self._drawn
end

--- Public method to draw the object.
-- Allocates a mark id and calls the abstract \_\_draw method once;
-- further calls are ignored until the object is removed again.
function DrawObject:draw()
	if self:isDrawn() then
		return
	end

	self.id = dcsext.world.getNextMarkID()
	self:__draw()
	self._drawn = true
end

--- Remove the drawn object from DCS.
-- Does nothing when the object is not currently drawn.
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
-- Live-updates the corresponding attribute of the drawn mark in DCS;
-- has no effect while the object is not drawn.
-- @param key name of the updated property.
-- @param new the new property value.
-- @param old the previous property value.
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
