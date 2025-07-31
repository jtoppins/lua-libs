-- SPDX-License-Identifier: LGPL-3.0

--- IO - extensions to lua io

local mylfs = require("lfs")
local mystring = require("dcsex.string")
local mytable = require("dcsex.table")

local _t = {}

--- returns the directory seperator used for the given OS
_t.pathSeperator = package.config:sub(1,1)

--- Join all directory paths provided in the parameter list.
-- @param ... varadic argument list of strings
-- @return joined string using the OS directory seperator
function _t.joinPaths(...)
	return mystring.join({...}, _t.pathSeperator)
end

--- Is a path a directory?
-- @param path string
-- @return True if path references a directory, false otherwise
function _t.isDir(path)
	local attr = mylfs.attributes(path)

	if attr == nil then
		return false
	end
	return attr.mode == "directory"
end

--- Read a lua file, using env as the sanatized environment and
-- look for tblname in the read result.
-- @param file file path to lua file
-- @param tblname (optional) specifies a specific environment key
-- @param env (optional) environment to use
-- @return resultant symbols read from file, file string
function _t.readLua(file, tblname, env)
	dcsex.check.string(file)
	local f = assert(loadfile(file))
	local config = env or {}
	setfenv(f, config)
	assert(pcall(f))
	local tbl = config
	if tblname ~= nil then
		tbl = config[tblname]
	end
	return tbl, file
end

--- Read configuration from cfgfiles and store read config into tbl
-- @param cfgfiles a table of configuration files to read
-- @param tbl the table to store the configuration into
function _t.readConfigs(cfgfiles, tbl)
	for _, cfg in pairs(cfgfiles) do
		tbl[cfg.name] = cfg.default or {}
		if mylfs.attributes(cfg.file) ~= nil then
			local readtbl = _t.readLua(cfg.file,
						   cfg.cfgtblname,
						   cfg.env)
			readtbl = cfg.validate(cfg, readtbl)
			mytable.merge(tbl[cfg.name], readtbl)
		end
	end
end

return _t
