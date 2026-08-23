-- SPDX-License-Identifier: LGPL-3.0

--- A common library of setter functions which can be used in the
-- set function for class properties.

local _t = {}

--- Force the new value to be a boolean.
-- Intended as the set hook of a dcsext.class managed property,
-- called back with (self, key, newvalue, oldvalue), unused hook
-- arguments are ignored.
-- @param _ unused class instance hook argument
-- @param _ unused property key hook argument
-- @param new value assigned to the property
-- @return the boolean interpretation of new
function _t.setBoolean(_, _, new)
	return dcsext.math.toBoolean(new)
end

--- Force the new value to be a number, if new cannot be converted to
-- a number return the old value.
-- Intended as the set hook of a dcsext.class managed property,
-- called back with (self, key, newvalue, oldvalue), unused hook
-- arguments are ignored.
-- @param _ unused class instance hook argument
-- @param _ unused property key hook argument
-- @param new value assigned to the property
-- @param old previous value, returned when new is not convertible
-- @return new as a number or old when new is not convertible
function _t.setNumber(_, _, new, old)
	local v = tonumber(new)

	if v == nil then
		return old
	end
	return v
end

--- Force the new value to be a string, if new cannot be converted to
-- a string return the old value.
-- Intended as the set hook of a dcsext.class managed property,
-- called back with (self, key, newvalue, oldvalue), unused hook
-- arguments are ignored.
-- @param _ unused class instance hook argument
-- @param _ unused property key hook argument
-- @param new value assigned to the property
-- @param old previous value, returned when new is not convertible
-- @return new as a string or old when new is not convertible
function _t.setString(_, _, new, old)
	local v = tostring(new)

	if v == nil then
		return old
	end
	return v
end

--- Check that new exists as a value in tbl. If new doesn't exist return
-- old otherwise return new.
-- Intended as the set hook of a dcsext.class managed property, tbl
-- holds the valid values and the remaining arguments are the property
-- hook callback arguments (self, key, newvalue, oldvalue).
-- @param tbl table of valid values checked against
-- @param _ unused class instance hook argument
-- @param _ unused property key hook argument
-- @param new value assigned to the property
-- @param old previous value, returned when new is not found in tbl
-- @return new when found in tbl otherwise old
function _t.setValFromTable(tbl, _, _, new, old)
	if dcsext.table.getKey(tbl, new) == nil then
		return old
	end
	return new
end

return _t
