# Design: <title>

Spec: `docs/work/<id>/spec.md` · Status: draft / approved (<who>, <date>)

## Options
| Option | Complexity | Performance | Risk | Reversible |
|---|---|---|---|---|
| A — <name> | | | | |
| B — <name> | | | | |

**Chosen:** <A>, because <one line>. B lost because <one line>.

## Interfaces
```
<real signatures: header declarations / trait + fn signatures>
```

## Ownership
<Who owns what; who borrows; lifetimes; what crosses threads.>

## Error model
<What can fail; how it is reported; what the caller can do.>

## Concurrency
<Threads/tasks; shared state; lock order; cancellation; shutdown.>

## Hot path
<Data layout; where allocation happens; complexity per operation.>

## NFR answers
| NFR | How the design meets it | How it is measured |
|---|---|---|
| | | |

## Failure modes
- <condition> → <behaviour>

## Test seams
<Where fakes plug in.>

## Threat model (if input crosses a trust boundary)
Assets · entry points · trust boundaries · attacker gain · mitigations.

## ADRs
- `adr-<n>-<slug>.md`
