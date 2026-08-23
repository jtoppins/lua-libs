-- SPDX-License-Identifier: LGPL-3.0

--- UI - map drawing and on-screen user interface namespace.
-- Bundles the classes used to draw marks on the F10 map and to show
-- pictures on screen. Exports Arrow, Circle, Color, DrawObject, Line,
-- Mark, Picture, PolyLine, Quad, Rect, Text, and Triangle.

local _t = {}

--- Draw an arrow on the F10 map.
-- @see dcsext.ui.Arrow
_t.Arrow      = require("dcsext.ui.Arrow")

--- Draw a circle on the F10 map.
-- @see dcsext.ui.Circle
_t.Circle     = require("dcsext.ui.Circle")

--- Represents a DCS color table.
-- @see dcsext.ui.Color
_t.Color      = require("dcsext.ui.Color")

--- Base class for all F10 map drawing objects.
-- @see dcsext.ui.DrawObject
_t.DrawObject = require("dcsext.ui.DrawObject")

--- Draw a line on the F10 map.
-- @see dcsext.ui.Line
_t.Line       = require("dcsext.ui.Line")

--- Draw a user mark on the F10 map.
-- @see dcsext.ui.Mark
_t.Mark       = require("dcsext.ui.Mark")

--- Draw a picture on screen.
-- @see dcsext.ui.Picture
_t.Picture    = require("dcsext.ui.Picture")

--- Draw a multi-segment line on the F10 map.
-- @see dcsext.ui.PolyLine
_t.PolyLine   = require("dcsext.ui.PolyLine")

--- Draw a quadrilateral on the F10 map.
-- @see dcsext.ui.Quad
_t.Quad       = require("dcsext.ui.Quad")

--- Draw a rectangle on the F10 map.
-- @see dcsext.ui.Rect
_t.Rect       = require("dcsext.ui.Rect")

--- Draw text on the F10 map.
-- @see dcsext.ui.Text
_t.Text       = require("dcsext.ui.Text")

--- Draw a triangle on the F10 map.
-- @see dcsext.ui.Triangle
_t.Triangle   = require("dcsext.ui.Triangle")

return _t
