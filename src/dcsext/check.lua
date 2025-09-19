-- SPDX-License-Identifier: LGPL-3.0

--- Library for checking input values

local _t = {}

--- Check that type(val) returns typstr, if not throw an error.
-- @param val the value to check
-- @param typestr the type string to compare with
-- @param lvl the stack level to start at/blame for the error
function _t.type(val, typestr, lvl)
	lvl = lvl or 0
	if type(val) ~= typestr then
		error("value error: must be of type "..typestr, lvl+1)
	end
	return val
end

--- Is val a boolean type?
-- @param val the value to check
-- @param lvl the stack level to start at/blame for the error
function _t.bool(val, lvl)
	lvl = lvl or 0
	return _t.type(val, "boolean", lvl+1)
end

--- Is num of type number?
-- @param num the number to check
-- @param lvl the stack level to start at/blame for the error
function _t.number(num, lvl)
	lvl = lvl or 0
	return _t.type(num, "number", lvl+1)
end

--- Is str of type string?
-- @param str the string to check
-- @param lvl the stack level to start at/blame for the error
function _t.string(str, lvl)
	lvl = lvl or 0
	return _t.type(str, "string", lvl+1)
end

--- Is t of type table?
-- @param t the table to check
-- @param lvl the stack level to start at/blame for the error
function _t.table(t, lvl)
	lvl = lvl or 0
	return _t.type(t, "table", lvl+1)
end

--- Is f of type function?
-- @param f the function reference to check
-- @param lvl the stack level to start at/blame for the error
function _t.func(f, lvl)
	lvl = lvl or 0
	return _t.type(f, "function", lvl+1)
end

--- Is val within min and max range?
-- @param val the value to check
-- @param min min value
-- @param max max value
-- @param lvl the stack level to start at/blame for the error
function _t.range(val, min, max, lvl)
	lvl = lvl or 0
	_t.number(val, lvl+1)
	if not (val >= min and val <= max) then
		error(string.format("value error: value not in range [%f,%f]",
			min, max), lvl+1)
	end
	return val
end

--- Is val a value from tbl?
-- @param val the value to check
-- @param tbl the table to check in
-- @param tblstr name of table used in the error msg to help the user
-- @param lvl the stack level to start at/blame for the error
function _t.tblkey(val, tbl, tblstr, lvl)
	lvl = lvl or 0
	if dcsext.table.getKey(tbl, val) == nil then
		error("value error: must be a value from "..tblstr, lvl+1)
	end
	return val
end

return _t
