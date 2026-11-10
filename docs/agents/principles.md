# Design principles

Load when: designing (L) or reviewing design.
Each principle is a tool with a trigger and a cost. Apply it when the trigger is present, not by default.

| Principle | Do | Apply when… | Over-applied looks like |
|---|---|---|---|
| **S** — single responsibility | One reason to change per type/module | A type changes for unrelated reasons; you can't name it without "and" or "Manager" | Dozens of one-method classes; logic scattered across files |
| **O** — open/closed | Add behaviour by adding code, not editing stable code | A third variant of the same `switch`/`match` arrives | Plugin systems and visitor hierarchies for two cases |
| **L** — Liskov substitution | Every implementation honours the interface's contract: pre/postconditions, errors, complexity | Callers check the concrete type or special-case one implementation | Never — it always applies once an interface exists |
| **I** — interface segregation | Small, role-shaped interfaces | Implementers stub out methods; callers use 2 of 10 | One-method interfaces everywhere; unreadable trait bounds |
| **D** — dependency inversion | Core logic depends on abstractions it owns; I/O plugs in at the edge | Logic can't be tested without disk, network, clock, or hardware | An interface for every class "for testability" |
| **DRY** | One authoritative place for each piece of *knowledge* (rule, constant, format) | The same decision is encoded twice and must change together | Merging code that merely looks alike; helpers with flag parameters |
| **KISS** | Fewest moving parts that meet the spec | Always | — |
| **YAGNI** | Build for the ACs in the spec, nothing speculative | You're adding a parameter, hook, or layer "for later" | Refusing a seam that is obviously needed and free today |

## Working rules

- **Rule of three.** Tolerate duplication twice. Extract on the third occurrence, when you can see what actually varies. A wrong abstraction costs more than duplication.
- **Deep modules.** Small interface, substantial implementation. Wrappers that only forward add cost and hide nothing.
- **Composition over inheritance.** Inherit only for a true is-a with a stable base; otherwise hold a member or take a trait/concept.
- **Make illegal states unrepresentable.** Enums/variants for states, newtypes for units and IDs, non-null by construction. Parse once at the boundary into a valid type.
- **Functional core, imperative shell.** Pure logic in the middle; side effects at the edges.
- **Explicit over implicit.** No hidden global state, singletons, or action at a distance. Pass dependencies in.
- **Least privilege in code.** Narrowest visibility, immutable by default, smallest scope.
- **Law of Demeter.** Talk to what you're given, not its internals; `a.b().c().d()` is a coupling chain.
- **Fail fast, fail loud.** Detect a violated invariant at the earliest point; never continue in a corrupt state.
- **High cohesion, low coupling.** Things that change together live together; modules know as little about each other as possible.

## Static vs dynamic dispatch

| Use | When |
|---|---|
| `std::variant` / `enum` | closed set of alternatives known at compile time — usually the best default |
| Templates + concepts / generics + trait bounds | hot paths, few concrete types, inlining matters |
| Virtual functions / `dyn Trait` | plugin points, heterogeneous collections, stable ABI boundaries, limiting compile time and binary size |

Neither is free: generics cost compile time and code size; dynamic dispatch costs an indirection and blocks inlining. Choose per boundary and state the choice in the design.

## Maintainability checks

- Can a new reader find where behaviour X lives in under a minute?
- Can this module be tested without constructing half the system?
- If this requirement changes, how many files change? (Target: one.)
- Is there exactly one way to do this in the codebase?
