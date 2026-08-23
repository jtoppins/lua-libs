-- SPDX-License-Identifier: LGPL-3.0

--- RingBuffer - fixed size circular buffer.
-- The buffer holds up to a fixed number of values; pushing into a
-- full buffer drops the oldest value to make room, so the buffer
-- always holds the most recently pushed values. Create a ring
-- buffer by calling the class with an optional capacity, e.g.
-- `local rb = RingBuffer(32)`, defaulting to 10 slots.
-- @classmod dcsext.containers.RingBuffer

local RingBuffer = {
	__index = {
		--- Push a value into the buffer.
		-- When the buffer is full the oldest value is dropped to
		-- make room for the new value.
		-- @function RingBuffer:push
		-- @param v value to store
		push = function(self, v)
			if self:size() == self.capacity then
				self.tail = self.tail + 1
			end
			self[self.head % self.capacity] = v
			self.head = self.head + 1
		end,

		--- Remove and return the oldest value in the buffer.
		-- @function RingBuffer:pop
		-- @return the oldest stored value or nil when the buffer
		-- is empty
		pop = function(self)
			if self:empty() then
				return nil
			end
			local v = self[self.tail % self.capacity]
			self.tail = self.tail + 1
			return v
		end,

		--- Test if the buffer holds no values.
		-- @function RingBuffer:empty
		-- @return bool, true when the buffer is empty
		empty = function(self)
			return self.head == self.tail
		end,

		--- Test if the buffer is filled to capacity.
		-- @function RingBuffer:full
		-- @return bool, true when the number of stored values
		-- equals the buffer capacity
		full = function(self)
			return self:size() == self.capacity
		end,

		--- Return the oldest value in the buffer without removing
		-- it.
		-- @function RingBuffer:peek
		-- @return the oldest stored value or nil when the buffer
		-- is empty
		peek = function(self)
			if self:empty() then
				return nil
			end
			return self[self.tail % self.capacity]
		end,

		--- Return the number of values stored in the buffer.
		-- @function RingBuffer:size
		-- @return the number of stored values
		size = function(self)
			return self.head - self.tail
		end,
	},

	--- Constructor.
	-- Create a new, empty ring buffer by calling the class
	-- directly, optionally passing the buffer capacity.
	-- @function RingBuffer:__call
	-- @param max optional maximum number of values the buffer
	-- holds, defaulting to 10
	-- @return a new, empty RingBuffer instance
	__call = function(cls, max)
		local m = max or 10
		return setmetatable({capacity = m, head = 1, tail = 1}, cls)
	end
}

setmetatable(RingBuffer, RingBuffer)
return RingBuffer
