-- SPDX-License-Identifier: LGPL-3.0

--- Queue - doubly ended queue with head and tail access.
-- Values are stored in a flat table indexed by position, giving
-- constant time push, pop and peek operations at both ends. Create
-- a queue by calling the class directly, e.g. `local q = Queue()`.
-- @classmod dcsext.containers.Queue

local Queue = {
	__index = {
		--- Push a value onto the head of the queue.
		-- @function Queue:pushhead
		-- @param v value to store, nil values are ignored
		pushhead = function(self, v)
			if v == nil then return end
			self.head = self.head - 1
			self[self.head] = v
		end,

		--- Pop the value at the head off the queue.
		-- @function Queue:pophead
		-- @return the value previously at the head or nil when the
		-- queue is empty
		pophead  = function(self)
			local h = self.head
			if h > self.tail then
				return nil
			end
			local v = self[h]
			self[h] = nil
			self.head = h + 1
			return v
		end,

		--- Push a value onto the tail of the queue.
		-- @function Queue:pushtail
		-- @param v value to store, nil values are ignored
		pushtail = function(self, v)
			if v == nil then return end
			self.tail = self.tail + 1
			self[self.tail] = v
		end,

		--- Pop the value at the tail off the queue.
		-- @function Queue:poptail
		-- @return the value previously at the tail or nil when the
		-- queue is empty
		poptail  = function(self)
			local t = self.tail
			if self.head > t then
				return nil
			end
			local v = self[t]
			self[t] = nil
			self.tail = t - 1
			return v
		end,

		--- Return the value at the head without removing it.
		-- @function Queue:peekhead
		-- @return the value at the head or nil when the queue is
		-- empty
		peekhead = function(self)
			return self[self.head]
		end,

		--- Return the value at the tail without removing it.
		-- @function Queue:peektail
		-- @return the value at the tail or nil when the queue is
		-- empty
		peektail = function(self)
			return self[self.tail]
		end,

		--- Return the number of values stored in the queue.
		-- @function Queue:size
		-- @return the number of stored values
		size     = function(self)
			local val = self.tail - self.head + 1

			if val < 0 then
				return 0
			end
			return val
		end,

		--- Test if the queue holds no values.
		-- @function Queue:empty
		-- @return bool, true when the queue is empty
		empty    = function(self)
			return self.head > self.tail
		end,

		--- Iterate over the values in the queue from head to tail.
		-- @function Queue:iterate
		-- @return an iterator function for use in a for-in loop,
		-- yielding the index and value of each entry; iterating an
		-- empty queue yields nothing
		iterate  = function(self)
			if self:empty() then
				return function() end, nil, nil
			end

			local fnext = function(state, key)
				if key == nil then
					key = state.head
				else
					key = key + 1
				end
				if key > state.tail then
					return nil
				end
				return key, state[key]
			end
			return fnext, self, nil
		end,

		--- Iterate over the values in the queue from tail to head.
		-- @function Queue:riterate
		-- @return an iterator function for use in a for-in loop,
		-- yielding the index and value of each entry in reverse
		-- order; iterating an empty queue yields nothing
		riterate = function(self)
			if self:empty() then
				return function() end, nil, nil
			end

			local fnext = function(state, key)
				if key == nil then
					key = state.tail
				else
					key = key - 1
				end
				if key < state.head then
					return nil
				end
				return key, state[key]
			end
			return fnext, self, nil
		end,
	},

	--- Constructor.
	-- Create a new, empty queue by calling the class directly,
	-- e.g. `local q = Queue()`.
	-- @function Queue:__call
	-- @return a new, empty Queue instance
	__call = function(cls)
		return setmetatable({head = 0, tail = -1}, cls)
	end,
}

setmetatable(Queue, Queue)
return Queue
