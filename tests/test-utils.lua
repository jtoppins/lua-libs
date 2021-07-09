#!/usr/bin/lua
require("os")

local utils = require("libs.utils")

local function test()
	local test_sortedpairs = {
        a = 1,
        c = 3,
        b = 2,
        d = 4,
    }
    local test_sortedpairs_out = {}
    for k, v in utils.sortedpairs(test_sortedpairs) do
        table.insert(test_sortedpairs_out, string.format("%s = %d", k, v))
    end
    local test_sortedpairs_concat = table.concat(test_sortedpairs_out, ", ")
    local test_sortedpairs_expect = "a = 1, b = 2, c = 3, d = 4"
    assert(test_sortedpairs_concat == test_sortedpairs_expect, string.format(
        "utils.sortedpairs iterated out of order; got: '%s', expected: '%s'",
        test_sortedpairs_concat, test_sortedpairs_expect))

	return 0
end
os.exit(test())
