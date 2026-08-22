# Parallel documentation workflow (fan-outs)

Context for coordinating sessions running multi-file comment-only
documentation work through doc-writer subagents.

## Protocol

- fan out parallel doc-writer subagents over disjoint file sets grouped by
  area, with balanced effort; skip tier-4/vendored files;
- draft ALL task prompts before launching anything;
- issue every launch in a single message; confirm the launched count
  matches the batch list before reviewing any results;
- reserve make targets for the coordinating session during fan-outs;
  agents verify with luacheck and solo ldoc dry-runs;
- treat ANY subagent report — audits included — as unverified until the
  coordinator spot-checks flagged files against the repo;
- treat an interrupted subagent's output as unverified until checked;
- review `git diff` before reporting the change as done.

## Mandatory prompt contents

Every fan-out prompt must instruct the agent to:

- read AGENTS.md first plus the context files it points to (at minimum
  `.agents/doc-conventions.md`);
- keep edits comment-only, verified afterwards via `git diff`;
- follow hard tabs and the 80-column limit including comments;
- avoid `%` characters in doc text; escape dunder names (`\_\_init`);
- verify with `luacheck <files>` plus a solo ldoc dry-run
  (`ldoc -q -i --filter pl.pretty.dump <file>`) whose stderr is empty,
  ignoring only "@see module not found";
- never run make targets and never commit — delivery belongs to the
  coordinating session.

## Delivery

After the shared gate passes green:

- deliver one commit per batch, message form `docs(<area>): ...`;
- stage only that batch's files;
- run `git diff --cached --check` before each commit;
- vendored and generated files stay untouched.
