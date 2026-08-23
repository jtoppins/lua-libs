-- SPDX-License-Identifier: LGPL-3.0

--- ai - DCS AI tasking helpers.
-- Namespace aggregating the AI submodules:
--
-- * `exec` - DCS AI execution functions and helpers
-- * `commands` - builders for DCS AI command tables
-- * `options` - builders for DCS AI option tables
-- * `tasks` - builders for DCS AI task tables
-- * `Waypoint` - waypoint class for constructing routes
-- * `Route` - route class composing waypoints into a flight plan

local _t = {}

--- DCS AI execution functions and helpers.
-- @see dcsext.ai.exec
_t.exec     = require("dcsext.ai.exec")

--- Builders for DCS AI command tables.
-- @see dcsext.ai.commands
_t.commands = require("dcsext.ai.commands")
--- Builders for DCS AI option tables.
-- @see dcsext.ai.options
_t.options  = require("dcsext.ai.options")

--- Builders for DCS AI task tables.
-- @see dcsext.ai.tasks
_t.tasks    = require("dcsext.ai.tasks")

--- Waypoint class for constructing routes.
-- @see dcsext.ai.Waypoint
_t.Waypoint = require("dcsext.ai.Waypoint")

--- Route class composing waypoints into a flight plan.
-- @see dcsext.ai.Route
_t.Route    = require("dcsext.ai.Route")

return _t
