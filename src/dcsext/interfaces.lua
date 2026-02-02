-- SPDX-License-Identifier: LGPL-3.0

local pkgname = "dcsext.interfaces"
local _t = {}

_t.Command      = require(pkgname..".Command")
_t.EventHandler = require(pkgname..".EventHandler")
_t.Observable   = require(pkgname..".Observable")
_t.State        = require(pkgname..".State")

return _t
