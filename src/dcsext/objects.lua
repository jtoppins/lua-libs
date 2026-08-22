-- SPDX-License-Identifier: LGPL-3.0

--- objects - wrappers around DCS game world objects.
-- Namespace aggregating the object submodules:
--
-- * `Weapon` - representation of a DCS Weapon object with impact
--   prediction helpers

local pkgname = "dcsext.objects"
local _t = {}

--- Representation of a DCS Weapon object with impact prediction
-- helpers.
-- @see dcsext.objects.Weapon
_t.Weapon = require(pkgname..".Weapon")

return _t
