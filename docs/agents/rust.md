# Rust

Load when: writing or reviewing Rust. Edition and MSRV are in `Cargo.toml` (`edition`, `rust-version`) — check before using a feature.

## Ownership & borrowing

- Borrow in parameters (`&str`, `&[T]`, `&Path`); own in struct fields; return owned unless borrowing from an argument is obvious.
- A borrow-checker error is design feedback. Before reaching for `.clone()`, `Rc<RefCell<_>>`, `'static`, or `unsafe`, ask: can the scope shrink, the data be split, or ownership move?
- `.clone()` is fine when it's cheap or genuinely needed — not as a reflex, and not on hot paths.
- Don't add lifetime parameters speculatively; elision covers most cases. A struct full of lifetimes usually wants owned data.
- `Arc` across threads, `Rc` within one. Keep interior mutability (`Cell`, `RefCell`, `Mutex`) as narrow as possible.

## Types & API

- Make invalid states unrepresentable: enums for states, newtypes for IDs and units, `NonZero*`, `Option` instead of sentinels.
- Parse at the boundary (`TryFrom`, `FromStr`) into a validated type; no re-validation inside.
- Derive `Debug` always; `Clone`, `PartialEq`, `Eq`, `Hash`, `Default` where meaningful.
- Conversions via `From`/`TryFrom`. Naming: `as_` (free, borrowed), `to_` (costly), `into_` (consuming).
- `#[must_use]` on results that matter; `#[non_exhaustive]` on public enums and structs likely to grow.
- Private by default, then `pub(crate)`, then `pub` for the real API only. Every `pub` item is documented; non-trivial ones get an example (doctests are tests).
- No boolean flag parameters — use an enum. A builder for more than three optional parameters.

## Errors

- Libraries: a concrete error enum (`thiserror`) that callers can match. Binaries: `anyhow` with `.context(...)` at each layer.
- Propagate with `?`. No `unwrap()`/`expect()` on library code paths, except `expect("why this cannot fail")` for a proven invariant. Fine in tests.
- Panics are for bugs, never for bad input. Document `# Errors` and `# Panics` on public functions.
- Keep the cause: wrap with `#[source]`/`#[from]`, don't stringify.

## Dispatch & generics

- `enum` for closed sets; generics for hot paths with few concrete types; `dyn Trait` at plugin boundaries and to contain compile time and binary size.
- Keep generic functions thin: a generic shell around a non-generic inner function.
- Small traits. No trait with a single implementor unless it is a test seam at an I/O boundary.

## Unsafe & FFI

- Default to `#![forbid(unsafe_code)]` per crate. Where it's needed, isolate it in one small module behind a safe API.
- Every `unsafe` block has a `// SAFETY:` comment justifying each invariant; every `unsafe fn` has a `# Safety` section. Enable the `unsafe_op_in_unsafe_fn` lint.
- Run Miri on the tests that reach it. Fuzz anything that feeds it parsed bytes.
- FFI: `#[repr(C)]`; no panic across the boundary (`catch_unwind` or `panic = "abort"`); explicit ownership rule for every pointer; null checks at entry.

## Concurrency & async

- Let `Send`/`Sync` do the work. Prefer moving ownership through channels to `Arc<Mutex<_>>`.
- Hold locks briefly and in a fixed order; never across `.await`, I/O, or callbacks.
- Async is for I/O-bound concurrency. Never block the executor: CPU work and blocking calls go to `spawn_blocking` or a thread pool.
- Every spawned task has an owner that joins or cancels it. Consider cancellation at each `.await`.
- Atomics: `SeqCst` unless a benchmark and a reviewer justify weaker.

## Performance defaults

- Iterators over index loops; don't `collect()` only to iterate again.
- `with_capacity` when the size is known; reuse buffers with `clear()`; `&str` or `Cow<str>` where ownership isn't needed.
- No `format!`, `to_string()`, or other allocation in inner loops. Keep `Box<dyn Trait>` out of hot paths.
- `#[inline]` only with a measurement. Release profile settings: see `performance.md`.

## Project hygiene

- Lints in the `[lints]` table of `Cargo.toml` (workspace-inherited), not scattered `#![deny]`. Clippy defaults as errors; opt into `pedantic` lints one by one.
- Every `#[allow]` carries a reason; prefer `#[expect(lint, reason = "...")]` where the MSRV permits.
- Fewest dependencies possible; `default-features = false`, then enable what's used. `cargo deny` and `cargo audit` in CI. Commit `Cargo.lock`.
- Large projects: a workspace of small crates (parallel builds, enforced boundaries). Features are additive, never mutually exclusive.
- `rust-toolchain.toml` pins the toolchain; CI also builds on the MSRV.

## Agent pitfalls

- Guessing crate APIs or versions. Read `cargo doc`, or the source under `~/.cargo/registry/src`.
- Quieting the borrow checker with clones, or the type checker with `as` (it truncates silently — use `try_into()` / `From`).
- Ignoring rustc's suggested fix. Read the `help:` line first; it is usually right.
- `cargo build` in the loop instead of `cargo check`; the whole suite for one test.
- Adding `async` or a new crate for a problem a plain function solves.
- Editing `Cargo.lock` by hand.
