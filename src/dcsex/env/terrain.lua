-- SPDX-License-Identifier: LGPL-3.0

--- terrain - exposes some functions of the DCS Terrain class.

local Terrain = require("terrain")

local _t = {}

_t.getConfig  = Terrain.GetTerrainConfig
_t.getRadio   = Terrain.getRadio
_t.getBeacons = Terrain.getBeacons
-- Need some way to get access to the towns table at
-- <DCS>/Mods/terrains/Caucasus/Map/towns.lua
_t.getTowns   = function() end -- don't know if the Terrain class gives access
			       -- to town data

return _t
