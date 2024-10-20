-- SPDX-License-Identifier: LGPL-3.0

local pkgname = "libs"

if _G[pkgname] ~= nil then
	error(string.format("package: `%s` already exists, not loading package",
		pkgname))
end

local _G   = _G
local libs = {
	_VERSION     = "1",
	_DESCRIPTION = "libs: general functions that most common languages have",
	_COPYRIGHT   = "Copyright (c) 2019 Jonathan Toppins",
	algorithms   = require("libs.algorithms"),
	check        = require("libs.check"),
	class        = require("libs.class"),
	classnamed   = require("libs.classnamed"),
	containers   = require("libs.containers"),
	IAUS         = require("libs.IAUS"),
	json         = require("libs.json"),
	utils        = require("libs.utils"),
}

_G[pkgname] = libs
return libs
