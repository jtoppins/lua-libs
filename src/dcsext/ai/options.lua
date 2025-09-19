-- SPDX-License-Identifier: LGPL-3.0

--- DCS AI options.

local _t = {}

--- Create an option task table.
-- @param optid the option ID, from AI.Option.*.id.*
-- @param value option approperate value to set the option to
-- @return table, dcsext.enum.TASKTYPE.OPTION
function _t.create(optid, value)
	dcsext.check.number(optid)
	assert(value ~= nil,
		string.format("value error: value is nil for optid(%d)",
			optid))
	return dcsext.ai.exec.createTaskTbl(optid, value),
		dcsext.enum.TASKTYPE.OPTION
end

--- Constructs either a simple or advanced formation spec value which
-- can then be used in Controller:setOption and dcsext friends to
-- set the formation of an air group.
-- @param ftype formation type from dcsext.enum.FORMATION.TYPE
-- @param dist (optional) distance enum from
-- dcsext.enum.FORMATION.DISTANCE
-- @param side (optional) side enum from dcsext.enum.FORMATION.SIDE
-- @return table, dcsext.enum.TASKTYPE.OPTION
function _t.createAirFormation(ftype, dist, side)
	local base = 65536
	local formation = dcsext.check.tblkey(ftype,
					     dcsext.enum.FORMATION.TYPE,
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
	return dcsext.ai.exec.createTaskTbl('WrappedAction', params),
		dcsext.enum.TASKTYPE.TASK
end

return _t
