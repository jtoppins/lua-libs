-- SPDX-License-Identifier: LGPL-3.0

--- PriorityQueue - min-heap priority queue.
-- Values are stored together with a numeric priority and are popped
-- in ascending priority order, so the value with the lowest priority
-- is always returned first. Create a priority queue by calling the
-- class directly, e.g. `local pq = PriorityQueue()`.
-- @classmod dcsext.containers.PriorityQueue

local function leftchild(i)
	return 2*i
end

--[[
local function rightchild(i)
	return 2*i+1
end
--]]

local function parent(i)
	return math.floor(i/2)
end

local PriorityQueue = {
	__index = {
		_swap = function(self, i, j)
			local a = self[i]
			self[i] = self[j]
			self[j] = a
		end,

		_siftup   = function(self, i)
			while i > 1 and self[parent(i)].prio > self[i].prio do
				self:_swap(i, parent(i))
				i = parent(i)
			end
		end,

		_siftdown = function(self, i)
			while leftchild(i) <= self:size() do
				local m = leftchild(i)

				if m ~= self:size() and
					self[m+1].prio < self[m].prio then
					m = m + 1
				end
				if self[m].prio < self[i].prio then
					self:_swap(i, m)
				else
					break
				end
				i = m
			end
		end,

		--- Return the number of values stored in the queue.
		-- @function PriorityQueue:size
		-- @return the number of stored values
		size = function(self)
			return #self
		end,

		--- Test if the queue holds no values.
		-- @function PriorityQueue:empty
		-- @return bool, true when the queue is empty
		empty = function(self)
			if next(self) == nil then
				return true
			end
			return false
		end,

		--- Insert a value into the queue with the given priority.
		-- @function PriorityQueue:push
		-- @param p priority used to order the value, lower
		-- priorities are popped first
		-- @param v value to store
		push = function(self, p, v)
			local d = {prio = p, data = v}
			local i = self:size()+1

			self[i] = d
			self:_siftup(i)
		end,

		--- Remove and return the value with the lowest priority.
		-- @function PriorityQueue:pop
		-- @return the stored value or nil when the queue is empty
		-- @return the priority of the returned value
		pop = function(self)
			if self:empty() then
				return nil
			end
			local sz = self:size()
			local data = self[1].data
			local prio = self[1].prio

			self[1] = self[sz]
			self[sz] = nil
			self:_siftdown(1)
			return data, prio
		end,


		--- Return the value with the lowest priority without
		-- removing it.
		-- @function PriorityQueue:peek
		-- @return the stored value or nil when the queue is empty
		-- @return the priority of the returned value
		peek = function(self)
			if self:empty() then
				return nil
			end

			return self[1].data, self[1].prio
		end,

		--- Remove an item from the queue by index.
		-- Not implemented yet, calling this method raises an
		-- assertion error.
		-- @function PriorityQueue:remove
		-- @param itemindex index of the item to remove
		remove = function(_--[[self, i]])
			assert(false, "Not supported yet")
		end,

		--- Increase the priority of an item by a given amount.
		-- Not implemented yet, calling this method raises an
		-- assertion error.
		-- @function PriorityQueue:increase
		-- @param itemindex index of the item to change
		-- @param deltaprio amount to add to the item priority
		increase = function(_ --[[self, i, deltap]])
			assert(false, "Not supported yet")
		end,

		--- Decrease the priority of an item by a given amount.
		-- Not implemented yet, calling this method raises an
		-- assertion error.
		-- @function PriorityQueue:decrease
		-- @param itemindex index of the item to change
		-- @param deltaprio amount to subtract from the item priority
		decrease = function(_ --[[self, i, deltap]])
			assert(false, "Not supported yet")
		end,
	},

	--- Constructor.
	-- Create a new, empty priority queue by calling the class
	-- directly, e.g. `local pq = PriorityQueue()`.
	-- @function PriorityQueue:__call
	-- @return a new, empty PriorityQueue instance
	__call = function(cls)
		return setmetatable({}, cls)
	end
}

setmetatable(PriorityQueue, PriorityQueue)
return PriorityQueue
