#!/usr/bin/lua

require 'busted.runner'()
require("dcsext")

describe("validate dcsext.ai", function()
	local vector = dcsext.vector
	local ai = dcsext.ai

	test("tasks", function()
		local task = dcsext.ai.options.create(
				AI.Option.Air.id.REACTION_ON_THREAT,
				AI.Option.Air.val.REACTION_ON_THREAT.PASSIVE_DEFENCE)
		assert.are.same(task, {
			["id"] = AI.Option.Air.id.REACTION_ON_THREAT,
			["params"] = AI.Option.Air.val.REACTION_ON_THREAT.PASSIVE_DEFENCE,
		})

		local wpt1 = ai.Waypoint(vector.Vec3.new(5, 2000, 10),
			AI.Task.WaypointType.TAKEOFF, nil, 200, "Takeoff")
		wpt1:addTask(
			ai.options.create(AI.Option.Air.id.REACTION_ON_THREAT,
				AI.Option.Air.val.REACTION_ON_THREAT.PASSIVE_DEFENCE))
		wpt1:addTask(ai.commands.eplrs(true))

		local wpt2 = ai.Waypoint(vector.Vec3.new(100, 1000, -430),
			AI.Task.WaypointType.TURNING_POINT, nil, 200, "Ingress")
		wpt2:addTask(ai.tasks.orbit(AI.Task.OrbitPattern.RACE_TRACK, {
			point  = vector.Vec2.new(100, -450),
			point2 = vector.Vec2.new(400, -600),
			speed  = 190,
			altitude = 6500,
		}))
		wpt2:addTask(ai.tasks.tanker())
		local route = ai.Route(true, {wpt1, wpt2})
		assert.are.same(route:get(), {
			["id"] = "Mission",
			["params"] = {
				["airborne"] = true,
				["route"] = {
					["points"] = {
						{
							["ETA_locked"] = false,
							["action"] = "From Runway",
							["alt"] = 2000,
							["alt_type"] = "BARO",
							["name"] = "Takeoff",
							["speed"] = 200,
							["speed_locked"] = true,
							["type"] = "TakeOff",
							["x"] = 5,
							["y"] = 10,
							["task"] = {
								["id"] = "ComboTask",
								["params"] = {
									{
										["id"] = "WrappedAction",
										["params"] = {
											["action"] = {
												["id"] = "Option",
												["params"] = {
													["name"] = AI.Option.Air.id.REACTION_ON_THREAT,
													["value"] = AI.Option.Air.val.REACTION_ON_THREAT.PASSIVE_DEFENCE,
												},
											},
										},
									}, {
										["id"] = "WrappedAction",
										["params"] = {
											["action"] = {
												["id"] = "EPLRS",
												["params"] = {
													["value"] = true,
												},
											},
										},
									},
								},
							},
						}, {
							["ETA_locked"] = false,
							["action"] = "Turning Point",
							["alt"] = 1000,
							["alt_type"] = "BARO",
							["name"] = "Ingress",
							["speed"] = 200,
							["speed_locked"] = true,
							["type"] = "Turning Point",
							["x"] = 100,
							["y"] = -430,
							["task"] = {
								["id"] = "ComboTask",
								["params"] = {
									{
										["id"] = "Orbit",
										["params"] = {
											["altitude"] = 6500,
											["pattern"] = "Race-Track",
											["point"] = {
												["x"] = 100,
												["y"] = -450,
											},
											["point2"] = {
												["x"] = 400,
												["y"] = -600,
											},
											["speed"] = 190,
										},
									}, {
										["id"] = "Tanker",
										["params"] = {},
									},
								},
							},
						},
					},
				},
			},
		})
	end)
end)
