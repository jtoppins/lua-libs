# Lua conventions

Context for any session or subagent editing this repository's Lua sources.
Loaded via the pointers in AGENTS.md.

## Style and linting

- luacheck: Lua 5.1 std, 80-char lines, cyclomatic complexity max 10
  (relaxed for `api/*` and `json.lua`).
- Indentation is hard tabs throughout all Lua sources.
- Every file starts with `-- SPDX-License-Identifier: LGPL-3.0`.

## Naming

- lowercase module name = set of functions/classes;
- Uppercase filename = single class matching the classname;
- public methods camelCase, verbs-first (`readDocs()`);
- internal/local fields prefixed `_`;
- internal functions lower_snake_case.

## Tests

- busted; config in `tests/.busted`;
- `api/dcs-world-api.lua` (on the lua path) stubs the DCS environment;
- name test files `test_NNN_<topic>.lua`.
