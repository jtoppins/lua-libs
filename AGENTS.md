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

## Conventions

- luacheck: Lua 5.1 std, 80-char lines, cyclomatic complexity max 10
  (relaxed for `api/*` and `json.lua`).
- Indentation is hard tabs throughout all Lua sources.
- Every file starts with `-- SPDX-License-Identifier: LGPL-3.0`.
- Public API documented with `---` LDoc comments (feeds the docs site):
  - the module summary (`--- Name - description.`) must be the file's
    first doc block and must appear before any code statement;
  - adjacent `---` blocks merge into one doc entry — separate doc
    blocks with actual code lines;
  - single-function modules: keep the module summary block and the
    `@function` item block separate (code lines between them);
    combining both roles in one block makes LDoc fail with
    `'class' cannot have multiple values; {function,module}` and an
    empty dump;
  - full doc blocks (summary + description) render on the docs site
    for modules and items alike, so write meaningful lead sentences;
  - document public constant tables with one prose doc block each;
    avoid `@field` tags on string-keyed tables (LDoc emits warnings);
  - doc text passes through gendocs as raw markdown (bullet lists OK);
    avoid `%` characters, gendocs template-interpolates `%..%`;
  - escape dunder names as `\_\_init` inside doc comments.
- Naming: lowercase module = set of functions/classes; Uppercase filename =
  single class matching the classname; public methods camelCase,
  verbs-first (`readDocs()`); internal/local fields prefixed `_`,
  internal functions lower_snake_case.
- Tests: busted; `api/dcs-world-api.lua` (on the lua path) stubs the DCS
  environment; name test files `test_NNN_<topic>.lua`.

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
- After editing source files run `make check`, then
  review `git diff` before reporting the change as done.
- After editing doc comments run `make docs`; LDoc warnings fail
  `make check` (the gate treats any ldoc stderr as fatal; do not
  replace it with `--fatalwarnings`, which ldoc ignores under
  `--filter` because it exits before that check runs).
- For multi-file comment-only documentation work, fan out parallel
  doc-writer subagents over disjoint file sets, then review
  `git diff` before reporting the change as done; treat an
  interrupted subagent's output as unverified until checked. Draft
  all task prompts first and issue every launch in a single message;
  confirm the launched count matches the batch list before reviewing
  any results. Reserve make targets for the coordinating session
  during fan-outs; agents verify with luacheck and solo ldoc dry-runs.
- Feature branches off `master`; PRs merge into `master`.
- Tagging `v*` triggers a release build (`make dist` zip attached to the
  GitHub release).
- `todos.md` holds coding standards and planned modules.
