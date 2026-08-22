-- SPDX-License-Identifier: LGPL-3.0

--- interfaces - reusable interface and pattern classes.
-- Namespace aggregating the interface submodules:
--
-- * `Command` - deferred function scheduled by the DCS scheduler
-- * `EventHandler` - common way for objects to process DCS events
-- * `Observable` - observer pattern support
-- * `State` - finite state machine state base class

local pkgname = "dcsext.interfaces"
local _t = {}

--- Deferred function scheduled by the DCS scheduler.
-- @see dcsext.interfaces.Command
_t.Command      = require(pkgname..".Command")

--- Common way for objects to process DCS events.
-- @see dcsext.interfaces.EventHandler
_t.EventHandler = require(pkgname..".EventHandler")

--- Observer pattern support.
-- @see dcsext.interfaces.Observable
_t.Observable   = require(pkgname..".Observable")

--- Finite state machine state base class.
-- @see dcsext.interfaces.State
_t.State        = require(pkgname..".State")

return _t
