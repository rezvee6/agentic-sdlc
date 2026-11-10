# Design

Load when: L-sized work. Also load `principles.md`. Templates: `templates/design.md`, `templates/adr.md`.

## Steps

1. Map only what you touch: list the modules involved and their public interfaces (headers / `pub` items). Don't read implementations yet.
2. Sketch 2–3 options, including "extend what exists". Compare in a table: complexity, performance, risk, reversibility.
3. Pick the simplest option that meets every AC and NFR. One line each on why the others lost.
4. Define, in this order:
   - **Interfaces** — real signatures (header declarations / trait and fn signatures). These are committed first.
   - **Ownership** — who owns each object, who borrows, lifetimes, what crosses threads.
   - **Error model** — what can fail, how it is reported, what the caller can do about it.
   - **Concurrency model** — threads/tasks, shared state, lock order, cancellation, shutdown.
   - **Data layout and allocation** on hot paths — container choice, sizes, where allocation happens.
   - **Failure modes** — resource exhaustion, partial writes, timeouts, restart behaviour.
   - **Test seams** — where fakes plug in (clock, I/O, network) without touching production logic.
5. Write an ADR for each decision that is costly to reverse: new dependency, wire/file format, public API shape, threading model, error strategy, `unsafe`/FFI boundary.
6. Get human approval.

## Rules

- Design at the boundary; leave internals to implementation. Signatures yes, function bodies no.
- Dependencies point inward: domain logic depends on nothing volatile; I/O, OS, and frameworks sit at the edge behind an interface.
- No abstraction without two concrete users today, a test seam, or an ADR saying why.
- Prefer compile-time guarantees (types, ownership, immutability) over runtime checks and comments.
- A new dependency must beat writing ≤100 lines yourself. Check licence, maintenance, transitive count, build-time cost.
- State the time and space complexity of each operation on the hot path.
- For each numeric NFR, say how the design meets it and how it will be measured.
- ≤120 lines. Diagrams as text (Mermaid), and only when they replace prose.

## Exit gate

- [ ] Interfaces are written as real signatures.
- [ ] Ownership, error, and concurrency models are stated.
- [ ] Each NFR has a design answer and a measurement plan.
- [ ] ADRs exist for the irreversible decisions.
- [ ] Human approved.
