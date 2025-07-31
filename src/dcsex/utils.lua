-- SPDX-License-Identifier: LGPL-3.0

local mytable = require("dcsex.table")
local _t = {}

--- Override metamethods in `cls` with methods defined in `mt`.
function _t.override_ops(cls, mt)
	local curmt = mytable.merge({}, cls.__mt)
	curmt = mytable.merge(curmt, mt)
	cls.__mt = curmt
	return cls
end

return _t
