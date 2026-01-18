-- SPDX-License-Identifier: LGPL-3.0

--- State class.

local class = require("dcsext.class")

local State = class("State")
function State:enter(_obj) end

function State:handleInput(_input) end

function State:update(_obj) end

function State:exit(_obj) end

return State
