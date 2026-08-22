-- SPDX-License-Identifier: LGPL-3.0

--- Debug - extensions to lua's debug module.
-- Provides functions for dumping globals and other debug helpers.

local myio    = require("io")
local mylfs   = require("lfs")
local dcsextio = require("dcsext.io")
local json    = require("dcsext.json")
local Logger  = require("dcsext.env.Logger")

local _t = {}

--- Dump a table to a file as pretty printed JSON.
-- The file is created in `<SAVEDGAMES>/DCS/Logs/`. Self referencing
-- tables are handled correctly and will not generate tracebacks.
-- @param filename file name to be created in `<SAVEDGAMES>/DCS/Logs/`
-- @param tbl the table to dump, encoded in JSON
function _t.dumpTable(filename, tbl)
	local logger = Logger.getByName("dcsext")
	local f = dcsextio.joinPaths(mylfs.writedir(), "Logs", filename)
	local hfile, errmsg = myio.open(f, 'w')

	if hfile == nil then
		logger:error(errmsg)
		return
	end

	hfile:write(json:encode_pretty(tbl))
	hfile:close()
end

return _t
