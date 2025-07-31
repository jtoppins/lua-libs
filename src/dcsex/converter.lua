-- SPDX-License-Identifier: LGPL-3.0

--- Units Converter.
-- Converts between common units of measure.

-- DCS base units:
-- distance = meters
-- angle = radians
-- mass = kilograms
-- position = dcs custom floating point triple
-- pressure = pascals
-- temperature = kelvins
-- speed = meters per second

local mytable = require("dcsex.table")

local _unitstbl = {}

--- Position formats for latitude/longitude coordinates.
-- @field DD degrees decimal, 32.12345 / -78.2345
-- @field DDM degrees decimal minutes, 32 12.34' / -78 23.45'
-- @field DMS degrees minutes seconds, 32 12' 15" / -78 23' 28"
local posfmt = {
	["DD"]  = 1,
	["DDM"] = 2,
	["DMS"] = 3,
}

local function passthrough(value)
	return value
end

local function dcs_to_ll(value)
	local lat, long, alt = coord.LOtoLL(value)

	return { latitude = lat,
		 longitude = long,
		 altitude = alt, }
end

local function ll_to_dcs(value)
	return coord.LLtoLO(value.latitude, value.longitude, value.altitude)
end

local function dcs_to_mgrs(value)
	local ll = dcs_to_ll(value)
	return coord.LLtoMGRS(ll.latitude, ll.longitude)
end

--- Converts an MGRS coordinate to a DCS native coordinate.
local function mgrs_to_dcs(value)
	local lat, long, alt = coord.MGRStoLL(value)
	return coord.LLtoLO(lat, long, alt)
end

--- Reduce the accuracy of the position to the precision specified
local function degradeLL(lat, long, precision)
	local multiplier = math.pow(10, precision)
	lat  = math.modf(lat * multiplier) / multiplier
	long = math.modf(long * multiplier) / multiplier
	return lat, long
end

--- set up formatting args for the LL string
local function getLLformatstr(precision, fmt)
	local decimals = precision
	if fmt == posfmt.DDM then
		if precision > 1 then
			decimals = precision - 1
		else
			decimals = 0
		end
	elseif fmt == posfmt.DMS then
		if precision > 4 then
			decimals = precision - 2
		elseif precision > 2 then
			decimals = precision - 3
		else
			decimals = 0
		end
	end
	if decimals == 0 then
		return "%02.0f"
	else
		return "%0"..(decimals+3).."."..decimals.."f"
	end
end

--- Convert a lat, long coordinate to a string.
local function tostringLL(lat, long, precision, fmt)
	local northing = "N"
	local easting  = "E"
	local degsym   = '°'

	if lat < 0 then
		northing = "S"
	end

	if long < 0 then
		easting = "W"
	end

	lat, long = degradeLL(lat, long, precision)
	lat  = math.abs(lat)
	long = math.abs(long)

	local fmtstr = getLLformatstr(precision, fmt)

	if fmt == posfmt.DD then
		return string.format(fmtstr..degsym, lat)..northing..
			" "..
			string.format(fmtstr..degsym, long)..easting
	end

	-- we give the minutes and seconds a little push in case the division
	-- from the truncation with this multiplication gives us a value ending
	-- in .99999...
	local tolerance = 1e-8

	local latdeg   = math.floor(lat)
	local latmind  = (lat - latdeg)*60 + tolerance
	local longdeg  = math.floor(long)
	local longmind = (long - longdeg)*60 + tolerance

	if fmt == posfmt.DDM then
		return string.format("%02d"..degsym..fmtstr.."'", latdeg,
				     latmind)..
			northing..
			" "..
			string.format("%03d"..degsym..fmtstr.."'", longdeg,
				      longmind)..
			easting
	end

	local latmin   = math.floor(latmind)
	local latsecd  = (latmind - latmin)*60 + tolerance
	local longmin  = math.floor(longmind)
	local longsecd = (longmind - longmin)*60 + tolerance

	return string.format("%02d"..degsym.."%02d'"..fmtstr.."\"",
			latdeg, latmin, latsecd)..
		northing..
		" "..
		string.format("%03d"..degsym.."%02d'"..fmtstr.."\"",
			longdeg, longmin, longsecd)..
		easting
end


local _t = {}

--- table of possible measures: length, speed, etc
_t.measure = {
	["LENGTH"]      = 1,
	["MASS"]        = 2,
	["SPEED"]       = 3,
	["PRESSURE"]    = 4,
	["TEMPERATURE"] = 5,
	["COORDINATES"] = 6,
}

--- Convert between units of measure.
-- @param value value(number|table) to convert
-- @param fromunit a units string the value is currently in
-- @param tounit unit of measure the convert value to
-- @return converted value or nil on error
function _t.convert(value, fromunit, tounit)
	local from = _unitstbl[fromunit:upper()]
	local to   = _unitstbl[tounit:upper()]

	if from == nil then
		return nil, string.format("invalid unit '%s'", fromunit)
	end

	if to == nil then
		return nil, string.format("invalid unit '%s'", tounit)
	end

	if from.measure ~= to.measure then
		return nil, string.format("'%s' to '%s' not possible",
			fromunit, tounit)
	end

	local a, v
	if type(from.tobase) == "function" then
		a = from.tobase(value)
	else
		a = tonumber(from.tobase) * value
	end

	if type(to.frombase) == "function" then
		v = to.frombase(a)
	else
		v = tonumber(to.frombase) * a
	end
	return v
end

--- Register a new unit of measure with the system.
-- @param unitstr the string used to reference this unit, will be
--    converted to uppercase. There cannot be collisions between units.
-- @param measure one of the items in dcsex.converter.measure.
-- @param frombase function assumes value is in a DCS base unit and
--    converts to the target unit.
-- @param tobase function assumes value is in this unit and it converts
--    it to the DCS base unit.
-- @param tostr (optional) converts to a human readable representation
-- @param overwrite (optional) flag to overwrite any previous entry.
-- @return True if successful otherwise false, error msg
function _t.register(unitstr, measure, frombase, tobase, tostr, overwrite)
	local us = unitstr:upper()

	if overwrite ~= true and _unitstbl[us] ~= nil then
		return false, string.format("unit(%s) already exists",
			unitstr)
	end

	if mytable.getKey(_t.measure, measure) == nil then
		return false, string.format("invalid measure %d", measure)
	end

	if frombase == nil then
		frombase = passthrough
	end

	if tobase == nil then
		tobase = passthrough
	end

	if type(frombase) ~= "function" and type(frombase) ~= "number" then
		return false, "frombase must be a function or number"
	end

	if type(tobase) ~= "function" and type(tobase) ~= "number" then
		return false, "tobase must be a function or number"
	end

	local entry = {}
	entry.measure = measure
	entry.frombase = frombase
	entry.tobase = tobase
	entry.symbol = tostr
	_unitstbl[us] = entry
	return true
end

--- Convert value to a human readable representation.
-- @param value the value to display
-- @param unitstr unit string that was registered
-- @param precision (optional) defines how many decimal places will be shown
--    the default is 2.
-- @return string representation of value or nil
function _t.tostring(value, unitstr, precision)
	local entry = _unitstbl[unitstr:upper()]

	if entry == nil then
		return nil
	end

	precision = precision or 2

	if type(entry.symbol) == "function" then
		return entry.symbol(value, precision)
	end

	return string.format("%."..tostring(precision).."f %s", value,
		tostring(entry.symbol))
end

-- Register some basic units
assert(_t.register("dcs"   , _t.measure.COORDINATES, nil, nil,
	function (value)
		return string.format("(%g, %g, %g)",
			value.x, value.y, value.z or 0)
	end))
assert(_t.register("dd"    , _t.measure.COORDINATES, dcs_to_ll, ll_to_dcs,
	function (value, precision)
		return tostringLL(value.latitude,
				  value.longitude,
				  precision, posfmt.DD)
	end))
assert(_t.register("ddm"   , _t.measure.COORDINATES, dcs_to_ll, ll_to_dcs,
	function (value, precision)
		return tostringLL(value.latitude,
				  value.longitude,
				  precision, posfmt.DDM)
	end))
assert(_t.register("dms"   , _t.measure.COORDINATES, dcs_to_ll, ll_to_dcs,
	function (value, precision)
		return tostringLL(value.latitude,
				  value.longitude,
				  precision, posfmt.DMS)
	end))
assert(_t.register("mgrs"  , _t.measure.COORDINATES,
	dcs_to_mgrs, mgrs_to_dcs,
	function (mgrs, precision)
		local str = mgrs.UTMZone .. " " .. mgrs.MGRSDigraph

		if precision == 0 then
			return str
		end

		local divisor = 10^(5-precision)
		local fmtstr  = "%0"..tostring(precision).."d"
		return str.." "..
			string.format(fmtstr, (mgrs.Easting/divisor))..
			" "..string.format(fmtstr, (mgrs.Northing/divisor))
	end))

assert(_t.register("m"     , _t.measure.LENGTH, nil, nil, "m"))
assert(_t.register("ft"    , _t.measure.LENGTH, 3.28084, 1/3.28084, "ft"))
-- nautical mile
assert(_t.register("nm"    , _t.measure.LENGTH, 0.000539957,
	1/0.000539957, "NM"))
-- statute mile
assert(_t.register("sm"    , _t.measure.LENGTH, 0.000621371,
	1/0.000621371, "SM"))
assert(_t.register("km"    , _t.measure.LENGTH, 0.001, 1/0.001, "km"))

assert(_t.register("pascal", _t.measure.PRESSURE, nil, nil, "Pa"))
assert(_t.register("inhg"  , _t.measure.PRESSURE, 0.0002953,
	1/0.0002953, "inHg"))
assert(_t.register("mmhg"  , _t.measure.PRESSURE, 0.00750062,
	1/0.00750062, "mmHg"))
assert(_t.register("hpa"   , _t.measure.PRESSURE, 0.01, 1/0.01, "hPa"))
assert(_t.register("mbar"  , _t.measure.PRESSURE, 0.1, 1/0.1, "mbar"))

assert(_t.register("mps"   , _t.measure.SPEED, nil, nil, "m/s"))
assert(_t.register("knots" , _t.measure.SPEED, 1.94384, 1/1.94384, "kts"))
assert(_t.register("kph"   , _t.measure.SPEED, 3.6, 1/3.6, "kph"))
assert(_t.register("mph"   , _t.measure.SPEED, 2.23694, 1/2.23694, "mph"))

assert(_t.register("kelvin"    , _t.measure.TEMPERATURE, nil, nil, "°K"))
assert(_t.register("celsius"   , _t.measure.TEMPERATURE,
	function (value)
		return value - 273.15
	end,
	function (value)
		return value + 273.15
	end, "°C"))
assert(_t.register("fahrenheit", _t.measure.TEMPERATURE,
	function (value)
		return (value - 273.15) * 9/5 + 32
	end,
	function (value)
		return 5/9 * (value - 32) + 273.15
	end, "°F"))

assert(_t.register("kg"    , _t.measure.MASS, nil, nil, "Kg"))
assert(_t.register("g"     , _t.measure.MASS, 1000, 1/1000, "g"))
assert(_t.register("lbs"   , _t.measure.MASS, 2.204623, 1/2.204623, "lbs"))

return _t
