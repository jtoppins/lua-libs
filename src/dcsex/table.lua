-- SPDX-License-Identifier: LGPL-3.0

--- Table - extensions to lua tables.

local _t = {}

_t.iterators = {}

--- Iterate a set of objects and return objects that have a given method.
-- @param tbl the table of objects whos keys do not matter and
-- whos values are the objects to be checked if the object implements
-- the optional `func` function.
-- @param iterator callback to iterate over tbl, used in for loop.
-- @param func the name of the function to check for and execute
-- if exists.
function _t.iterators.hasFunc(tbl, iterator, func)
	local itr, state, start = iterator(tbl)
	local function fnext(s, index)
		local idx = index
		local sys
		repeat
			idx, sys = itr(s, idx)
			if sys == nil then
				return nil
			end
		until(type(sys[func]) == "function")
		return idx, sys
	end
	return fnext, state, start
end

--- Create an iterator over a table using sorted keys.
-- @param tbl The table to iterate over
-- @param order optional function to sort tbl keys with
-- @return an iterator to be used in the generic for loop
function _t.iterators.sortedPairs(tbl, order)
	local index = 1
	local keys = _t.getKeys(tbl)

	table.sort(keys, order)
	local function iterator()
		local key = keys[index]
		if key ~= nil then
			index = index + 1
			return key, tbl[key]
		else
			return nil
		end
	end
	return iterator, tbl, index
end

--- Returns true if table tbl contains value val.
-- @param tbl table to search
-- @param val value to look for
-- @return True if table contains val, false otherwise
function _t.contains(tbl, val)
	if not tbl then
		return false
	end

	for k, v in pairs(tbl) do
		if v == val then
			return true, k
		end
	end
	return false
end

--- Create a deep copy of obj where all tables referenced by obj
-- are also copied. This is an expensive operation.
-- @param obj the object to copy
-- @return A deep copy of obj
function _t.deepCopy(obj)
	local obj_type = type(obj)
	local copy

	if obj_type == 'table' then
		copy = {}
		for k,v in next, obj, nil do
			copy[k] = _t.deepCopy(v)
		end
	else
		copy = obj
	end
	return copy
end

--- Calls an optional function for a set of objects defined in tbl.
-- @param tbl the table of objects whos keys do not matter and
-- whos values are the objects to be checked if the object implements
-- the optional `func` function.
-- @param iterator callback to iterate over tbl, used in for loop.
-- @param func the name of the function to check for and execute
-- if exists.
function _t.foreachCall(tbl, iterator, func, ...)
	dcsex.check.table(tbl)
	dcsex.check.func(iterator)

	for _, obj in _t.iterators.hasFunc(tbl, iterator, func) do
		obj[func](obj, ...)
	end
end

--- Call an optional function for a set of objects defined in tbl
-- in a protected context.
-- @param tbl the table of objects whos keys do not matter and whos
--    values are the objects to be checked if the object implements
--    the optional `func` function.
-- @param iterator callback to iterate over tbl, used in for loop.
-- @param func the name of the function to check for and execute if
--    exists.
-- @param logger to report errors.
function _t.foreachProtectedCall(tbl, iterator, func, logger, ...)
	dcsex.check.table(tbl)
	dcsex.check.func(iterator)
	dcsex.check.string(func)
	dcsex.check.table(logger)

	local ok, errmsg

	for _, obj in _t.iterators.hasFunc(tbl, iterator, func) do
		logger:debug("calling: %s.%s", tostring(obj), func)
		ok, errmsg = pcall(obj[func], obj, ...)
		if not ok then
			dcsex.env.errhandler(errmsg, logger, 2)
		end
	end
end

--- Find the table key assiciated with val. If val not found
-- return nil.
-- @param tbl the table to search
-- @param val the value to find
-- @return The key associated with val in the table or nil
function _t.getKey(tbl, val)
	tbl = tbl or {}
	for k, v in pairs(tbl) do
		if v == val then
			return k
		end
	end
	return nil
end

--- Return all keys in table tbl.
-- @param tbl the table to pull keys from
-- @return array of keys from tbl
function _t.getKeys(tbl)
	local keys = {}

	for k, _ in pairs(tbl) do
		table.insert(keys, k)
	end
	return keys
end

--- Merge two tables, source and dest, where the keys and values from
-- source will overwrite any same keys in dest with the value from
-- source. Note the values in source are not deep copied.
-- @param dest the table keys/values from source will be saved to
-- @param source table of key/values to copy
-- @return a table of merged keys/values
function _t.merge(dest, source)
	if type(dest) ~= "table" then
		return nil
	end

	for k, v in pairs(source or {}) do
		dest[k] = v
	end
	return dest
end

--- Create a shallow copy of obj, tables referenced by obj will
-- be referenced in the new table as well.
-- @param obj the object to clone
-- @return a new table that is a copy of obj
function _t.shallowCopy(obj)
	local obj_type = type(obj)
	local copy

	if obj_type == 'table' then
		copy = {}
		for k,v in pairs(obj) do
			copy[k] = v
		end
	else
		copy = obj
	end
	return copy
end

return _t
