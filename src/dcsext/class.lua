-- SPDX-License-Identifier: LGPL-3.0

--- Class - creates tables that emulate properties of a class.

local mytable = require("dcsext.table")

--- Create a table object that emulates properties of a class.
-- The returned class table is instantiated by calling it,
-- `newobj = obj(...)`. Instantiation shallow copies the class into
-- a new instance, deep copies any registered properties, then runs
-- "\_\_init" if the class defines one.
--
-- Inheritance emulates java like single inheritance: only the
-- `base` argument forms the inheritance chain tracked by super()
-- and isa(). Additional classes passed via `...` act like java
-- interfaces, their methods are merged into the new class but are
-- not part of the inheritance chain. Merged keys overwrite existing
-- ones so later arguments take precedence over earlier arguments
-- and over `base`. Since instance data is shallow copied every
-- class must create its instance variables in its \_\_init(),
-- thus when inheriting from multiple sources \_\_init must call
-- each base class's \_\_init explicitly, similar to python 2.0
-- classes.
--
-- Managed properties can be defined inside \_\_init() using
-- _property(), they behave like regular fields but route access
-- through optional setter and notification hooks.
--
-- All methods and instance data are visible and are regular lua
-- table entries. There is no concept of data protection like
-- private, as in C++, so care must be taken to not modify a
-- class's data outside of its methods unless the data is intended
-- to be public. A convention to identify private data and methods
-- is to prefix these field names with '\_'.
--
-- @param name name of the class
-- @param base the base class this new class should inherit from
-- @param ... additional base classes to merge methods from,
-- keys from these classes override keys defined by earlier ones
-- @return a class like object table
local function class(name, base, ...)
	local newcls = mytable.shallowCopy(base or {})

	for i = 1, select('#', ...) do
		newcls = mytable.merge(newcls,
			mytable.shallowCopy(select(i, ...) or {}))
	end
	if base ~= nil and base.__mt ~= nil then
		newcls.__mt = mytable.shallowCopy(base.__mt)
	else
		newcls.__mt = nil
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
		-- classes stringify as class(<name>)
		__tostring = function(cls)
			return string.format("class(%s)", cls.__clsname)
		end
	}

	-- property definitions (value, set, setAfter) stored here
	newcls._props = newcls._props or {}

	--- Return the base class this class inherits from.
	-- @return the base class table or nil if the class has no base
	function newcls:super()
		return base
	end

	--- Test if this class inherits from another class.
	-- Only walks the single inheritance chain, classes passed as
	-- additional bases (interfaces) are not tracked.
	-- @param other the class to test against
	-- @return boolean, true means this class is derived from other
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

	--- Register a managed property on the instance.
	-- Properties behave like regular fields but are stored in the
	-- internal `_props` table, keeping the property hooks (see the
	-- instance metatable) active for that key. Must be called from
	-- \_\_init() so every instance gets its own copy of the
	-- property value.
	-- @param propName name of the property
	-- @param value initial value of the property
	-- @param set optional setter hook called before the value is
	-- stored, signature `set(self, key, newvalue, oldvalue)`, its
	-- return value is what gets stored
	-- @param setAfter optional notification hook invoked after the
	-- new value is stored, signature
	-- `setAfter(self, key, value, oldvalue)`
	function newcls:_property(propName, value, set, setAfter)
		local props = rawget(self, "_props")
		props[propName] = {
			["value"] = value
		}

		if set ~= nil and type(set) == "function" then
			self._props[propName].set = set
		end

		if setAfter ~= nil and type(setAfter) == "function" then
			self._props[propName].setAfter = setAfter
		end
	end

	newcls.__clsname = name or tostring(newcls)
	if newcls.__mt == nil then
		newcls.__mt = {
			-- instances stringify as instance(<name>) by default,
			-- may be overridden through the class's __mt table
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
