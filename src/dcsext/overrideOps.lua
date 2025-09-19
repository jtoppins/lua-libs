-- SPDX-License-Identifier: LGPL-3.0

local mytable = require("dcsext.table")

--- Override metamethods in `cls` with methods defined in `mt`.
local function overrideOps(cls, mt)
	local curmt = mytable.merge(cls.__mt or {}, mt)
	cls.__mt = curmt
	return cls
end

return overrideOps
