# Planning

Load when: turning a spec (+ design) into `plan.md` (M, L). Template: `templates/plan.md`.

## A good task

- One commit. Builds and passes tests on its own.
- ≤ ~200 changed lines and ≤ ~5 files. Larger → split.
- Names the files it touches, the AC IDs it covers, the test it adds, and the command that proves it.
- Executable by a fresh session given only AGENTS.md, the task block, and the files it names.

## Order

1. Interfaces and types first — signatures, no logic. This unblocks parallel work.
2. The riskiest or least understood piece next. Fail early.
3. Core logic behind the interface, test-first.
4. Edges: I/O, wiring, configuration.
5. Docs, changelog, cleanup last.

Refactors needed to make room go in their own task **before** the behaviour change.

## Steps

1. List every AC ID. Each must appear in at least one task.
2. Locate insertion points with search; record `path:line` in the task so the implementer doesn't search again.
3. Find one existing neighbour that does something similar; name it as the pattern to follow.
4. Mark tasks with disjoint file sets as parallelisable.
5. End with a verification task: full gate, sanitizers (L), benchmarks for any NFR with a number.

## Rules

- The plan is a checklist, not an essay. ≤8 lines per task.
- No task says "implement X" without saying where, and how it is verified.
- Don't pre-write code in the plan. Signatures only where they pin an interface.
- If you can't name the verify command, the task isn't understood yet.

## Exit gate

- [ ] Every AC is mapped to a task.
- [ ] Every task has files, a test, and a verify command.
- [ ] No task exceeds ~200 lines.
- [ ] Refactors are separated from behaviour changes.
