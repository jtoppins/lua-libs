#!/usr/bin/lua

require 'busted.runner'()
require("dcsext")

describe("validate dcsext.tacan", function()
	test("API", function()
		local t = dcsext.tacan.decode("35A")
		assert.is.equal(t, nil)

		t = dcsext.tacan.decode("59X QJ")
		assert.is.equal(t.channel, 59)
		assert.is.equal(t.mode, "X")
		assert.is.equal(t.callsign, "QJ")
		assert.is.equal(t.frequency, 1020000000)

		t = dcsext.tacan.decode("126Y TKR")
		assert.is.equal(t.channel, 126)
		assert.is.equal(t.mode, "Y")
		assert.is.equal(t.callsign, "TKR")

		t = dcsext.tacan.decode("128X")
		assert.is.equal(t, nil)

		t = dcsext.tacan.decode("73X GW")
		assert.is.equal(t.channel, 73)
		assert.is.equal(t.mode, "X")
		assert.is.equal(t.callsign, "GW")
		assert.is.equal(t.frequency, 1160000000)

		t = dcsext.tacan.decode("16Y")
		assert.is.equal(t.channel, 16)
		assert.is.equal(t.mode, "Y")
		assert.is.equal(t.callsign, nil)
		assert.is.equal(t.frequency, 1103000000)
	end)

	test("tasks", function()
		local task = dcsext.ai.commands.createTACAN(nil, "TST", 73,
			dcsext.enum.BEACON.TACANMODE.X, "test", false,
			false, true)
		assert.are.same(task, {
			["id"] = "ActivateBeacon",
			["params"] = {
				["type"] = dcsext.enum.BEACON.TYPE.TACAN,
				["system"] = dcsext.enum.BEACON.SYSTEM.TACAN_MOBILE_MODE_X,
				["frequency"] = 1160000000,
				["callsign"] = "TST",
				["name"] = "test",
				["channel"] = 73,
				["modeChannel"] = dcsext.enum.BEACON.TACANMODE.X,
			},
		})
	end)
end)
