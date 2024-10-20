-- SPDX-License-Identifier: LGPL-3.0

local queue      = require("libs.containers.queue")
local pqueue     = require("libs.containers.pqueue")
local ringbuffer = require("libs.containers.ringbuffer")
local graph      = require("libs.containers.graph")
local goap       = require("libs.containers.goap")

local containers = {
	GOAP          = goap,
	Graph         = graph,
	Queue         = queue,
	PriorityQueue = pqueue,
	RingBuffer    = ringbuffer,
}

return containers
