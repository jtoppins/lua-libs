-- SPDX-License-Identifier: LGPL-3.0

--- algorithms - reusable algorithms.
-- Namespace aggregating the algorithm submodules:
--
-- * `search_astar` - A* shortest path search over a graph

local _algos = {}

--- A* shortest path search over a graph.
-- @see dcsext.algorithms.search_astar
_algos.search_astar = require("dcsext.algorithms.search_astar")

return _algos
