-- SPDX-License-Identifier: LGPL-3.0

local queue      = require("dcsex.containers.queue")
local pqueue     = require("dcsex.containers.pqueue")
local ringbuffer = require("dcsex.containers.ringbuffer")
local graph      = require("dcsex.containers.graph")
local goap       = require("dcsex.containers.goap")

local containers = {
	GOAP          = goap,
	Graph         = graph,
	Queue         = queue,
	PriorityQueue = pqueue,
	RingBuffer    = ringbuffer,
}

return containers
