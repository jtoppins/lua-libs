#!/usr/bin/lua
require('busted.runner')()
require("dcsex")
local class = dcsex.classnamed
local goap = dcsex.containers.GOAP

local ID = {
	["ISARMED"]     = "isArmed",     -- <bool>
	["HASFUEL"]     = "hasFuel",     -- <bool>
	["HASCARGO"]    = "hasCargo",    -- <bool>
	["HASTARGET"]   = "hasTarget",   -- <bool>
	["TARGETDEAD"]  = "targetDead",  -- <bool>
	["ATTARGET"]    = "atTarget",    -- <handle>
	["ATNODE"]      = "atNode",      -- <handle>
	["STANCE"]      = "stance",      -- <enum>
	["SENSORSON"]   = "sensorsOn",   -- <bool>
}

local Stances = {
	["IDLE"]  = "idle",
	["FLEE"]  = "flee",
	["RELAX"] = "relax",
	["ALERT"] = "alert",
}

local actions = {
	class("SensorsSet", goap.Action)(nil, {}, {
		goap.Property(ID.SENSORSON, goap.Property.ANYHANDLE),
	}),
	class("Hide", goap.Action)(nil, {
		goap.Property(ID.SENSORSON, false),
	}, {
		goap.Property(ID.STANCE, Stances.FLEE),
	}),
	class("Alert", goap.Action)(nil, {
		goap.Property(ID.SENSORSON, true),
	}, {
		goap.Property(ID.STANCE, Stances.ALERT),
	}),
	class("Relax", goap.Action)(nil, {
		goap.Property(ID.SENSORSON, true),
	}, {
		goap.Property(ID.STANCE, Stances.RELAX),
	}),
	class("Idle", goap.Action)(nil, {}, {
		goap.Property(ID.STANCE, Stances.IDLE),
	}),
	class("Attack", goap.Action)(nil, {
		goap.Property(ID.STANCE, Stances.ALERT),
		goap.Property(ID.ISARMED, true),
		goap.Property(ID.SENSORSON, true),
	}, {
		goap.Property(ID.TARGETDEAD, true),
	}),
	class("RequestRearm", goap.Action)(nil, {
		goap.Property(ID.SENSORSON, false),
	}, {
		goap.Property(ID.ISARMED, true),
	}),
	class("GotoNode", goap.Action)(nil, {}, {
		goap.Property(ID.ATNODE, goap.Property.ANYHANDLE),
	}),
}

local Test = class("Test")
function Test:__init(ws, goal, a, plan, cost)
	self.worldstate = ws
	self.goal = goal
	self.actions = a
	self.expectedplan = plan
	self.expectedcost = cost
end

local nodea = {}
local nodeb = {}

local tests = {
	Test(
		goap.WorldState({
			goap.Property(ID.ISARMED, false),
			goap.Property(ID.HASFUEL, true),
			goap.Property(ID.HASCARGO, false),
			goap.Property(ID.TARGETDEAD, false),
			goap.Property(ID.ATTARGET, nil),
			goap.Property(ID.ATNODE, nil),
			goap.Property(ID.STANCE, Stances.IDLE),
			goap.Property(ID.SENSORSON, false),}),
		goap.WorldState({
			goap.Property(ID.TARGETDEAD, true),}),
		actions,
		{"Attack", "RequestRearm", "SensorsSet", "Alert"},
		4),
	Test(
		goap.WorldState({
			goap.Property(ID.ISARMED, true),
			goap.Property(ID.HASFUEL, true),
			goap.Property(ID.HASCARGO, false),
			goap.Property(ID.TARGETDEAD, false),
			goap.Property(ID.ATTARGET, nil),
			goap.Property(ID.ATNODE, nil),
			goap.Property(ID.STANCE, Stances.IDLE),
			goap.Property(ID.SENSORSON, false),}),
		goap.WorldState({goap.Property(ID.TARGETDEAD, true),}),
		actions,
		{"Attack", "SensorsSet", "Alert"},
		3),
	Test(
		goap.WorldState({
			goap.Property(ID.ISARMED, true),
			goap.Property(ID.HASFUEL, true),
			goap.Property(ID.HASCARGO, false),
			goap.Property(ID.TARGETDEAD, false),
			goap.Property(ID.ATTARGET, nil),
			goap.Property(ID.ATNODE, nil),
			goap.Property(ID.STANCE, Stances.IDLE),
			goap.Property(ID.SENSORSON, false),}),
		goap.WorldState({
			goap.Property(ID.SENSORSON, true),
			goap.Property(ID.STANCE, Stances.RELAX),}),
		actions,
		{"SensorsSet", "Relax"},
		2),
	Test(
		goap.WorldState({
			goap.Property(ID.ISARMED, true),
			goap.Property(ID.HASFUEL, true),
			goap.Property(ID.HASCARGO, false),
			goap.Property(ID.TARGETDEAD, false),
			goap.Property(ID.ATTARGET, nil),
			goap.Property(ID.ATNODE, nil),
			goap.Property(ID.STANCE, Stances.IDLE),
			goap.Property(ID.SENSORSON, false),}),
		goap.WorldState({goap.Property(ID.HASCARGO, true),}),
		actions,
		nil, -- no plan possible given actions
		nil),
	Test(
		goap.WorldState({
			goap.Property(ID.ISARMED, true),
			goap.Property(ID.HASFUEL, true),
			goap.Property(ID.HASCARGO, false),
			goap.Property(ID.TARGETDEAD, false),
			goap.Property(ID.ATTARGET, nil),
			goap.Property(ID.ATNODE, nodea),
			goap.Property(ID.STANCE, Stances.IDLE),
			goap.Property(ID.SENSORSON, false),}),
		goap.WorldState({goap.Property(ID.ATNODE, nodeb),}),
		actions,
		{"GotoNode",},
		1),
}

local function check(test, plan, cost)
	if test.expectedplan == nil and plan == nil then
		return
	end

	local empty = false
	if next(test.expectedplan) == nil then
		empty = true
	end
	if empty then
		assert(next(plan) == nil)
	else
		assert(next(plan) ~= nil)
	end
	assert(test.expectedcost == cost, "plan cost not correct")
	local p = {}
	for _, action in ipairs(plan) do
		table.insert(p, action.__clsname)
	end
	table.sort(test.expectedplan)
	table.sort(p)
	for k, v in ipairs(p) do
		assert(v == test.expectedplan[k],
		string.format("expected(%s), got(%s)",
			test.expectedplan[k], v))
	end
end

describe("containers.GOAP", function()
	test("tests", function()
		local prop = goap.Property(ID.ATNODE, true)
		local prop_copy = prop:copy()
		assert.is.equal(prop_copy, prop)
		prop.value = false
		assert(prop_copy ~= prop)

		for _, test in ipairs(tests) do
			local _, plan, cost = goap.find_plan(
				goap.Graph({}, test.actions),
				test.worldstate,
				test.goal)
			check(test, plan, cost)
		end
	end)
end)
