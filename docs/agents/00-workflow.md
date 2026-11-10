# Workflow

Load when: unsure of phase or role, or handing work over.

## Phases

| # | Phase | Sizes | Input | Artifact | Exit gate |
|---|---|---|---|---|---|
| 1 | Requirements | M L | request | `spec.md` | every acceptance criterion (AC) testable; human approved |
| 2 | Design | L | spec | `design.md`, ADRs | interfaces, ownership, error model defined; human approved |
| 3 | Planning | M L | spec (+ design) | `plan.md` | every AC maps to a task; every task has a verify command |
| 4 | Implementation | all | one plan task | commits | task's tests pass; plan ticked |
| 5 | Verification | all | branch | gate output | format + lint + full tests pass (+ sanitizers for L) |
| 6 | Review | S self; M L independent | spec + diff | `review.md` | no blocker or major finding open |
| 7 | Integration | all | reviewed branch | PR | CI green; human merges |
| 8 | Release | when shipping | main | tag, changelog | release checklist complete |
| 9 | Maintenance | ongoing | bug, debt | fix + regression test | gap that let it through is closed |

Artifacts live in `docs/work/<id>/` (`<id>` = issue number or short slug). Templates: `docs/agents/templates/`.

## Roles

One role per session. A role change is a context reset.

| Role | Reads | Writes | Must not |
|---|---|---|---|
| Planner | request, module boundaries | spec, design, plan | write production code |
| Implementer | one plan task and the files it names | code, tests, plan ticks | change spec or plan scope silently |
| Reviewer | spec, diff, gate output | `review.md` | see the implementer's conversation; fix the code |
| Integrator | `review.md`, CI output | PR, changelog | merge without human approval |

Reviewer independence is the point: a reviewer that shares the author's context shares the author's blind spots.

## Going backwards

- Implementation shows the spec is wrong or incomplete → stop, amend `spec.md`, get re-approval. Never code around it.
- A task passes ~200 changed lines or touches files not in the plan → stop, re-plan.
- Review finds a design flaw → back to phase 2, not a patch.
- The gate fails on something unrelated to your change → report it; don't fix it on this branch.

## Parallel work

Tasks run in parallel only if their file sets are disjoint and the interface between them is already committed. One git worktree per agent. Merge in plan order; re-run the gate after each merge.

## Definition of done

- [ ] Every AC has a passing test that would fail without the change.
- [ ] Gate passed in this session on the final diff.
- [ ] No blocker or major review finding open.
- [ ] Public API documented; changelog entry if user-visible.
- [ ] `plan.md` fully ticked; `followups.md` lists anything deferred.
- [ ] The diff contains only in-scope changes.

## Handoff

Write `handoff.md` from the template (≤15 lines) whenever you stop: phase boundary, three strikes, or blocked.
The next session starts from AGENTS.md + `handoff.md` + the one artifact it needs. If it needs more, the handoff was too thin.
