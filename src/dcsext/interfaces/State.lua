-- SPDX-License-Identifier: LGPL-3.0

--- State class.
-- @classmod dcsext.interfaces.State

local class = require("dcsext.class")

local State = class("State")

--- Called when the object enters this state.
-- @param _obj the object transitioning into this state
function State:enter(_obj) end

--- Handle an input while in this state.
-- @param _input the input to handle
function State:handleInput(_input) end

--- Update this state, called periodically while the object is in
-- this state.
-- @param _obj the object being updated
function State:update(_obj) end

--- Called when the object leaves this state.
-- @param _obj the object transitioning out of this state
function State:exit(_obj) end

return State
