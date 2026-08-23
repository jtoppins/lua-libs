-- SPDX-License-Identifier: LGPL-3.0

--- EventHandler class. Provides a common way for objects to process
-- events. Classes inheriting EventHandler map DCS event ids to
-- handler methods which onEvent dispatches protected from errors.
-- @classmod dcsext.interfaces.EventHandler

local class = require("dcsext.class")

local EventHandler = class()

--- Class constructor.
-- Initializes the internal event handler table. Subclasses must call
-- this from their own constructors, optionally after assigning
-- self._logger to reuse a specific logger instance.
function EventHandler:__init()
	if self._logger == nil then
		self._logger = dcsext.env.Logger.getByName(self.__clsname)
	end

	self._eventhandlers = {}
end

--- [internal] Overrides event handlers in the object.
-- Used mainly internally in inheriting constructor functions.
-- @param handlers map of DCS event id to handler function merged
--     into the handlers already registered on this object
function EventHandler:_overridehandlers(handlers)
	self._eventhandlers = dcsext.table.merge(self._eventhandlers, handlers)
end

--- Register this class with the DCS event handler system.
-- Requires the DCS world global, only available inside the mission
-- scripting environment. Events are delivered to onEvent until
-- unregister is called.
function EventHandler:register()
	world.addEventHandler(self)
end

--- Remove this class from the DCS event handler system.
-- No further events are delivered to onEvent afterwards.
function EventHandler:unregister()
	world.removeEventHandler(self)
end

--- Process a DCS event.
-- Looks up the handler registered for event.id and invokes it with
-- the event object. Implementers provide handlers through
-- _overridehandlers keyed by world.event ids. Handler errors are
-- caught and routed to the dcsext error handler so they never
-- propagate into the DCS event loop.
-- @param event the event object to dispatch
function EventHandler:onEvent(event)
	local handler = self._eventhandlers[event.id]
	if handler == nil then
		return
	end

	self._logger:debug("onEvent; event.id: %d (%s)",
		event.id,
		tostring(dcsext.table.getKey(world.event, event.id)))
	local ok, errmsg = pcall(handler, self, event)
	if not ok then
		dcsext.env.errhandler(errmsg, self._logger, 2)
	end
end

return EventHandler
