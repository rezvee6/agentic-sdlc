# Integration & release

Load when: opening a PR, touching CI, or releasing. Template: `templates/pr.md`.

## Pull request

- One plan, or one coherent slice of it, per PR. Target ≤ ~400 changed lines; larger → stack PRs.
- Rebase on the base branch; the gate passes after the rebase.
- Description from the template: what, why, AC IDs, evidence (commands run and results), risk, rollback.
- Agents open PRs. Humans merge.

## CI pipeline — cheapest first, fail fast

| Stage | C++ | Rust |
|---|---|---|
| 1 Format | `clang-format --dry-run --Werror` | `cargo fmt --check` |
| 2 Build, warnings as errors | `-Wall -Wextra -Wpedantic -Wconversion -Wshadow -Werror`, on GCC and Clang | `RUSTFLAGS="-D warnings" cargo build --all-targets --locked` |
| 3 Lint | `clang-tidy`, warnings as errors | `cargo clippy --all-targets --locked -- -D warnings` |
| 4 Tests | `ctest --output-on-failure` | `cargo test --workspace --locked` |
| 5 Sanitizers | ASan + UBSan build; TSan build | `cargo miri test` for crates with `unsafe` |
| 6 Supply chain | pinned dependencies, SBOM | `cargo deny check`, `cargo audit` |
| 7 Benchmarks (budgeted paths) | Google Benchmark vs baseline | `cargo bench` vs baseline |
| 8 Docs | Doxygen warnings as errors, if used | `RUSTDOCFLAGS="-D warnings" cargo doc --no-deps` |
| 9 API compatibility (libraries) | ABI diff (`abidiff`) | `cargo semver-checks` |

Rules:

- CI runs the same commands as AGENTS.md. If they differ, fix the difference.
- Never bypass: no `--no-verify`, skipped stages, `continue-on-error`, or retry-until-green.
- A red main branch outranks all feature work.
- Commit lockfiles: `Cargo.lock`; a Conan lockfile, vcpkg baseline, or `FetchContent` pinned to a commit hash.
- Builds reproduce from a clean checkout with pinned toolchains: `rust-toolchain.toml`; compiler version fixed in the CI image.

## Versioning

- SemVer. Breaking a public API, an ABI (C++ shared libraries), or a wire/file format → major.
- Changelog entry in the same PR as any user-visible change: Added / Changed / Fixed / Removed / Security.
- Deprecate before removing: `[[deprecated("use X")]]` / `#[deprecated(note = "use X")]`, keep for one minor release, then remove.

## Release checklist

- [ ] Main is green, including sanitizers and benchmarks.
- [ ] Version bumped; changelog section dated.
- [ ] Release build from a clean checkout; tests run against the release build.
- [ ] Benchmarks within budget against the previous release; numbers recorded.
- [ ] API/ABI compatibility check agrees with the version bump.
- [ ] Artifacts built by CI, not on a developer or agent machine.
- [ ] Tag created by a human. Rollback step written down and tried once.

## After release

Watch crash and error signals for the agreed window. On a regression: revert first, diagnose second.
