codes = true
std   = "lua51"
jobs  = 3
self  = false
max_line_length = 80
max_cyclomatic_complexity = 10
read_globals = {
	-- common lua globals
	"lfs",

	-- DCS specific globals
	"net",
	"atmosphere",
	"country",
	"env",
	"Unit",
	"Object",
	"StaticObject",
	"Group",
	"coalition",
	"world",
	"timer",
	"trigger",
	"missionCommands",
	"coord",
	"land",
	"SceneryObject",
	"AI",
	"Controller",
	"radio",
	"Weapon",
	"Airbase",
	"VoiceChat",
	"Disposition",
	"Spot",
	"Warehouse",

	-- DCSEx specific
	"dcsext",
}

files["api/*"] = {
	max_cyclomatic_complexity = false,
	max_line_length = false,
	ignore = {"212", "614",},
	globals = {
		-- DCS specific globals
		"net",
		"atmosphere",
		"country",
		"env",
		"Unit",
		"Object",
		"StaticObject",
		"Group",
		"coalition",
		"world",
		"timer",
		"trigger",
		"missionCommands",
		"coord",
		"land",
		"SceneryObject",
		"AI",
		"Controller",
		"radio",
		"Weapon",
		"Airbase",
		"VoiceChat",
		"Disposition",
		"Spot",
		"Warehouse",
	},
}

files["src/dcsext/json.lua"] = {
	max_cyclomatic_complexity = false,
	max_line_length = false,
	ignore = {"614", "411"},
}

files["tests/*"] = {
	ignore = {"143", },
	globals = {
		-- busted globals
		"describe",
		"test",
		"pending",
		"before_each",
		"insulate",
		"mock",
		"stub",
	},
}
