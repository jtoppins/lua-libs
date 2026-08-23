-- SPDX-License-Identifier: LGPL-3.0

--- containers - data structure classes and algorithms.
-- Namespace aggregating the container submodules:
--
-- * `goap` - Goal-Oriented Action Planning system
-- * `graph` - basic Graph container with nodes and edges
-- * `Queue` - first-in first-out queue
-- * `PriorityQueue` - min-heap queue ordered by priority
-- * `RingBuffer` - fixed size circular buffer
-- * `SpatialHashGrid` - spatial hash container for 2d positions

local containers = {}

--- Goal-Oriented Action Planning system.
-- @see dcsext.containers.goap
containers.goap = require("dcsext.containers.goap")

--- Basic Graph container with nodes and edges.
-- @see dcsext.containers.graph
containers.graph = require("dcsext.containers.graph")

--- Doubly ended queue with head and tail access.
-- @see dcsext.containers.Queue
containers.Queue = require("dcsext.containers.Queue")

--- Min-heap queue ordered by priority.
-- @see dcsext.containers.PriorityQueue
containers.PriorityQueue = require("dcsext.containers.PriorityQueue")

--- Fixed size circular buffer.
-- @see dcsext.containers.RingBuffer
containers.RingBuffer = require("dcsext.containers.RingBuffer")

--- Spatial hash container for 2d positions.
-- @see dcsext.containers.SpatialHashGrid
containers.SpatialHashGrid =
	require("dcsext.containers.SpatialHashGrid")

return containers
