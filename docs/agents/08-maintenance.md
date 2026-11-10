# Maintenance

Load when: fixing a bug, refactoring, updating dependencies, or editing these docs.

## Bug fix

1. Reproduce. Reduce to the smallest input. Write it as a failing test.
2. Find the root cause — the first point where state went wrong, not where it crashed.
3. Fix it there with the smallest change. The test passes.
4. Search for siblings of the same mistake (`rg` the pattern). Fix them or log them in `followups.md`.
5. Ask why the existing tests and lints missed it. Close that gap if it's cheap — a lint rule beats a note.

Size: usually S. It becomes M if the fix changes documented behaviour.

## Refactor

- Behaviour must not change. Tests stay untouched and green before and after every step.
- No tests around the code? Write characterisation tests first, in a separate commit.
- Small mechanical steps, each compiling and passing: rename → extract → move → inline. Commit each.
- Never in the same commit as a behaviour change; ideally not the same PR.
- Refactor to make the next change easy, not for its own sake. If no change is waiting, log it and move on.
- Prefer tool-driven edits (LSP rename, `clang-tidy --fix`, `cargo clippy --fix`, `cargo fix`) over hand edits, then review the result.

## Dependency update

- One dependency, or one tightly coupled group, per PR.
- Read the changelog between versions for breaking changes; don't infer them from compile errors alone.
- Full gate + sanitizers + benchmarks on budgeted paths.
- Security advisories are S-sized and jump the queue.
- Remove unused dependencies when you find them (`cargo machete`; unused `target_link_libraries` entries).

## Tech debt

- `followups.md` entries become issues at PR time: what, where (`path:line`), why it matters, rough size.
- Debt that caused a bug or slowed a task twice gets scheduled, not logged a third time.

## Incident

Revert or mitigate first. Then write, in under a page and without blame: timeline, root cause, why it wasn't caught, one action per gap (test, lint, alert, doc).

## Keeping these docs lean

When an agent makes the same mistake twice, add the smallest fix, in this order of preference:

1. a compiler flag, lint rule, or CI check;
2. a test;
3. one line in the most specific doc;
4. last resort — one line in AGENTS.md, displacing another. It stays ≤100 lines.

- When a tool starts enforcing a rule, delete the prose.
- When the toolchain changes, re-read the docs and delete rules nobody has needed.
- Changes to instructions go through PR review like code.
