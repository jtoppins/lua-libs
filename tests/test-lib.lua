#!/usr/bin/lua
require("os")
require("libs")

local function test()
	assert(_G["libs"] ~= nil)
	assert(libs.class ~= nil)
end
os.exit(test())
