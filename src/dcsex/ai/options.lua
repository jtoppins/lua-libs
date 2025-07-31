-- SPDX-License-Identifier: LGPL-3.0

--- DCS AI options.

local _t = {}

--- Create an option task table.
-- @param optid the option ID, from AI.Option.*.id.*
-- @param value option approperate value to set the option to
-- @return table, dcsex.enum.TASKTYPE.OPTION
function _t.create(optid, value)
	dcsex.check.number(optid)
	assert(value ~= nil,
		string.format("value error: value is nil for optid(%d)",
			optid))
	return dcsex.ai.exec.createTaskTbl(optid, value),
		dcsex.enum.TASKTYPE.OPTION
end

--- Constructs either a simple or advanced formation spec value which
-- can then be used in Controller:setOption and dcsex friends to
-- set the formation of an air group.
-- @param ftype formation type from dcsex.enum.FORMATION.TYPE
-- @param dist (optional) distance enum from
-- dcsex.enum.FORMATION.DISTANCE
-- @param side (optional) side enum from dcsex.enum.FORMATION.SIDE
-- @return table, dcsex.enum.TASKTYPE.OPTION
function _t.createAirFormation(ftype, dist, side)
	local base = 65536
	local formation = dcsex.check.tblkey(ftype,
					     dcsex.enum.FORMATION.TYPE,
					     "enum.FORMATION.TYPE")
	side = side or 0

	if dist ~= nil then
		formation = (ftype * base) + dist + side
	end
	return _t.create(AI.Option.Air.id.FORMATION, formation)
end

--- Takes an options table from ai.options.create() and wraps the option
-- so it is able to be stuck into an advanced waypoint task list.
function _t.wrappedOption(optiontbl)
	local params = {}
	params.action = {
		["id"] = "Option",
		["params"] = {
			["value"] = optiontbl.params,
			["name"]  = optiontbl.id,
		},
	}
	return dcsex.ai.exec.createTaskTbl('WrappedAction', params),
		dcsex.enum.TASKTYPE.TASK
end

return _t
