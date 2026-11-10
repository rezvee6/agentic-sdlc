# Plan: <title>

Spec: `docs/work/<id>/spec.md` · Branch: `<branch>`
AC coverage: AC-1 → T2 · AC-2 → T2, T3 · …

## Tasks

- [ ] **T1 — <imperative title>**
  Files: `path/a.hpp:40`, `path/a.cpp`
  Pattern: follow `path/neighbour.cpp:<fn>`
  Covers: AC-<n>
  Test: `<test name>` — <what it asserts>
  Verify: `<exact command>`
  Parallel: yes / no (after T<n>)

- [ ] **T2 — …**

- [ ] **Tn — Verify**
  Full gate; sanitizers (L); benchmarks for numeric NFRs. Record output in `handoff.md`.
