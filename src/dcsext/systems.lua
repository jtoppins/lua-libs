-- SPDX-License-Identifier: LGPL-3.0

--- systems - higher level systems built on library primitives.
-- Namespace aggregating the system submodules:
--
-- * `WeaponImpactTracker` - tracks weapons in flight and emits an
--   impact event when they reach their predicted impact point

local pkgname = "dcsext.systems"
local _t = {}

--- Tracks weapons in flight and emits an impact event when they
-- reach their predicted impact point.
-- @see dcsext.systems.WeaponImpactTracker
_t.WeaponImpactTracker = require(pkgname..".WeaponImpactTracker")

return _t
