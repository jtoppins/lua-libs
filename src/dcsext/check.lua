-- SPDX-License-Identifier: LGPL-3.0

--- Check - library for validating input values.
-- Each check raises a lua error when it fails and returns the validated
-- value on success so calls can be used inline, ex
-- `local str = check.string(arg)`. The optional `lvl` argument offsets
-- the error level passed to lua's error function to blame the caller of
-- the check instead of this library, the default blames the caller.

local _t = {}

--- Check that type(val) returns typestr, if not throw an error.
-- @param val the value to check
-- @param typestr the type string to compare with
-- @param lvl (optional) error level offset used to blame the caller,
-- defaults to 0
-- @return val unchanged when the check passes
function _t.type(val, typestr, lvl)
	lvl = lvl or 0
	if type(val) ~= typestr then
		error("value error: must be of type "..typestr, lvl+1)
	end
	return val
end

--- Is val a boolean type?
-- @param val the value to check
-- @param lvl (optional) error level offset, defaults to 0
-- @return val unchanged when it is a boolean
function _t.bool(val, lvl)
	lvl = lvl or 0
	return _t.type(val, "boolean", lvl+1)
end

--- Is num of type number?
-- @param num the number to check
-- @param lvl (optional) error level offset, defaults to 0
-- @return num unchanged when it is a number
function _t.number(num, lvl)
	lvl = lvl or 0
	return _t.type(num, "number", lvl+1)
end

--- Is str of type string?
-- @param str the string to check
-- @param lvl (optional) error level offset, defaults to 0
-- @return str unchanged when it is a string
function _t.string(str, lvl)
	lvl = lvl or 0
	return _t.type(str, "string", lvl+1)
end

--- Is t of type table?
-- @param t the table to check
-- @param lvl (optional) error level offset, defaults to 0
-- @return t unchanged when it is a table
function _t.table(t, lvl)
	lvl = lvl or 0
	return _t.type(t, "table", lvl+1)
end

--- Is f of type function?
-- @param f the function reference to check
-- @param lvl (optional) error level offset, defaults to 0
-- @return f unchanged when it is a function
function _t.func(f, lvl)
	lvl = lvl or 0
	return _t.type(f, "function", lvl+1)
end

--- Is val within min and max range inclusive?
-- @param val the value to check
-- @param min minimum allowed value
-- @param max maximum allowed value
-- @param lvl (optional) error level offset, defaults to 0
-- @return val unchanged when it is within the range
function _t.range(val, min, max, lvl)
	lvl = lvl or 0
	_t.number(val, lvl+1)
	if not (val >= min and val <= max) then
		error(string.format("value error: value not in range [%f,%f]",
			min, max), lvl+1)
	end
	return val
end

--- Is val a value stored in tbl?
-- Membership is tested by comparing values with dcsext.table.getKey.
-- @param val the value to check
-- @param tbl the table to check in
-- @param tblstr name of table used in the error msg to help the user
-- @param lvl (optional) error level offset, defaults to 0
-- @return val unchanged when found in tbl
function _t.tblkey(val, tbl, tblstr, lvl)
	lvl = lvl or 0
	if dcsext.table.getKey(tbl, val) == nil then
		error("value error: must be a value from "..tblstr, lvl+1)
	end
	return val
end

return _t
