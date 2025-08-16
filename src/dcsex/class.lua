-- SPDX-License-Identifier: LGPL-3.0

local mytable = require("dcsex.table")

--- Return a table object (`obj`) that emulates properties of a class.
-- If the table defines an entry "__init" that is a function,
-- __init will be run when new instances are created.
-- A new instance of `obj` can be created by calling `newobj = obj()`.
-- Multiple inheritance is not tracked, thus this emulates java like
-- inhertiance where there is single inheritance but allows for
-- multiple interfaces to be inherited.
-- Since all data is shallow copied all class instances must create
-- their instances variables in their __init(). Thus if a class
-- inherits from multiple classes its __init much call each base class's
-- __init function, similar to python 2.0 classes.
-- All methods and instance data is visiable and are regular lua table
-- entries. There is no concept of data protection like private,
-- as in C++, so care must be taken to not modify a class's date
-- outside of its methods unless the data is intended to be public.
-- A convention to identify private data and methods is to prefix
-- these field names with '_'.
--
-- @param name name of the class
-- @param base the base class this new class should inherit from
-- @param ... additional base classes to inherit methods from
-- @return a class like object table
local function class(name, base, ...)
	local newcls = mytable.shallowCopy(base or {})

	for i = 1, select('#', ...) do
		newcls = mytable.merge(newcls,
			mytable.shallowCopy(select(i, ...) or {}))
	end

	local cls_mt = {
		-- allow new object to be created directly,
		-- example: o = Object()
		__call = function(cls, ...)
			local c = mytable.shallowCopy(cls)
			c._props = mytable.deepCopy(newcls._props)
			c.__mt = nil
			if cls.__mt ~= nil then
				setmetatable(c, cls.__mt)
			end
			if type(c.__init) == "function" then
				c.__init(c, ...)
			end
			return c
		end,
		__tostring = function(cls)
			return string.format("class(%s)", cls.__clsname)
		end
	}

	-- All property setter information stored here
	newcls._props = newcls._props or {}

	function newcls:super()
		return base
	end

	function newcls:isa(other)
		local b_isa = false
		local cur_class = newcls

		while nil ~= cur_class and false == b_isa do
			if cur_class == other then
				b_isa = true
			else
				cur_class = cur_class:super()
			end
		end
		return b_isa
	end

	function newcls:_property(propName, value, set, setAfter)
		local props = rawget(self, "_props")
		props[propName] = {
			["value"] = value
		}

		if set ~= nil and type(set) == "function" then
			self._props[propName].set = set
		end

		if setAfter ~= nil and type(set) == "function" then
			self._props[propName].setAfter = setAfter
		end
	end

	newcls.__clsname = name or tostring(newcls)
	if newcls.__mt == nil then
		newcls.__mt = {
			__tostring = function(c)
				return string.format("instance(%s)",
					c.__clsname)
			end,

			-- Support generic getters for class properties.
			-- Called when `key` doesn't exist in `self`. This
			-- means if `key` doesn't exist in the props table
			-- we can return nil otherwise return any value
			-- stored in `self._props[key].value`.
			__index = function(self, key)
				local props = rawget(self, "_props")
				local pt = props[key]

				if pt == nil then
					return nil
				end
				return pt.value
			end,

			-- Support setters for class properties.
			-- Called when `key` doesn't exist in `self`. This
			-- means `key` is a property we need to store its
			-- value in the _props table so that __index will
			-- continue to get called.
			__newindex = function(self, key, value)
				local props = rawget(self, "_props")
				local pt = props[key]

				if pt ~= nil then
					local oldval = pt.value

					if pt.set ~= nil then
						value = pt.set(self, key,
							value, oldval)
					end

					pt.value = value

					if pt.setAfter ~= nil then
						pt.setAfter(self, key,
							    value, oldval)
					end
				else
					-- not a property bypass __newindex
					rawset(self, key, value)
				end
			end,
		}
	end
	setmetatable(newcls, cls_mt)
	return newcls
end

return class
