-- SPDX-License-Identifier: LGPL-3.0

--- SpatialHash. Provides a basic spatial hasing container for 2d
-- objects to facilitate fast neighbor query.
-- @classmod dcsext.containers.SpatialHash

local class = require("dcsext.class")

local P1 = 73856093
local P2 = 83492791

local function createTuple(x, y)
	return dcsext.vector.Vec2.new(x, y)
end

local Object = class("HashGridObject")
function Object:__init(pos, radius)
	self.position = dcsext.vector.Vec2(pos)
	self.radius   = math.abs(radius)
	self._queryId = -1
	self._cells   = nil
end

local SpatialHashGrid = class("SpatialHash2D")

SpatialHashGrid.Object = Object

--- Constructor.
function SpatialHashGrid:__init(tablesize, cellsize)
	self._cellsize  = cellsize
	self._tablesize = tablesize
	self._queryIds  = 0
	self._cells     = {}

	for i = 1, self._tablesize do
		self._cells[i] = setmetatable({}, { __mode = "k", })
	end
end

--- Maps a 2d position(x, y) into our cell grid.
-- @param position a table with members 'x' and 'y'.
function SpatialHashGrid:_hash(x, y)
	local xi = x * P1
	local yi = y * P2

	local idx = math.floor((xi + yi) % self._tablesize)
	if idx < 0 then idx = idx + self._tablesize end

	-- force value between [1, tablesize]
	return idx + 1
end

function SpatialHashGrid:_getBounds(position, radius)
	local minX = math.floor((position.x - radius) / self._cellsize)
	local minY = math.floor((position.y - radius) /	self._cellsize)
	local maxX = math.floor((position.x + radius) / self._cellsize)
	local maxY = math.floor((position.y + radius) / self._cellsize)

	return {
		["min"] = createTuple(minX, minY),
		["max"] = createTuple(maxX, maxY),
	}
end

--- Returns a new Object already inserted into the grid.
function SpatialHashGrid:newObject(position, radius)
	local object = Object(position, radius)

	self:insert(object)

	return object
end

--- Update the position of object in the grid.
function SpatialHashGrid:update(object)
	local bounds = self:_getBounds(object.position, object.radius)

	if object._cells.min == bounds.min and
	   object._cells.max == bounds.max then
		return
	end

	self:remove(object)
	self:insert(object)
end

--- Add a new object into the grid.
function SpatialHashGrid:insert(object)
	local bounds = self:_getBounds(object.position, object.radius)

	object._cells = bounds

	for x = bounds.min.x, bounds.max.x, 1 do
		for y = bounds.min.y, bounds.max.y, 1 do
			local index = self:_hash(x, y)
			self._cells[index][object] = true
		end
	end
end

--- Remove object from the grid.
function SpatialHashGrid:remove(object)
	local bounds = object._cells

	for x = bounds.min.x, bounds.max.x, 1 do
		for y = bounds.min.y, bounds.max.y, 1 do
			local index = self:_hash(x, y)
			self._cells[index][object] = nil
		end
	end
end

--- Find all objects in the grid within radius of position.
function SpatialHashGrid:findNear(position, radius)
	local bounds = self:_getBounds(position, radius)

	local objects = {}
	local queryId = self._queryIds
	self._queryIds = self._queryIds + 1
	for x = bounds.min.x, bounds.max.x, 1 do
		for y = bounds.min.y, bounds.max.y, 1 do
			local index = self:_hash(x, y)
			for obj, _ in pairs(self._cells[index]) do
				if obj._queryId ~= queryId then
					obj._queryId = queryId
					objects[obj] = true
				end
			end
		end
	end
	return objects
end

return SpatialHashGrid
