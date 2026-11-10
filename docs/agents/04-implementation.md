# Implementation

Load when: writing code. Also load `cpp.md` or `rust.md`.

## Loop (per plan task)

1. Read the task block. Read only the files and ranges it names.
2. Read the neighbour pattern it points to. Match its style, error handling, naming, and test layout.
3. Write the test first. Run it. Confirm it fails **for the right reason**.
4. Write the minimum code to pass. Check/build after each logical edit, not after ten.
5. Run the targeted tests, then format and lint the changed files.
6. Read your own diff once (`git diff`). Remove anything the task doesn't require.
7. Commit. Tick the task in `plan.md`.

## Code rules

- Follow the codebase over your preferences. Consistency beats local improvement.
- Smallest change that satisfies the AC. No options, hooks, or generality nobody asked for.
- A function does one thing; if describing it needs "and", split it. Aim for ≤ ~40 lines and ≤3 levels of nesting; return early.
- Names say what, not how. No abbreviations the codebase doesn't already use.
- Handle an error where something can be done about it; otherwise propagate it with context. Never swallow one.
- Validate at the boundary, then trust inside. Convert raw input into types that cannot hold invalid states.
- Immutable by default. Narrowest scope and visibility that works.
- Comments explain why, constraints, and non-obvious invariants — never what the code says. No commented-out code.
- Public items get a doc comment: purpose, preconditions, errors, thread-safety, complexity if not O(1).
- Name magic numbers. Don't duplicate knowledge (see `principles.md` — duplicated text is sometimes fine).
- Delete dead code you create. No compatibility shims unless the spec asks for them.

## Never

- Guess an API. Open the header, `cargo doc`, or the source and read the signature.
- Use a language feature newer than the project's standard, edition, or MSRV.
- Touch files outside the task without re-planning.
- Silence a warning with a cast, `#[allow]`, or `NOLINT` without a one-line justification.
- Leave a `TODO`/`FIXME` without an entry in `followups.md`.

## Debugging protocol

1. Reproduce with the smallest command. No repro → no fix.
2. Read the actual error text. State one hypothesis.
3. Run the cheapest experiment that could disprove it: assert, log line, targeted test, debugger, sanitizer.
4. Fix the root cause, not the symptom. Add a test that fails without the fix.
5. Third failed attempt at the same problem → stop and hand off.

## Commits

`<type>(<scope>): <imperative summary, ≤72 chars>`
Types: `feat` `fix` `refactor` `perf` `test` `docs` `build` `ci` `chore`.
Body only when the why isn't obvious; reference the AC or issue ID. One logical change per commit; refactor and behaviour change never share one.
