# Agentic SDLC kit (C++ / Rust)

Markdown instructions that take coding agents through the whole lifecycle — requirements → design → planning → implementation → testing → review → integration/release → maintenance — without loading the whole process into every session.

This README is for humans. Agents never need to read it.

## How it keeps token use down

- **One always-loaded file.** `AGENTS.md` (≤100 lines) holds task sizing, a load-on-demand table, the hard rules, and context discipline.
- **Everything else loads on a trigger.** A typical session reads one phase doc and one language doc.
- **Process scales with the task.** XS / S / M / L sizing means a typo fix doesn't pay for a design phase.
- **State on disk.** Spec, plan, and handoff files let each phase start in a fresh, small context.
- **Tools over prose.** Anything a formatter, linter, compiler flag, or CI check can enforce is not repeated here as a rule.

## Layout

```
AGENTS.md                      always loaded: router + hard rules
docs/agents/
  00-workflow.md               phases, roles, gates, definition of done
  01-requirements.md           spec with testable acceptance criteria
  02-design.md                 interfaces, ownership, error + concurrency models, ADRs
  03-planning.md               small, verifiable tasks
  04-implementation.md         test-first loop, code rules, debugging protocol
  05-testing.md                levels, property tests, fuzzing, sanitizers
  06-review.md                 independent review, severity, output format
  07-integration-release.md    PRs, CI stages, versioning, release checklist
  08-maintenance.md            bugs, refactors, dependencies, keeping docs lean
  principles.md                SOLID, DRY, KISS, YAGNI — with when not to apply
  cpp.md / rust.md             language rules and agent pitfalls
  performance.md               measure-first method, tools, build settings
  security.md                  code, dependencies, agent operating rules
  embedded.md                  cross-compilation, freestanding C++, no_std Rust, on-target testing
  observability.md             log levels, structured logs, metrics, tracing
  context-budget.md            reading, tool output, sessions, subagents
  templates/                   spec, design, adr, plan, handoff, review, pr
docs/work/<id>/                created per task: the agents' working memory
```

## Install

1. Copy `AGENTS.md` and `docs/agents/` into the repository root.
2. Fill in the two `FILL IN` blocks in `AGENTS.md` (project summary, commands). Delete the language column and language doc you don't use.
3. Make the commands real: CMake presets `dev` / `asan` / `tsan` / `release`, or the Cargo equivalents. Agents must be able to run each one verbatim.
4. Put the enforcement in tooling: `.clang-format`, `.clang-tidy`, warning flags; `rustfmt.toml`, `[lints]`, `deny.toml`; CI stages as in `07-integration-release.md`.
5. Add `build/`, `target/`, lockfiles and generated-code directories to your agent tool's ignore file.
6. Protect the main branch: CI required, human approval required.

## Harnesses

The core (`AGENTS.md` + `docs/agents/`) is harness-neutral. Harness-specific wiring lives on its own branch:

| Branch | Harness | Adds |
|---|---|---|
| `main` | Claude Code | core only |
| `kiro` | Kiro CLI V3 | role agents, an orchestrator, language steering, `.kiroignore` |

Changes to the core land on `main` first, then merge into each harness branch.

**Other tools.** If a tool looks for a differently named instruction file, symlink that name to `AGENTS.md` so there is one source of truth.

## Running it

One role per session. Start each with a one-line prompt:

| Role | Prompt |
|---|---|
| Planner | "Task `<id>`: `<request>`. Size it per AGENTS.md and write the spec. Stop for approval." |
| Planner (L) | "Spec `<id>` is approved. Write the design and ADRs. Stop for approval." |
| Planner | "Write the plan for `<id>`." |
| Implementer | "Implement T`<n>` from `docs/work/<id>/plan.md`. Read `handoff.md` first." |
| Reviewer | "Review branch `<b>` against `docs/work/<id>/spec.md`." |
| Integrator | "Open the PR for `<id>`." |

You approve the spec, the design, anything under hard rule 5, the merge, and the release. Everything in between runs unattended.

## Tuning

- Start strict, then relax what proves unnecessary — easier than the reverse.
- When an agent repeats a mistake, fix it in tooling first, a specific doc second, `AGENTS.md` last (see `08-maintenance.md`).
- Size limits (200 lines per task, 400 per PR, three strikes) are starting points; adjust them to your codebase.
- For safety-related code, add your coding standard's checker to the gate and name the standard in the `AGENTS.md` project block.

## Licence

MIT — see `LICENSE`.
