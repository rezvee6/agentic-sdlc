# Context & token budget

Load when: a session is getting long, before spawning subagents, or when editing these docs.
The always-on rules are in AGENTS.md §4; this is the detail.

Tokens go on four things: instructions, reading, tool output, and your own writing. Cut each.

## Instructions

- AGENTS.md ≤100 lines; any other doc ≤120. Load a doc once, only on its trigger.
- Enforce by tool, not prose: formatting → formatter; style → linter; invariants → types and tests. Once a tool enforces a rule, delete the prose.
- Keep AGENTS.md unchanged within a session — a stable prefix can be cached; an edited one is paid for again.
- Reference docs by path in prompts and handoffs; never paste their contents.

## Reading

- Locate, then read: `rg -n '<symbol>' -g '*.{h,hpp,cpp,rs}'`, then open ±30 lines around the hit.
- Outline a large file before opening it:
  `rg -n '^\s*(class|struct|enum|namespace|template|pub |fn |impl |trait |mod )' <file>`
- Headers and trait definitions before implementations. Often the signature is all you need.
- Never open `build/`, `target/`, lockfiles, generated code, binaries; put them in the agent tool's ignore file.
- Vendored code (`third_party/`, `vendor/`): only the public header or signature you need, never a browse.
- Don't re-read a file you read or edited this session unless something else changed it.
- `git diff --stat` before `git diff`; `git log --oneline -n 10`, not `git log`.

## Tool output

- Use the cheapest check in the loop: `cargo check`, not `cargo build`; one CMake target, not `all`.
- Compile errors — first error only:
  - C++: `-fmax-errors=3` (GCC) or `-ferror-limit=3` (Clang) in the dev preset; `2>&1 | head -n 40`.
  - Rust: `--message-format=short`; rerun without it only for the one error you need explained.
- Tests: targeted in the loop, failures only (`--output-on-failure`, `cargo test -q`). Full suite once, `| tail -n 30`.
- Long logs: write to a file, then `rg -n 'error|FAILED|panicked' <log> | head`.
- Never run a command whose output you can't bound: verbose builds, full dependency trees, `cat` on unknown files.
- Never run the same failing command twice without changing something.

## Writing

- Edit in place with minimal hunks. Don't rewrite a file to change ten lines.
- One line of intent, then act. Don't echo code back or restate the diff.
- Reports follow the templates: handoff ≤15 lines, review = one line per finding, PR description ≤25 lines.
- No comments that restate code. No documents nobody asked for.

## Sessions

- One role, one phase, ideally one plan task per session. Write state to disk (`plan.md` ticks, `handoff.md`), then start clean.
- Reset when: phase boundary; three strikes; you've read the same file three times; you catch yourself re-deriving an earlier conclusion.

## Subagents

Use for work that is wide but returns little: codebase searches, log triage, "which of these 40 files mention X", independent review.
Don't use for work that needs your accumulated context, or for a lookup one search would answer — every subagent starts cold and pays for orientation again.

Brief in five lines: goal · scope (paths) · constraints · what to ignore · **return format**.
Always cap the return: "≤10 lines, `path:line` + one-line conclusion each, no file contents."

## Model tiering

Mechanical work (search, formatting, log triage, applying a reviewed fix) → smallest capable model.
Spec, design, root-cause debugging, review of concurrency or `unsafe` → strongest model. A wrong decision redone costs more than the tier difference.

## Where the waste usually is

1. Full build or test output dumped into context.
2. Whole files read for one function.
3. Re-reading after every edit.
4. Fix loops with no hypothesis.
5. Oversized always-loaded instructions.
6. Re-planning in a session that should have been reset.
