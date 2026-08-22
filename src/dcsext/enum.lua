-- SPDX-License-Identifier: LGPL-3.0

--- Enum - DCS enumerations and constants not exposed via the mission
-- scripting environment, but necessary for library functions.

local _t = {}

--- Coalition sides extended with library specific entries.
-- Extends the DCS `coalition.side` enum with ALL (-1), ex used for the
-- scope of ui draw objects, and CONTESTED (3).
_t.coalition = {
	["ALL"]       = -1,
	["NEUTRAL"]   = coalition.side.NEUTRAL,
	["RED"]       = coalition.side.RED,
	["BLUE"]      = coalition.side.BLUE,
	["CONTESTED"] = 3,
}

-- TACAN constants used by dcsext.tacan
local tacan = {}
tacan.CHANNEL = {
	["MIN"] = 1,
	["MAX"] = 126,
}

tacan.GND = {
	["BASE_X"]   = 961,
	["BASE_Y"]   = 1087,
	["BASE_INV"] = 64,
}

--- TACAN related constants.
-- CHANNEL defines the valid TACAN channel number range (MIN/MAX), GND
-- holds the base channel numbers for X and Y mode ground stations
-- (BASE_X, BASE_Y) and the inversion offset (BASE_INV) needed to
-- encode/decode ground station channels.
_t.TACAN = tacan

--- Constants for DCS markup drawings used by the ui draw objects.
_t.MARKUP = {}

--- Line styles for markup drawings.
_t.MARKUP.LINETYPE = {
	["NOLINE"]   = 0,
	["SOLID"]    = 1,
	["DASHED"]   = 2,
	["DOTTED"]   = 3,
	["DOTDASH"]  = 4,
	["LONGDASH"] = 5,
	["TWODASH"]  = 6,
}

--- Shape identifiers for markup drawings.
_t.MARKUP.SHAPE = {
	["LINE"]     = 1,
	["CIRCLE"]   = 2,
	["RECT"]     = 3,
	["ARROW"]    = 4,
	["TEXT"]     = 5,
	["QUAD"]     = 6,
	["FREEFORM"] = 7,
}

--- Carrier controlled deck illumination modes.
-- OFF, AUTO or a specific flight operation: NAV, LAUNCH and RECOVERY.
_t.CARRIER_ILLUM_MODE = {
	["OFF"]      = -2,
	["AUTO"]     = -1,
	["NAV"]      = 0,
	["LAUNCH"]   = 1,
	["RECOVERY"] = 2,
}

--- Task entry types within a waypoint task table.
-- COMMAND wraps an EnRouteCommand, OPTION sets a controller option and
-- TASK assigns the main mission task.
_t.TASKTYPE = {
	["COMMAND"] = 1,
	["OPTION"]  = 2,
	["TASK"]    = 3,
}

--- Attack run types for bombing tasks.
_t.ATTACKTYPE = {
	["CARPET"] = "Carpet",
	["DIVE"]   = "Dive",
}

--- Radio beacon constants used with the DCS beacon commands.
_t.BEACON = {}

--- Beacon type identifiers, ex VOR, TACAN, ILS and ICLS stations.
_t.BEACON.TYPE = {
	["NULL"]                      = 0,
	["VOR"]                       = 1,
	["DME"]                       = 2,
	["VOR_DME"]                   = 3,
	["TACAN"]                     = 4,
	["VORTAC"]                    = 5,
	["HOMER"]                     = 8,
	["RSBN"]                      = 128,
	["BROADCAST_STATION"]         = 1024,
	["AIRPORT_HOMER"]             = 4104,
	["AIRPORT_HOMER_WITH_MARKER"] = 4136,
	["ILS_FAR_HOMER"]             = 16408,
	["ILS_NEAR_HOMER"]            = 16456,
	["ILS_LOCALIZER"]             = 16640,
	["ILS_GLIDESLOPE"]            = 16896,
	["PRMG_LOCALIZER"]            = 33024,
	["PRMG_GLIDESLOPE"]           = 33280,
	["ICLS_LOCALIZER"]            = 131328,
	["ICLS_GLIDESLOPE"]           = 131584,
	["NAUTICAL_HOMER"]            = 65536,
}

--- Navigation system identifiers for beacons.
_t.BEACON.SYSTEM = {
	["PAR_10"]              = 1,
	["RSBN_4H"]             = 2,
	["TACAN"]               = 3,
	["TACAN_TANKER_MODE_X"] = 4,
	["TACAN_TANKER_MODE_Y"] = 5,
	["VOR"]                 = 6,
	["ILS_LOCALIZER"]       = 7,
	["ILS_GLIDESLOPE"]      = 8,
	["PRMG_LOCALIZER"]      = 9,
	["PRMG_GLIDESLOPE"]     = 10,
	["BROADCAST_STATION"]   = 11,
	["VORTAC"]              = 12,
	["TACAN_AA_MODE_X"]     = 13,
	["TACAN_AA_MODE_Y"]     = 14,
	["VORDME"]              = 15,
	["ICLS_LOCALIZER"]      = 16,
	["ICLS_GLIDESLOPE"]     = 17,
	["TACAN_MOBILE_MODE_X"] = 18,
	["TACAN_MOBILE_MODE_Y"] = 19,
}

--- TACAN channel modes.
_t.BEACON.TACANMODE = {
	["X"] = "X",
	["Y"] = "Y",
}

--- DCS command names used to switch off beacon services.
-- ALL deactivates the beacon itself, the remaining entries deactivate
-- the ACLS, ICLS and Link4 services.
_t.BEACON.DEACTIVATE = {
	["ALL"]   = "DeactivateBeacon",
	["ACLS"]  = "DeactivateACLS",
	["ICLS"]  = "DeactivateICLS",
	["LINK4"] = "DeactivateLink4",
}

--- Formation definitions for grouped aircraft.
_t.FORMATION = {}

--- Formation geometry identifiers, MAX bounds the valid range.
_t.FORMATION.TYPE = {
	["NO_FORMATION"]              = 0,
	["LINE_ABREAST"]              = 1,
	["TRAIL"]                     = 2,
	["WEDGE"]                     = 3,
	["ECHELON_RIGHT"]             = 4,
	["ECHELON_LEFT"]              = 5,
	["FINGER_FOUR"]               = 6,
	["SPREAD_FOUR"]               = 7,
	["HEL_WEDGE"]                 = 8,
	["HEL_ECHELON"]               = 9,
	["HEL_FRONT"]                 = 10,
	["HEL_COLUMN"]                = 11,
	["WW2_BOMBER_ELEMENT"]        = 12,
	["WW2_BOMBER_ELEMENT_HEIGHT"] = 13,
	["WW2_FIGHTER_VIC"]           = 14,
	["COMBAT_BOX"]                = 15,
	["JAVELIN_DOWN"]              = 16,
	["MODERN_BOMBER_ELEMENT"]     = 17,
	["COMBAT_BOX_OPEN"]           = 18,
	["MAX"]                       = 19,
}

--- Formation spacing presets.
_t.FORMATION.DISTANCE = {
	["CLOSE"] = 1,
	["OPEN"]  = 2,
	["GROUP"] = 3,
}

--- Side offsets for echelon style formations.
_t.FORMATION.SIDE = {
	["RIGHT"] = 0,
	["LEFT"]  = 256,
}

--- Orbit patterns for racetrack/circle style station keeping.
_t.ORBITPATTERN = {
	["RACE_TRACK"] = "Race-Track",
	["CIRCLE"]     = "Circle",
	["ANCHORED"]   = "Anchored",
}

--- Weapon category identifiers.
-- Classifies the weapons carried by a unit, e.g. bombs, rockets,
-- missiles, AAMs, guns, torpedoes and specialty shells.
_t.WEAPONFLAGS = {
	["NOWEAPON"]      = 0,

	-- Bombs
	["LGB"]           = 1,
	["TVGB"]          = 2,
	["SNSGB"]         = 3,
	["HEBOMB"]        = 4,
	["PENETRATOR"]    = 5,
	["NAPALMBOMB"]    = 6,
	["FAEBOMB"]       = 7,
	["CLUSTERBOMB"]   = 8,
	["DISPENCER"]     = 9,
	["CANDLEBOMB"]    = 10,
	["PARACHUTEBOMB"] = 31,

	-- Rockets
	["LIGHTROCKET"]   = 11,
	["MARKERROCKET"]  = 12,
	["CANDLEROCKET"]  = 13,
	["HEAVYROCKET"]   = 14,

	-- Missiles
	["ARM"]           = 15,
	["ASM"]           = 16,
	["ATGM"]          = 17,
	["FAFASM"]        = 18,
	["LASM"]          = 19,
	["TELEASM"]       = 20,
	["CRUISEMISSILE"] = 21,
	["ARM2"]          = 30,
	["DECOY"]         = 33,

	-- AAMs
	["SRAAM"]         = 22,
	["MRAAM"]         = 23,
	["LRAAM"]         = 24,
	["IR_AAM"]        = 25,
	["SAR_AAM"]       = 26,
	["AR_AAM"]        = 27,

	-- Guns
	["GUNPOD"]        = 28,
	["BUILTINGUN"]    = 29,

	-- Torpedo
	["TORPEDO"]       = 32,

	-- Shells
	["SmokeShell"]    = 34,
	["IllumShell"]    = 35,
	["SubDespShell"]  = 36,
	["GuidedShell"]   = 37,
}

return _t
