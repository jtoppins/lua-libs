#!/usr/bin/lua

local class = require("libs.namedclass")
local goap = require("libs.containers.goap")

local ID = {
	["INAIR"]       = "inAir",       -- <bool>
	["ISARMED"]     = "isArmed",     -- <bool>
	["HASFUEL"]     = "hasFuel",     -- <bool>
	["HASCARGO"]    = "hasCargo",    -- <bool>
	["HASTARGET"]   = "hasTarget",   -- <bool>
	["TARGETDEAD"]  = "targetDead",  -- <bool>
	["ATTARGET"]    = "atTarget",    -- <bool>
	["ATNODE"]      = "atNode",      -- <bool>
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
	class("SensorsOn", goap.Action)(nil, {}, {
		goap.Property(ID.SENSORSON, true),
	}),
	class("SensorsOff", goap.Action)(nil, {}, {
		goap.Property(ID.SENSORSON, false),
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
}

local Test = class("Test")
function Test:__init(ws, goal, a, plan, cost)
	self.worldstate = ws
	self.goal = goal
	self.actions = a
	self.expectedplan = plan
	self.expectedcost = cost
end

local tests = {
	Test(
		goap.WorldState({
			goap.Property(ID.INAIR, false),
			goap.Property(ID.ISARMED, false),
			goap.Property(ID.HASFUEL, true),
			goap.Property(ID.HASCARGO, false),
			goap.Property(ID.TARGETDEAD, false),
			goap.Property(ID.ATTARGET, false),
			goap.Property(ID.ATNODE, true),
			goap.Property(ID.STANCE, Stances.IDLE),
			goap.Property(ID.SENSORSON, false),}),
		goap.WorldState({
			goap.Property(ID.TARGETDEAD, true),}),
		actions,
		{"Attack", "RequestRearm", "SensorsOn", "Alert"},
		4),
	Test(
		goap.WorldState({
			goap.Property(ID.INAIR, false),
			goap.Property(ID.ISARMED, true),
			goap.Property(ID.HASFUEL, true),
			goap.Property(ID.HASCARGO, false),
			goap.Property(ID.TARGETDEAD, false),
			goap.Property(ID.ATTARGET, false),
			goap.Property(ID.ATNODE, true),
			goap.Property(ID.STANCE, Stances.IDLE),
			goap.Property(ID.SENSORSON, false),}),
		goap.WorldState({goap.Property(ID.TARGETDEAD, true),}),
		actions,
		{"Attack", "SensorsOn", "Alert"},
		3),
	Test(
		goap.WorldState({
			goap.Property(ID.INAIR, false),
			goap.Property(ID.ISARMED, true),
			goap.Property(ID.HASFUEL, true),
			goap.Property(ID.HASCARGO, false),
			goap.Property(ID.TARGETDEAD, false),
			goap.Property(ID.ATTARGET, false),
			goap.Property(ID.ATNODE, true),
			goap.Property(ID.STANCE, Stances.IDLE),
			goap.Property(ID.SENSORSON, false),}),
		goap.WorldState({
			goap.Property(ID.SENSORSON, true),
			goap.Property(ID.ATNODE, true),
			goap.Property(ID.STANCE, Stances.RELAX),}),
		actions,
		{"SensorsOn", "Relax"},
		2),
	Test(
		goap.WorldState({
			goap.Property(ID.INAIR, false),
			goap.Property(ID.ISARMED, true),
			goap.Property(ID.HASFUEL, true),
			goap.Property(ID.HASCARGO, false),
			goap.Property(ID.TARGETDEAD, false),
			goap.Property(ID.ATTARGET, false),
			goap.Property(ID.ATNODE, true),
			goap.Property(ID.STANCE, Stances.IDLE),
			goap.Property(ID.SENSORSON, false),}),
		goap.WorldState({goap.Property(ID.HASCARGO, true),}),
		actions,
		nil, -- no plan possible given actions
		nil),
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

local function main()
	local prop = goap.Property(ID.ATNODE, true)
	local prop_copy = prop:copy()
	assert(prop_copy == prop)
	prop.value = false
	assert(prop_copy ~= prop)

	for _, test in ipairs(tests) do
		local _, plan, cost = goap.find_plan(
			goap.Graph({}, test.actions),
			test.worldstate,
			test.goal)
		check(test, plan, cost)
	end
end

os.exit(main())
