# AGENTS.md

Lua library extensions (DCSExt) for the DCS mission scripting environment.
Code targets Lua 5.1 and runs inside DCS's sandbox where `os`, `io`, `lfs`,
and `package`/`require` are removed after loading — don't rely on them at
runtime.

## Commands

- Setup deps: `./scripts/devel-setup` (lua5.1, luacheck, busted, ldoc, lua-zip)
- CI gate: `make check` (= lint + tests + doc lint); CI runs `make V=1 check`
- Lint only: `make syntax` (luacheck + `git diff --check` whitespace check)
- Tests: `make tests` (busted, config in `tests/.busted`)
- Single test: `(cd tests && busted test_007_vector.lua)`; filter with `-t <name>`
- Docs: `make docs` (LDoc + `scripts/gendocs` → `docs/_reference/`)
- Install to DCS saved games: `make install PREFIX="<SAVED_GAMES>/DCS"`
- Release zip: `make dist`

## Generated code

- `src/dcsext.lua` is GENERATED from `src/dcsext.lua.in` (sed swaps
  `%VERSION%` for `git describe`). Edit the `.in` file, never the output.
  Both it and `docs/_reference/` are gitignored; run `make` once on a fresh
  clone before testing since tests do `require("dcsext")`.
- New submodule/class: add `src/dcsext/<Name>.lua`, then register it in its
  area's wrapper (`src/dcsext/<area>.lua`) AND in the require list of
  `src/dcsext.lua.in`.
- New DCS globals go in `.luacheckrc` `read_globals`.
- `.build/` is untracked local directory for scratch output; don't commit it.

## Agent context files

This file stays thin; load the context file matching your task before
starting work:

| Task | Read first |
|------|------------|
| Editing Lua sources | `.agents/lua-conventions.md` |
| Writing or editing LDoc comments | `.agents/doc-conventions.md` |
| Coordinating parallel doc fan-outs | `.agents/docs-workflow.md` |

## Workflow

- Track multi-step work in the session task list and keep statuses
  truthful in real time: mark an item `in_progress` when starting it
  and `completed` only once its verification has actually run (gate
  green, diff reviewed, commit created); never carry planning-time
  statuses unrefreshed into later turns.
- Reconcile the list at every checkpoint - after drafting plans or
  prompts, after each launch-count confirmation, after each gate run,
  and after each commit - updating statuses before processing results
  or reporting progress.
- Before reporting a change as done, do a final tracker sync so every
  item matches verified reality.
- When resuming a session, first reconcile the list against repo state
  (`git log --oneline`, `git status`) and correct stale statuses before
  starting new work.
- After editing source files run `make check`, then review `git diff`
  before reporting the change as done.
- Feature branches off `master`; PRs merge into `master`.
- Tagging `v*` triggers a release build (`make dist` zip attached to the
  GitHub release).
- `todos.md` holds coding standards and planned modules.
