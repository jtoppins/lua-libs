-- SPDX-License-Identifier: LGPL-3.0

local class = require("dcsext.class")

--- EventHandler class. Provides a common way for objects to process
-- events.
-- @classmod dcsext.interfaces.EventHandler
local EventHandler = class()

--- Class constructor.
function EventHandler:__init()
	if self._logger == nil then
		self._logger = dcsext.env.Logger.getByName(self.__clsname)
	end

	self._eventhandlers = {}
end

--- [internal] Overrides event handlers in the object.
-- Used mainly internally in inhertining constructor functions.
function EventHandler:_overridehandlers(handlers)
	self._eventhandlers = dcsext.table.merge(self._eventhandlers, handlers)
end

--- Register this class with the DCS event handler system.
function EventHandler:register()
	world.addEventHandler(self)
end

--- Remove this class from the DCS event handler system.
function EventHandler:unregister()
	world.removeEventHandler(self)
end

--- Process a DCS event.
-- @param event the event object to dispatch
function EventHandler:onEvent(event)
	self._logger:debug("onEvent; event.id: %d (%s)",
		event.id,
		tostring(dcsext.table.getKey(world.event, event.id)))
	local handler = self._eventhandlers[event.id]
	if handler ~= nil then
		handler(self, event)
	end
end

return EventHandler
