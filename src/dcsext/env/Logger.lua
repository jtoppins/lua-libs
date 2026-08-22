-- SPDX-License-Identifier: LGPL-3.0

--- Logger. A simple leveled logger that writes to the DCS mission
-- environment log functions. Loggers are created by name and shared
-- through `getByName`.
-- @classmod dcsext.env.Logger

local class = require("dcsext.class")

local _loggers = {}
local _settings = {
	prefix      = "dcsext",
	level       = 1,
	debug       = false,
	showErrors  = false,
	logger      = {},
}

local Logger = class("Logger")

--- Logger logging levels.
-- Numeric levels passed to setLevel and setDefaultLogLevel, lower
-- values are more severe.
Logger.level = {
	["error"] = 0,
	["warn"]  = 1,
	["info"]  = 2,
	["debug"] = 4,
}

--- Get the logger associated with name.
-- Creates the logger on first use so callers sharing a name share a
-- single instance.
-- @param name facility name
-- @return the Logger instance for name
function Logger.getByName(name)
	local l = _loggers[name]
	if l == nil then
		l = Logger(name)
		_loggers[name] = l
	end
	return l
end

--- Enable or disable debug level as the default for new loggers.
-- Existing loggers keep their current level.
-- @param debug value converted with dcsext.math.toBoolean
function Logger.setDebug(debug)
	debug = dcsext.math.toBoolean(debug)
	_settings.debug = debug
end

--- Set the default logging level that new loggers with use unless
-- not specified in the logger table.
-- @param lvl log level from Logger.level
function Logger.setDefaultLogLevel(lvl)
	lvl = dcsext.check.tblkey(lvl, Logger.level, "Logger.level")
	_settings.level = lvl
end

--- Set specifically named loggers to have a specified default log
-- level. This might be useful when you have a known set of named
-- loggers and some need to log at debug vs. error.
-- @param lvltbl a table where each key is the name of a logger
--      and the value is the log level.
function Logger.setAllLogLevels(lvltbl)
	lvltbl = dcsext.check.table(lvltbl)
	_settings.logger = lvltbl
end

--- Set the log line prefix prepended to every log message generated.
-- This should be called first and set to something unique.
-- @param prefix the string prefix added to all log messages
function Logger.setPrefix(prefix)
	prefix = dcsext.check.string(prefix)
	_settings.prefix = prefix
end

--- Constructor.
-- @param name unique facility name for this logger, shown in every
--     message it logs
function Logger:__init(name)
	self.name   = dcsext.check.string(name)
	self.fmtstr = _settings.prefix .. "|%s: %s"
	self.dbgfmt = _settings.prefix .. "-debug|%s: %s"
	self:setLevel(_settings.level)
	if _settings.logger ~= nil and _settings.logger[name] ~= nil then
		self:setLevel(_settings.logger[name])
	elseif _settings.debug == true then
		self:setLevel(Logger.level["debug"])
	end

	self.level              = nil
	self.getByName          = nil
	self.setDebug           = nil
	self.setDefaultLogLevel = nil
	self.setAllLogLevels    = nil
	self.setPrefix          = nil

	if _settings.showErrors == true then
		self.errors = 0
		self.showErrors = true
	end
end

--- Sets the logging level of the logger object.
-- @param lvl numeric log level from Logger.level
function Logger:setLevel(lvl)
	assert(type(lvl) == "number", "invalid log level, not a number")
	assert(lvl >= Logger.level["error"] and lvl <= Logger.level["debug"],
			"invalid log level, out of range")
	self.__lvl = lvl
end

function Logger:_log(sink, fmtstr, userfmt, showErrors, ...)
	sink(string.format(fmtstr, self.name,
		string.format(userfmt, ...)), showErrors)
end

--- Log an error message.
-- @param userfmt format string same as string.format
-- @param ... values to format
function Logger:error(userfmt, ...)
	if self.showErrors then
		self.errors = self.errors + 1
		if self.errors > 3 then
			self:_log(env.error, self.fmtstr,
				"Supressing further messages from this logger\n"..
				"(check dcs.log for more errors)", true)
			self.showErrors = false
		end
	end
	self:_log(env.error, self.fmtstr, userfmt, self.showErrors, ...)
end

--- Log a warning message.
-- @param userfmt format string same as string.format
-- @param ... values to format
function Logger:warn(userfmt, ...)
	if self.__lvl < Logger.level["warn"] then
		return
	end
	self:_log(env.warning, self.fmtstr, userfmt, false, ...)
end

--- Log an info message.
-- @param userfmt format string same as string.format
-- @param ... values to format
function Logger:info(userfmt, ...)
	if self.__lvl < Logger.level["info"] then
		return
	end
	self:_log(env.info, self.fmtstr, userfmt, false, ...)
end

--- Log a debug message.
-- @param userfmt format string same as string.format
-- @param ... values to format
function Logger:debug(userfmt, ...)
	if self.__lvl < Logger.level["debug"] then
		return
	end
	self:_log(env.info, self.dbgfmt, userfmt, false, ...)
end

return Logger
