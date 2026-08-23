-- SPDX-License-Identifier: LGPL-3.0

--- IO - extensions to lua io.
-- Zip support automatically uses minizip when available and falls back
-- to the luazip library otherwise.

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

--- Directory separator character used by the host OS.
_t.pathSeparator = package.config:sub(1,1)

--- Extract the specified files from a zip archive and evaluate them
-- as lua chunks.
-- Each extracted file must contain lua source, it is loaded with
-- loadstring and executed against a shared environment table so the
-- symbols defined by all files accumulate into one merged table.
-- @param zippath file path to target zip file
-- @param ... vararg list of file names to extract from the zip file
-- @return merged table or nil on error followed by an error message
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
-- @param ... vararg list of strings
-- @return joined string using the OS directory separator
function _t.joinPaths(...)
	return mystring.join({...}, _t.pathSeparator)
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

--- Read a lua file, using env as the sanitized environment and
-- look for tblname in the read result.
-- The file is executed with setfenv against env so it cannot modify
-- global state; all symbols it defines land in the environment table.
-- @param file file path to lua file
-- @param tblname (optional) specifies a specific environment key
-- @param env (optional) environment to use, defaults to a fresh
--   empty table
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

--- Read configuration from cfgfiles and store read config into tbl.
-- Each cfgfiles entry is a table with the fields:
-- name - key under which the config is stored in tbl,
-- default - fallback value used when the config file does not exist,
-- file - path of the lua configuration file,
-- cfgtblname - optional key to select from the read environment,
-- env - optional environment passed to dcsext.io.readLua,
-- validate - function(cfg, readtbl) returning the validated config
--   to merge over the default.
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
