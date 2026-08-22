-- SPDX-License-Identifier: LGPL-3.0

--- terrain - exposes some functions of the DCS Terrain class.

local Terrain = require("terrain")

local _t = {}

--- Thin wrapper around the DCS Terrain.GetTerrainConfig method, returns
-- the current terrain configuration table.
_t.getConfig  = Terrain.GetTerrainConfig
--- Thin wrapper around the DCS Terrain.getRadio method, exposes
-- radio/navaid data for the terrain.
_t.getRadio   = Terrain.getRadio
--- Thin wrapper around the DCS Terrain.getBeacons method, returns the list
-- of navigation beacons defined by the terrain.
_t.getBeacons = Terrain.getBeacons
--- Unimplemented stub; the DCS Terrain class does not expose town data yet.
-- Need some way to get access to the towns table at
-- <DCS>/Mods/terrains/Caucasus/Map/towns.lua
_t.getTowns   = function() end -- don't know if the Terrain class gives access
			       -- to town data

return _t
