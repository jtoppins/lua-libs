codes = true
std   = "lua51"
jobs  = 3
self  = false
max_line_length = 80
max_cyclomatic_complexity = 10
read_globals = {
	-- common lua globals
	"lfs",
	"libs",
}

files["src/libs/json.lua"] = {
	max_cyclomatic_complexity = false,
	max_line_length = false,
	ignore = {"614", "411"},
}

files["src/libs/utils.lua"] = {
	max_cyclomatic_complexity = 12,
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
	},
}
