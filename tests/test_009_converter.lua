#!/usr/bin/lua

require 'busted.runner'()
require("dcsex")

local testvec = {
	{
		from = "m",
		to = "ft",
		value = 50,
		result = 164.042,
		tolerance = 0.0001,
		tostring = "164.04 ft",
	}, {
		from = "mps",
		to = "knots",
		value = 51.444,
		result = 99.99,
		tolerance = 0.01,
		tostring = "100.00 kts",
	}, {
		from = "mps",
		to = "mph",
		value = 51.444,
		result = 115.07,
		tolerance = 0.01,
		tostring = "115.08 mph",
	}, {
		from = "mps",
		to = "kph",
		value = 51.444,
		result = 185.198,
		tolerance = 0.01,
		tostring = "185.20 kph",
	}, {
		from = "m",
		to = "nm",
		value = 2500,
		result = 1.3498,
		tolerance = 0.01,
		tostring = "1.35 NM",
	}, {
		from = "m",
		to = "sm",
		value = 2500,
		result = 1.553,
		tolerance = 0.01,
		tostring = "1.55 SM",
	}, {
		from = "m",
		to = "km",
		value = 2500,
		result = 2.5,
		tolerance = 0.01,
		precision = 1,
		tostring = "2.5 km",
	}, {
		from = "m",
		to = "ft",
		value = 2500,
		result = 8202.1,
		tolerance = 0.01,
		precision = 1,
		tostring = "8202.1 ft",
	}, {
		from = "m",
		to = "m",
		value = 2500,
		result = 2500,
		tolerance = 0.00001,
		tostring = "2500.00 m",
	}, {
		from = "pascal",
		to = "inhg",
		value = 100,
		result = 0.0295,
		tolerance = 0.0001,
		precision = 4,
		tostring = "0.0295 inHg",
	}, {
		from = "pascal",
		to = "mmhg",
		value = 100,
		result = 0.75,
		tolerance = 0.001,
		tostring = "0.75 mmHg",
	}, {
		from = "pascal",
		to = "hpa",
		value = 100,
		result = 1,
		tolerance = 0.001,
		tostring = "1.00 hPa",
	}, {
		from = "pascal",
		to = "mbar",
		value = 100,
		result = 10,
		tolerance = 0.001,
		tostring = "10.00 mbar",
	}, {
		from = "kelvin",
		to = "kelvin",
		value = 100,
		result = 100,
		tolerance = 0.001,
		precision = 0,
		tostring = "100 °K",
	}, {
		from = "kelvin",
		to = "celsius",
		value = 100,
		result = -173.15,
		tolerance = 0.001,
		tostring = "-173.15 °C",
	}, {
		from = "kelvin",
		to = "fahrenheit",
		value = 100,
		result = -279.67,
		tolerance = 0.001,
		tostring = "-279.67 °F",
	}, {
		from = "celsius",
		to = "kelvin",
		value = 15,
		result = 288.15,
		tolerance = 0.001,
		tostring = "288.15 °K",
	},
}


describe("validate dcsex.converter", function()
	test("convert", function()
		for _, data in ipairs(testvec) do
			local result, err = dcsex.converter.convert(
							data.value,
							data.from,
							data.to)
			assert(result, err)
			assert.is.near(result, data.result, data.tolerance)
			assert.is.equal(data.tostring,
				dcsex.converter.tostring(result, data.to,
					data.precision))
		end
	end)

	test("coordinates", function()
		local mgrs = {
			UTMZone = "37T",
			MGRSDigraph = "DK",
			Easting = 12345,
			Northing = 67890,
		}
		assert.is.equal(dcsex.converter.tostring(mgrs, "mgrs", 4),
			"37T DK 1234 6789")

		local ll = {
			latitude = 36.12345,
			longitude = -78.67890,
			altitude = 150,
		}
		assert.is.equal(dcsex.converter.tostring(ll, "dd", 2),
			"36.12°N 78.67°W")
		assert.is.equal(dcsex.converter.tostring(ll, "ddm", 3),
			"36°07.38'N 078°40.68'W")
		assert.is.equal(dcsex.converter.tostring(ll, "dms", 4),
			"36°07'24.2\"N 078°40'44.0\"W")
	end)
end)
