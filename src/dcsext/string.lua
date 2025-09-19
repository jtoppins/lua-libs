-- SPDX-License-Identifier: LGPL-3.0

--- String - extensions to lua strings

local _t = {}

--- Uppercase the first letter of string.
-- @param str A string
-- @return A string, with the first letter uppercased.
function _t.firstToUpper(str)
	return str:gsub("^%l", string.upper)
end

--- String interpolation, substitute %NAME% where NAME is any arbitrary
-- string enclosed with parenthesis with a value in `tab`. `tab` is
-- a table of name=value pairs.
-- @param s string with possible substitution keys.
-- @param tab table of name=value pairs used in the substitution.
-- @return [string] expanded with substitutions.
function _t.interp(s, tab)
	return (s:gsub('(%b%%)', function(w) return tab[w:sub(2,-2)] or w end))
end

--- Join an array of typically strings into a single string
-- seperated by sep.
-- @param tbl A table of typically strings
-- @param sep seperator string to use
-- @return A string
function _t.join(tbl, sep)
	return table.concat(tbl, sep)
end

--- Split str string searching str for spe substring to split on.
-- Return a array of the resulting substrings.
-- @param str string to split
-- @param sep seperator substring to split the string on, this
--   sequence of characters will not exist in the resultant substrings.
-- @return array of split strings
function _t.split(str, sep)
	sep = sep or "%s"
	local t = {}

	for s in string.gmatch(str, "([^"..sep.."]+)") do
		table.insert(t, s)
	end
	return t
end

--- Does a string start with a given substring?
-- @param haystack the string
-- @param needle the substring to look for
-- @return True if it starts with needle, false otherwise
function _t.startsWith(haystack, needle)
	return haystack:sub(1, #needle) == needle
end

--- Trim withspace from the beginning and end of str.
-- @param str A string
-- @return a trimmed string
function _t.trim(str)
	return str:gsub("^%s*(.-)%s*$", "%1")
end

return _t
