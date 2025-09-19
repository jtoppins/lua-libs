-- SPDX-License-Identifier: LGPL-3.0

--- Extensions to lua debug module.
-- Provides functions for dumping _G and other debug functions.

local myio    = require("io")
local mylfs   = require("lfs")
local dcsextio = require("dcsext.io")
local json    = require("dcsext.json")
local Logger  = require("dcsext.env.Logger")

local _t = {}

--- Dump table `tbl` to a file `filename` using the JSON format.
-- This correctly handles self referencing tables and will not generate
-- tracebacks.
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
