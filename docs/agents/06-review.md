# Review

Load when: reviewing a diff. Template: `templates/review.md`.

## Setup

- Fresh session. Inputs: `spec.md`, `git diff <base>...HEAD`, gate output. Not the author's conversation or reasoning.
- Read the spec, then the tests, then the code. The tests show what the author thought the requirement was.
- Open surrounding code only where the diff can't be judged without it.

## Passes, in order

1. **Scope** — does the diff do what the spec says, all of it, and nothing else?
2. **Checks intact** — any test deleted, weakened, or disabled? Lint or CI config loosened? Suppressions added?
3. **Correctness** — for each AC, find the code and the test. Walk boundaries and error paths by hand.
4. **Safety** — ownership and lifetimes, bounds, integer overflow and truncation, uninitialised data, undefined behaviour, data races, lock order, `unsafe` invariants, exception/panic safety, leaks on error paths.
5. **Tests** — would each fail without the change? Deterministic? Error paths covered?
6. **Design** — right place for this code? Is each abstraction earned? Duplicated knowledge? Public API minimal and hard to misuse?
7. **Performance** (hot paths only) — allocations, copies, complexity, locks held across slow calls. Any speed claim needs numbers.
8. **Readability** — names, function size, comments that explain why.

A failure in passes 1–2 ends the review: report it and stop.

## Verify, don't trust

- Run the gate yourself.
- Where it's cheap, run the new tests against the base commit's code — they should fail.
- Any claim in the PR description ("no behaviour change", "2× faster") needs evidence in the diff or the output.

## Findings

One line each: `path:line — <severity> — <problem> — <concrete fix>`

| Severity | Meaning | Blocks merge |
|---|---|---|
| blocker | wrong behaviour, UB, data race, security hole, checks weakened, AC unmet | yes |
| major | AC or error path untested; design flaw that will cost later; regression on a budgeted path | yes |
| minor | readability, naming, small duplication | no |
| nit | taste — at most 5, or omit | no |

## Rules

- No praise, no summary of what the diff does, no restated code.
- Report; don't fix. The author fixes, and you re-review only the changed lines.
- Something a formatter or linter should catch → one finding ("add lint rule X"), not N findings.
- Out-of-scope problems you notice → `followups.md`, not findings.
- End with a verdict line: `APPROVE` or `CHANGES REQUIRED (n blocker, n major)`.

## Self-review (S, and before requesting any review)

Read `git diff` once, top to bottom, as if someone else wrote it. Apply passes 1–3 and 8.
