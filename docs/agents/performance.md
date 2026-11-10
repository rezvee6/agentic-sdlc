# Performance

Load when: the spec has a numeric budget, the change touches a known hot path, or a regression is reported.

## Method

1. **Budget** — take the number from the spec. No number → record a baseline and stop once the code is clean.
2. **Benchmark first** — representative input sizes, release build, target-class hardware. Commit the benchmark.
3. **Profile** before changing anything. Optimise what the profile shows, not what looks slow.
4. **One change at a time.** Re-measure. Keep it if the gain is beyond noise; revert if not.
5. **Record** before/after numbers, hardware, compiler and flags in the PR.
6. **Guard** — the benchmark runs in CI against a baseline with a tolerance.

## Where the time usually goes — check in this order

1. **Algorithm** — the wrong complexity beats every micro-optimisation.
2. **Allocation** — per-iteration `new`/`malloc`, `Vec`/`String` growth. Reserve, reuse buffers, arenas or pools for many small objects.
3. **Copies** — pass views and borrows (`std::string_view`, `std::span`, `&str`, `&[T]`); move instead of copy; watch implicit copies in range-for and lambda captures.
4. **Data layout** — contiguous beats pointer-chasing (`vector`/`Vec` over lists and node-based maps); hot fields together, cold fields apart; struct-of-arrays for wide scans.
5. **Indirection** — virtual calls, `dyn`, `std::function`, `Box<dyn Fn>` in inner loops block inlining.
6. **Locks and sharing** — contention, locks held across I/O, false sharing of adjacent atomics. Prefer ownership transfer or per-thread state.
7. **I/O and syscalls** — batch, buffer, avoid per-item flushes.
8. **Branches and bounds checks** — only after 1–7. Restructure so the compiler can vectorise or elide; confirm in the disassembly.

## Tools

| Need | C++ | Rust |
|---|---|---|
| Microbenchmark | Google Benchmark | `criterion` |
| Whole-program timing | `hyperfine` | `hyperfine` |
| CPU profile | `perf record` + flame graph | `cargo flamegraph`, `perf` |
| Heap | heaptrack, Massif | heaptrack, `dhat` |
| Deterministic counts for CI | Callgrind, Cachegrind | Callgrind, Cachegrind |
| Generated code | Compiler Explorer, `objdump -d` | `cargo asm` (cargo-show-asm) |
| Binary size | `bloaty` | `cargo bloat` |

## Benchmark hygiene

- Release build with the shipping flags. Debug numbers mean nothing.
- Stop the optimiser deleting the work: `benchmark::DoNotOptimize` / `std::hint::black_box`.
- Realistic data: sizes, distributions, cache-cold where that's the real case.
- Report a distribution (median, p99), not one run. Know the noise floor.
- Compare on the same machine; pin CPU frequency and core affinity where you can.

## Build settings — decide once, in the release preset/profile, record in an ADR

- C++: `-O2` (`-O3` only when measured), LTO, PGO for a proven hot binary. `-march=native` only if every deployment target matches.
- Rust `[profile.release]`: `lto = "thin"` or `"fat"`, `codegen-units = 1`, `panic = "abort"` if unwinding isn't needed, `debug = "line-tables-only"` to keep profiles readable.
- Keep assertions cheap enough to leave on, or keep a separate checked-release build.

## Rules

- Clarity first on cold paths. An optimisation that isn't on the profile is just complexity.
- An optimisation that hurts readability carries a comment with the measurement that justified it.
- Never trade correctness or safety (`unsafe`, unchecked access, relaxed atomics) for speed without a benchmark showing it matters and tests/sanitizers showing it's sound.
- Latency budgets are about the tail: check p99 and worst case, not the mean.
- Real-time or constrained paths: no allocation, locking, or unbounded loops on the time-critical path — and show the bound.
