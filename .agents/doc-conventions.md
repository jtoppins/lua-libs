# Documentation conventions (LDoc)

Context for any session or subagent writing or editing LDoc comments in
this repository. Loaded via the pointers in AGENTS.md. Public API is
documented with `---` LDoc comments (feeds the docs site):

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

## Parameter tags

Document every formal argument, in positional order. For `_` placeholder
arguments repeat a literal `@param _` tag once per placeholder.
Partially-tagged signatures break ldoc's positional matching ("param and
formal argument name mismatch", "undocumented formal argument") and fail
the gate.

## Running ldoc locally

- Any ldoc stderr output is fatal in `make check`; do not replace it with
  `--fatalwarnings`, which ldoc ignores under `--filter` because it exits
  before that check runs.
- Never run bare `ldoc` in the repository root — default html output
  creates a stray `doc/` directory. Use filter mode only:
  `ldoc -q -i --filter pl.pretty.dump <file>`; if html output is ever
  needed pass `-d /tmp/opencode/...`.
