# Agentic SDLC kit (C++ / Rust)

Markdown instructions that take coding agents through the whole lifecycle — requirements → design → planning → implementation → testing → review → integration/release → maintenance — without loading the whole process into every session.

This README is for humans. Agents never need to read it.

**Branch: `kiro`** — the shared core plus the Kiro CLI harness. Other harnesses live on other branches (`main` is Claude Code). The core (`AGENTS.md`, `LICENSE`, `docs/agents/`, `scripts/`, `.github/workflows/`) is changed only on `main`; CI opens a `sync/main-to-kiro` pull request to bring changes here, and fails any push or pull request that edits the core on this branch. Details: the "Keeping branches in sync" section of the README on `main`.

## How it keeps token use down

- **One always-loaded file.** `AGENTS.md` (≤100 lines) holds task sizing, a load-on-demand table, the hard rules, and context discipline.
- **Everything else loads on a trigger.** A typical session reads one phase doc and one language doc.
- **Process scales with the task.** XS / S / M / L sizing means a typo fix doesn't pay for a design phase.
- **State on disk.** Spec, plan, and handoff files let each phase start in a fresh, small context.
- **Tools over prose.** Anything a formatter, linter, compiler flag, or CI check can enforce is not repeated here as a rule.

## Layout

```
AGENTS.md                      always loaded: router + hard rules
.kiroignore                    build output, lockfiles, secrets: unreadable to agents
.kiro/agents/                  Kiro CLI agents: planner, implementer, reviewer, integrator, orchestrator
.kiro/steering/                loads cpp.md / rust.md when matching source files are in play
harness/check.sh               CI check for the Kiro agents (front matter, paths, permission coverage)
scripts/, .github/workflows/   docs checks and branch sync (core: shared with every branch)
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

1. Copy `AGENTS.md`, `docs/agents/`, `.kiro/` and `.kiroignore` into the repository root.
2. Fill in the two `FILL IN` blocks in `AGENTS.md` (project summary, commands). Delete the language column and language doc you don't use.
3. Make the commands real: CMake presets `dev` / `asan` / `tsan` / `release`, or the Cargo equivalents. Agents must be able to run each one verbatim.
4. Put the enforcement in tooling: `.clang-format`, `.clang-tidy`, warning flags; `rustfmt.toml`, `[lints]`, `deny.toml`; CI stages as in `07-integration-release.md`.
5. Add your generated-code directories to `.kiroignore`.
6. Trim the shell rules in `.kiro/agents/*.md` to the commands you kept in step 2.
7. Protect the main branch: CI required, human approval required.

## Kiro CLI

Written for Kiro CLI V3 (`kiro-cli --version` ≥ 3.0.0), which reads the root `AGENTS.md` in every session, including custom-agent sessions.

| Piece | What it does |
|---|---|
| `AGENTS.md` | Always loaded. Routes to `docs/agents/*` on demand. |
| `.kiro/agents/<role>.md` | One agent per role. Each exposes only the tools it needs, preloads its one phase doc, and carries its permissions. |
| `.kiro/steering/lang-*.md` | `fileMatch` pointers: load `cpp.md` / `rust.md` when matching source files are in play. |
| `.kiroignore` | Blocks reads and searches of build output, lockfiles and secrets. |

```
kiro-cli chat --agent planner          # start a session in a role
/agent swap implementer                # switch role mid-session (prefer a fresh session)
/agent list                            # confirm the five agents loaded
kiro-cli chat --agent orchestrator     # run a task end to end (see below)
kiro-cli chat --v3 --agent implementer --no-interactive "Implement T2 from docs/work/42/plan.md"
```

**Permissions.** Each agent pre-approves the commands in the `AGENTS.md` table and writes inside its remit; everything else prompts.

- The implementer is prompted before editing lint, format, toolchain or CI config, `.kiro/`, `AGENTS.md` or `docs/agents/` (hard rule 2).
- Force-push and `--no-verify` are denied for every agent that can commit (hard rule 8). The integrator cannot merge, tag, or push to `main`.
- Planner and reviewer may write only under `docs/work/` without a prompt.
- Pre-approving `cargo`, `cmake` and `ctest` lets build scripts and tests run unprompted. Remove those rules if you want to approve each run.
- In headless runs a prompt becomes a denial, so anything not pre-approved fails rather than waits.

**Independent review.** The implementer can hand off to `reviewer` as a sub-agent. Sub-agents don't see the parent conversation, which is the independence `06-review.md` asks for.

**End to end.** `orchestrator` chains the four roles as sub-agents: it reads the state in `docs/work/<id>/`, runs the next step, and stops at each human checkpoint (spec approval, design approval, merge). Start it again with the task id to resume.

- It has no write or shell tools of its own, so it can only delegate.
- Kiro runs a sub-agent's tool call unprompted only if the parent allows it too, so the orchestrator carries the union of the role agents' allow rules. Each role's narrower rules still apply. If you change a role's rules, change the orchestrator's to match.
- It costs more tokens than running roles by hand, because every step starts a cold sub-agent. Use it for unattended runs; run roles directly when you are at the keyboard.

**Keep the docs out of `.kiro/steering/`.** Steering files without front matter load into every session; that would put all ~14k tokens of this kit in every context. Only the two `fileMatch` pointers live there.

**Specs.** Kiro's `/spec` workflow covers the same ground as phases 1–3. Use one or the other per task, not both.

**Kiro CLI 2.x.** `AGENTS.md` and the docs work unchanged. The agent files use the V3 format (Markdown, `permissions`), and 2.x does not auto-load `fileMatch` steering, so there the `AGENTS.md` table does the routing.

**Other tools.** If a tool looks for a differently named instruction file, symlink that name to `AGENTS.md` so there is one source of truth.

## Running it

One role per session (`kiro-cli chat --agent <role>`). Start each with a one-line prompt:

| Role | Prompt |
|---|---|
| Planner | "Task `<id>`: `<request>`. Size it per AGENTS.md and write the spec. Stop for approval." |
| Planner (L) | "Spec `<id>` is approved. Write the design and ADRs. Stop for approval." |
| Planner | "Write the plan for `<id>`." |
| Implementer | "Implement T`<n>` from `docs/work/<id>/plan.md`. Read `handoff.md` first." |
| Reviewer | "Review branch `<b>` against `docs/work/<id>/spec.md`." |
| Integrator | "Open the PR for `<id>`." |
| Orchestrator | "Task `<id>`: `<request>`." — or "Resume `<id>`." |

You approve the spec, the design, anything under hard rule 5, the merge, and the release. Everything in between runs unattended.

## Tuning

- Start strict, then relax what proves unnecessary — easier than the reverse.
- When an agent repeats a mistake, fix it in tooling first, a specific doc second, `AGENTS.md` last (see `08-maintenance.md`).
- Size limits (200 lines per task, 400 per PR, three strikes) are starting points; adjust them to your codebase.
- For safety-related code, add your coding standard's checker to the gate and name the standard in the `AGENTS.md` project block.

## Licence

MIT — see `LICENSE`.
