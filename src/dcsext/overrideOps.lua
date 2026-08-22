-- SPDX-License-Identifier: LGPL-3.0

--- OverrideOps - override metamethods of a class after creation.
-- Useful to swap or extend class behavior at runtime without touching
-- the class definition itself.

local mytable = require("dcsext.table")

--- Merge the methods defined in `mt` over the metatable of `cls`.
-- @function overrideOps
-- @param cls a class created by dcsext.class.
-- @param mt table of metamethod implementations merged over the class
-- metatable(cls.\_\_mt), entries in mt win over existing ones.
-- @return cls so calls can be chained.
local function overrideOps(cls, mt)
	local curmt = mytable.merge(cls.__mt or {}, mt)
	cls.__mt = curmt
	return cls
end

return overrideOps
