-- Terrain class
--- Provides functions for accessing info about the currently loaded
--- terrain. This class is not directly accessible via the mission
--- environment. Do `local Terrain = require("terrain")` to gain
--- access to the class before sanitization.
--- @class Terrain
local Terrain = {}

--- Get some config information about the loaded terrain. Some of the
-- cfg strings that can be used are:
-- "id" - gets the map name
-- "SummerTimeDelta" - gets the map timezone, likely the daylight
--    savings offset
-- "Airdromes" - presumably returns airbase info for the map
--       airbaseinfo = {
--       }
-- @param cfgstr string Name of the configuration element of the loaded
-- terrain.
-- @return variable depending on the config entry requested
function Terrain.GetTerrainConfig(cfgstr) end

--- Get radio frequency information of airdromes on the loaded map,
-- used in <DCS>/Scripts/UI/BriefingDialog.lua.
-- @return radio info table, probably looks a lot like
-- <DCS>/Mods/terrains/Caucasus/Radio.lua
function Terrain.getRadio() end

--- Get the maps radio beacons built into the map, used in
-- <DCS>/Scripts/UI/DTC_manager/DTC_manager_PanelCommon.lua.
-- @return beacon table, probably looks a lot like
-- <DCS>/Mods/terrains/Caucasus/Beacons.lua
function Terrain.getBeacons() end

--- Get the heigh if a map position.
-- @param x the x coordinate
-- @param y the y coordinate
-- @return terrain height in meters, a negative value represents
-- below sea level.
function Terrain.GetHeight(x, y) end

--- Convert DCS coordinates to lat/long
-- @param x the x coordinate of a Vec3
-- @param z the z coordinate of a Vec3, because DCS uses a rotated
-- right-hand rule coordinate system where the 'y' axis represents
-- altitude
-- @return two tuple: number (latitude), number (longitude)
function Terrain.convertMetersToLatLong(x, z) end

-- There is also an MGRS conversion function, GetMGRScoordinates(x, z),
-- but this seems redundant as these are already exposed via the
-- coords singleton.

return Terrain
