-- SPDX-License-Identifier: LGPL-3.0

--- Command class to run a deferred function. Provides a basic Command
-- class to call an arbitrary function at a later time.
-- @classmod dcsext.interfaces.Command

-- DCS sanitizes its environment so we have to keep a local reference to
-- the os table.
local myos    = require("os")
local class   = require("dcsext.class")
local check   = require("dcsext.check")

local function execute(self, time)
	self._logger:debug("executing: %s", tostring(self))
	local results = { pcall(self.run, self, time) }

	if results[1] == false then
		dcsext.env.errhandler(results[2], self._logger)

		if self.requeueOnError == true then
			return time + self.delay
		else
			return nil
		end
	end

	table.remove(results, 1)
	return unpack(results)
end

local function timedexecute(self, time)
	local tstart = myos.clock()
	local results = { execute(self, nil, time) }
	self._logger:debug("'%s' exec time: %5.2fms", tostring(self),
		(myos.clock()-tstart)*1000)
	return unpack(results)
end

local cmdpriority = {
	["UI"]     = 10,
	["NORMAL"] = 64,
}

local function setPriority(self, key, new, old)
	return dcsext.setters.setValFromTable(cmdpriority, self, key,
					      new, old)
end

local Command = class("Command")

--- Execute the deferred function.
-- The deferred function is called in a protected context where the
-- function can take an arbitrary parameter list and returns the same
-- number of values as if the function was called directly.
-- If the environment variable `DCSEXT_PROFILE == true` a different execute
-- function will be enabled which tracks how long the deferred function
-- takes to execute.
-- This could be beneficial when trying to debug stuttering.
-- @param self reference to Command object
-- @param time time-step the command is executed
-- @return[1] nil do not requeue the command
-- @return[2] number delay time the command should be requeued for
if _G.DCSEXT_PROFILE == true then
	Command.__mt.__call = timedexecute
else
	Command.__mt.__call = execute
end

function Command.__mt.__tostring(self)
	local s = self.__clsname
	if self.name ~= nil then
		s = s .. string.format(".%s", tostring(self.name))
	end
	return s
end

--- Class constructor.
-- @tparam number delay amount of delay in seconds before the command is
--   run.
-- @tparam string name name of the Command, used in log output to
--   differentiate.
-- @tparam function func the function to execute later. The function should
--   return either a number representing how long the command should be
--   requeued for before being executed again, otherwise nil to signal the
--   command should not be requeue.
-- @param ... arguments to pass to the function
function Command:__init(delay, name, func, ...)
	if self._logger == nil then
		self._logger = dcsext.env.Logger.getByName(self.__clsname)
	end
	self:_property("delay", check.number(delay), dcsext.setters.setNumber)
	self:_property("priority", cmdpriority.NORMAL, setPriority)
	self:_property("requeueOnError", false, dcsext.setters.setBoolean)
	self:_property("id", Command.IDNONE, dcsext.setters.setNumber)
	self.name = name

	if type(func) == "function" then
		self.func = func
		self.args = {select(1, ...)}
	end

	if _G.DCSEXT_PROFILE == true then
		self._exec = timedexecute
	else
		self._exec = execute
	end

	self.PRIORITY = nil
	self.IDNONE   = nil
end

--- General priority of the command.
-- lower value is higher priority; total of 127 priority values
Command.PRIORITY = cmdpriority
Command.IDNONE   = -1

--- Schedule the object to be called by the DCS scheduler.
function Command:register()
	if self.id ~= Command.IDNONE then
		return
	end
	self.id = timer.scheduleFunction(self._exec, self,
					 timer.getTime() + self.delay)
end

--- Remove this Command from the DCS scheduler.
function Command:unregister()
	if self.id == Command.IDNONE then
		return
	end
	timer.removeFunction(self.id)
	self.id = Command.IDNONE
end

--- Reschedules this Command for a different model time.
-- @param time the model time to run the Command
function Command:reschedule(time)
	if self.id == Command.IDNONE then
		return
	end
	timer.setFunctionTime(self.id, time)
end

--- This method is run each time the command is called. This function
-- may be overridden. The default implementation allows the Command
-- class to run an arbitrary function provided at instantiation.
function Command:run(time)
	local args = dcsext.table.shallowCopy(self.args)
	table.insert(args, time)
	return self.func(unpack(args))
end

return Command
