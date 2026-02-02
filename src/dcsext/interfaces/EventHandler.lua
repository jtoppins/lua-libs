-- SPDX-License-Identifier: LGPL-3.0

local class = require("dcsext.class")

--- EventHandler class. Provides a common way for objects to process
-- events.
-- @classmod dcsext.EventHandler
local EventHandler = class()

--- Class constructor.
function EventHandler:__init()
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
	local handler = self._eventhandlers[event.id]
	if handler ~= nil then
		handler(self, event)
	end
end

return EventHandler
