-- SPDX-License-Identifier: LGPL-3.0

local class = require("dcsext.class")
local setters = require("dcsext.setters")

--- Draw a picture on screen to all players
-- @classmod dcsext.ui.Picture
local Picture = class("Picture")

Picture.hAlign = {
	["LEFT"]   = 0,
	["CENTER"] = 1,
	["RIGHT"]  = 2,
}

local function setHAlign(self, key, new, old)
	return setters.setValFromTable(Picture.hAlign, self, key, new, old)
end

Picture.vAlign = {
	["TOP"]    = 0,
	["CENTER"] = 1,
	["BOTTOM"] = 2,
}

local function setVAlign(self, key, new, old)
	return setters.setValFromTable(Picture.vAlign, self, key, new, old)
end

Picture.scaleType = {
	["PIXEL"]   = 0,
	["PERCENT"] = 1,
}

local function setScaleType(self, key, new, old)
	return setters.setValFromTable(Picture.scaleType, self, key, new, old)
end

--- Constructor.
function Picture:__init()
	self._drawn = false
	self:_property("file", "", setters.setString)
	self:_property("duration", 30, setters.setNumber)
	self:_property("clearview", false, setters.setBoolean)
	self:_property("delay", 0, setters.setNumber)
	self:_property("halign", Picture.hAlign.CENTER, setHAlign)
	self:_property("valign", Picture.vAlign.CENTER, setVAlign)
	self:_property("scale", 100, setters.setNumber)
	self:_property("scaletype", Picture.scaleType.PIXEL, setScaleType)

	self.hAlign = nil
	self.vAlign = nil
	self.scaleType = nil
end

--- Has the picture been drawn?
function Picture:isDrawn()
	return self._drawn
end

--- Draw the picture.
function Picture:draw()
	local cmd = [[
	a_out_picture(getValueResourceByKey("%s"), %d, %s, %d,
			"%d", "%d", %d, "%d")
	return true
	]]

	dcsext.env.doRPC("mission",
			string.format(cmd,
				self.file,
				self.duration,
				self.clearview,
				self.delay,
				self.halign,
				self.valign,
				self.scale,
				self.scaletype),
			"boolean")
	self._drawn = true
end

--- Remove the picture.
function Picture:remove()
	self._drawn = false
end

return Picture
