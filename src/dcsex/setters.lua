-- SPDX-License-Identifier: LGPL-3.0

--- A common library of setter functions which can be used in the
-- set function for class properties.

local _t = {}

--- Force the new value to be a boolean.
function _t.setBoolean(_, _, new)
	return dcsex.math.toBoolean(new)
end

--- Force the new value to be a number, if new cannot be converted to
-- a number return the old value.
function _t.setNumber(_, _, new, old)
	local v = tonumber(new)

	if v == nil then
		return old
	end
	return v
end

--- Force the new value to be a string, if new cannot be converted to
-- a string return the old value.
function _t.setString(_, _, new, old)
	local v = tostring(new)

	if v == nil then
		return old
	end
	return v
end

--- Check that new exists as a value in tbl. If new doesn't exist return
-- old otherwise return new.
function _t.setValFromTable(tbl, _, _, new, old)
	if dcsex.table.getKey(tbl, new) == nil then
		return old
	end
	return new
end

return _t
