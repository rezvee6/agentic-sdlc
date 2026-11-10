# Testing

Load when: writing or fixing tests.

## What to write

| Level | Covers | Share | Speed |
|---|---|---|---|
| Unit | one function or type; pure logic; edge cases | most | milliseconds |
| Integration | modules together across a real boundary (filesystem, IPC, DB) | some | under 1 s each |
| End-to-end | one or two critical paths through the built binary | few | seconds |

Plus, where they fit:

- **Property tests** for anything with an invariant or round-trip (parse/print, encode/decode, sort, state machines). Rust: `proptest`. C++: RapidCheck.
- **Fuzzing** for anything that parses untrusted bytes. Rust: `cargo-fuzz`. C++: libFuzzer. Keep the corpus; every crash input becomes a regression test.
- **Sanitizers** over the whole suite: ASan + UBSan in one build, TSan in another. Rust: Miri on tests that reach `unsafe`.
- **Benchmarks** for any AC with a number — see `performance.md`. Never assert timing in a unit test.

## Rules

- One behaviour per test. The name states it: `<unit>_<condition>_<expected>`.
- Arrange / act / assert, visibly separated. No loops or branches in a test.
- Test behaviour through the public interface. A test that breaks on a refactor is testing the wrong thing.
- Every AC ID has at least one test that references it and fails without the change.
- Cover the boundaries: empty, one, many, max, max+1, invalid, duplicate, out of order, concurrent.
- Test error paths as carefully as the happy path.
- Deterministic: no sleeps, wall clock, real network, shared global state, or order dependence. Inject clocks, RNG seeds, and I/O.
- Prefer real objects, then fakes, then mocks. Mock only at process boundaries you don't own.
- Every bug fix starts with a failing test that reproduces it.
- A flaky test is a bug: fix it or quarantine it with a tracked issue the same day. Never retry until green.
- Coverage is a flashlight, not a target: look at uncovered lines in your diff and decide. No assertion-free tests to move the number.

## Never

- Change an existing test's expectation to match new output unless the spec changed the behaviour — and say so in the commit.
- Special-case test inputs in production code.
- Delete or disable (`#[ignore]`, `DISABLED_`) a failing test.
- Assert on log text, addresses, or the iteration order of unordered containers.

## Running

- Loop: targeted (`ctest -R <regex>` / `cargo test <filter>`). Gate: full suite once.
- On failure, read the first failing assertion only; fix; rerun that test.
- Rust: doctests count — public API examples run under `cargo test --doc`.
- C++: build tests with the same warnings and standard as production code.
