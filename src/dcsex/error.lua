-- SPDX-License-Identifier: LGPL-3.0

-- =============================================
-- Error - contains error handling functions
-- useful for DCS.
--
-- ex.error.errtraceback(err, lvl, version)
-- ex.error.errhandler(err, logger, lvl)
-- =============================================

local _t = {}

--- Print a stack trace in a well known format, so users know what
-- to copy when reporting errors.
-- @param err error object.
-- @param lvl level in the call stack to start the traceback or zero.
-- @param version version string to output with the stack track
-- @return string containing the stack trace
function _t.errtraceback(err, version, lvl)
	lvl = lvl or 0
	return "\n---[ cut here ]---\n"..
	       string.format("ERROR %s: ", version or "")..
	       debug.traceback(err, lvl+1)..
	       "\n---[ end trace ]---"
end

--- Logs an error message as a result of a failed pcall context.
-- @param err error object.
-- @param logger a dcsex.Logger object to print the trackback to.
-- @param lvl level in the call stack to start the traceback or one.
function _t.errhandler(err, logger, lvl)
	local str = _t.errtraceback(err, lvl or 1)
	logger:error("%s", str)
end

return _t
