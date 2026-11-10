# Requirements

Load when: writing `spec.md` (M, L). Template: `templates/spec.md`.

## Steps

1. Restate the goal in one sentence: who needs what, and why.
2. Search for existing behaviour that overlaps (`rg`). Extend before adding.
3. Write acceptance criteria (ACs). Each is one observable, testable statement:
   `When <trigger> [and <state>], the system shall <observable result>.`
   Cover error and boundary cases: empty, maximum size, invalid, concurrent, out of resource.
4. Write non-functional requirements as numbers, not adjectives (table below).
5. Write the out-of-scope list. It is as binding as the criteria.
6. List open questions and ask them in one batch. Don't proceed on a guess that would change a criterion.
7. Get human approval. Record who and when at the top of the spec.

## Non-functional requirements — make them measurable

| Area | Pin down |
|---|---|
| Latency / throughput | p50 and p99 target, at what input size, on what hardware |
| Memory | peak heap or RSS budget; is allocation allowed after initialisation? |
| Binary size / startup | limit, if the target is constrained |
| Concurrency | which threads call this; reentrancy; ordering guarantees |
| Compatibility | API/ABI stability, wire or file format, compiler / standard / MSRV floor |
| Failure | behaviour on bad input, partial failure, timeout; is abort/panic acceptable? |
| Platforms | OS, architecture, endianness, toolchain versions |
| Safety / security | trust boundary of each input; applicable standard (e.g. MISRA, ISO 26262) |

If a number is unknown, write "no budget — record a baseline". Never invent one.

## Rules

- Describe behaviour, not implementation. "Parses a 1 MB frame in under 2 ms" yes; "uses a hash map" no.
- One spec per independently shippable change. More than ~10 ACs → split.
- Each criterion gets an ID (`AC-1`…). Tasks, tests, and review refer to IDs, not prose.
- ≤60 lines. Link to existing docs by path; don't copy them.

## Exit gate

- [ ] Every AC is verifiable by an automated test.
- [ ] Error and boundary cases are covered.
- [ ] NFRs are numeric or explicitly "baseline only".
- [ ] Out of scope is written.
- [ ] No open questions. Human approved.
