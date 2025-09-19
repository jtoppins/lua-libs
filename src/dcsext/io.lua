-- SPDX-License-Identifier: LGPL-3.0

--- IO - extensions to lua io

local mylfs = require("lfs")
local mystring = require("dcsext.string")
local mytable = require("dcsext.table")

local ziptype = {
	["MINIZIP"] = 1,
	["LUAZIP"]  = 2,
}

local ztype = ziptype.MINIZIP
local ok, zip = pcall(require, "minizip")
if not ok then
	ztype = ziptype.LUAZIP
	ok, zip = pcall(require, "zip")
	assert(ok, "require: unable to load zip library")
end

--- Extract all files using minizip, exit on first error.
-- luacheck: ignore 212
local function minizip_extract(z, ...)
	local tbl = {}

	for _, filename in ipairs(arg) do
		local result

		local str = z:extract(filename)
		local f, err = loadstring(str)
		if not f then
			return nil, err
		end

		setfenv(f, tbl)
		result, err = pcall(f)
		if not result then
			return nil, err
		end
	end

	return tbl
end

--- Extract all files using luazip, exit on first error.
local function luazip_extract(z, ...)
	local tbl = {}

	for _, filename in ipairs(arg) do
		local file, f, result, err

		file, err = z:open(filename)
		if not file then
			return nil, err
		end

		local str = file:read("*a")
		file:close()
		f, err = loadstring(str)
		if not f then
			return nil, err
		end

		setfenv(f, tbl)
		result, err = pcall(f)
		if not result then
			return nil, err
		end
	end

	return tbl
end

local _t = {}

--- returns the directory seperator used for the given OS
_t.pathSeperator = package.config:sub(1,1)

--- Extract the specified files from the zip archive and convert them
-- to a lua table.
-- @param zippath file path to target zip file
-- @param ... varadic list of file names to extract from the zip file
-- @return merged table
function _t.extract(zippath, ...)
	local z, errmsg = zip.open(zippath)
	local tbl, err

	if not z then
		return nil, errmsg
	end

	if ziptype.MINIZIP == ztype then
		tbl, err = minizip_extract(z, ...)
	elseif ziptype.LUAZIP == ztype then
		tbl, err = luazip_extract(z, ...)
	end
	z:close()

	return tbl, err
end

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
	dcsext.check.string(file)
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
