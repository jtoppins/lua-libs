-- SPDX-License-Identifier: LGPL-3.0

--- Load script modules into the mission environment before it is sanatized.

local sep      = package.config:sub(1,1)
local libspath = table.concat({lfs.writedir(), "Scripts", "mission"}, sep)
local pkgpath  = table.concat({libspath, "?.lua"}, sep)

if lfs.attributes(libspath) == nil then
	error(("libs path not found: %s"):format(libspath))
end

package.path = table.concat({package.path, pkgpath}, ";")
require("dcsext")

local function loadplugins(cfgfile)
	local plugins = dcsext.io.readLua(cfgfile, "plugins")

	for _, plugin in ipairs(plugins) do
		require(plugin)
	end
end

local cfgfile = dcsext.io.joinPaths(lfs.writedir(),
				   "Config",
				   "missionplugins.cfg")
loadplugins(cfgfile)
