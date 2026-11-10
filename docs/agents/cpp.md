# C++

Load when: writing or reviewing C++. The standard is whatever `CMAKE_CXX_STANDARD` says — check before using a feature.

## Feature floor

| C++17 | C++20 | C++23 |
|---|---|---|
| `string_view`, `optional`, `variant`, structured bindings, `if constexpr`, `[[nodiscard]]`, `filesystem` | concepts, `span`, ranges, `jthread`, `format`, `<=>`, designated initialisers, `bit_cast` | `expected`, `print`, `mdspan`, deducing `this`, `flat_map` |

Library support lags the language. If the code must build on an older toolchain, compile there before relying on a feature.

## Ownership & lifetime

- RAII for every resource. No naked `new`/`delete`/`malloc`. Rule of zero; if you write one special member, define or delete all five.
- `std::unique_ptr` by default; `std::shared_ptr` only for genuinely shared ownership. A raw pointer or reference is non-owning and isn't stored beyond the call unless the lifetime is documented.
- Views (`string_view`, `span`, iterators, references) never outlive their owner: don't return them to temporaries, hold them across container mutation, or store them in members without a lifetime comment.
- Mark move constructor and move assignment `noexcept`. After a move, only assign to or destroy the object.

## Interfaces

- Parameters: cheap types by value; read-only by `const&` or view; sinks by value then `std::move`. Return a struct, `optional`, or `expected` instead of out-parameters.
- `[[nodiscard]]` on anything whose result must not be dropped: errors, handles, pure functions.
- `const` wherever it compiles; `constexpr` where it's free; `explicit` single-argument constructors; `enum class`; `override` on every override.
- `noexcept` only when you can guarantee it — a throw through it terminates.
- No C-style casts. `reinterpret_cast` only with a comment showing it isn't UB.
- No macros for constants, functions, or types.

## Errors

- One strategy per project — follow what exists: exceptions, or `expected`/error codes. Don't mix within a module.
- With exceptions: throw by value, catch by `const&`, never throw from destructors or across C/FFI/ABI boundaries. Give at least the basic guarantee.
- Without (`-fno-exceptions`): every fallible function returns a `[[nodiscard]]` result type, and callers check it.
- `assert` is for programmer errors, never for input validation.

## Undefined behaviour — check each in review

Signed overflow · out-of-bounds access · dangling pointer/reference/view · iterator invalidation · uninitialised read · data race · strict-aliasing violation (pun with `memcpy` or `std::bit_cast`) · null dereference · narrowing conversion · shift ≥ width · ODR violation · static-initialisation order · temporaries bound in range-for.

## Concurrency

- State which threads may call each public function. Document what each mutex guards.
- `std::scoped_lock` / `lock_guard`, never manual `lock()`/`unlock()`. Fixed lock order, or lock together.
- Never hold a lock while calling unknown code, doing I/O, or waiting.
- Condition variables wait with a predicate. Threads are joined (`jthread` or an RAII wrapper), never detached.
- `std::atomic` with default ordering unless a benchmark and a reviewer justify relaxing it.
- Prefer message passing and immutable shared data to shared mutable state.

## Performance defaults (cheap — always do)

- `std::vector` unless measured otherwise; `reserve` when the size is known; `emplace_back` to construct in place.
- Range-for by `const auto&`. Watch accidental copies in lambda captures and `auto x = returns_reference();`.
- Don't pass `shared_ptr` by value unless sharing ownership. No `std::function` or virtual call in an inner loop where a template works.
- `'\n'`, not `std::endl`. Keep `std::regex` and iostreams off hot paths.

## Headers & build

- Include what you use; forward-declare where a pointer or reference suffices; no `using namespace` in headers.
- Every include is paid by every includer. Keep definitions out of headers unless they must inline; PIMPL where ABI stability or build time demands it.
- Constrain templates (concepts; `static_assert`/`enable_if` before C++20) so errors point at the call site.
- CMake: targets, not globals — `target_link_libraries(... PRIVATE|PUBLIC)`, `target_include_directories`, `target_compile_features`. Presets for dev / asan / tsan / release. `CMAKE_EXPORT_COMPILE_COMMANDS=ON`.

## Tooling (enforced in CI)

- Warnings: `-Wall -Wextra -Wpedantic -Wconversion -Wsign-conversion -Wshadow -Wnon-virtual-dtor -Werror`.
- clang-tidy: `bugprone-*`, `cppcoreguidelines-*`, `clang-analyzer-*`, `modernize-*`, `performance-*`, `readability-*`, `concurrency-*`, `cert-*`. Prune noisy checks in `.clang-tidy`, not with inline `NOLINT`.
- Sanitizers: `-fsanitize=address,undefined` in one preset, `-fsanitize=thread` in another. Standard-library assertions on in debug (`-D_GLIBCXX_ASSERTIONS` or libc++ hardening).
- clang-format decides formatting. Never hand-format, never reformat lines you didn't change.

## Agent pitfalls

- Editing the `.cpp` and forgetting the header, or the reverse. Change both, then build.
- Inventing library functions. Open the header.
- Template error avalanches: fix the first error only, rebuild.
- Adding a source file without adding it to `CMakeLists.txt`.
- "Fixing" a sanitizer report by suppressing it.
- Building `all` when one target would do.

## Constrained or safety-related targets (only if the project says so)

No heap after initialisation · no exceptions or RTTI · fixed-capacity containers · bounded loops and recursion · fixed-width integers · follow the project's coding standard (e.g. MISRA C++, AUTOSAR, CERT) and never suppress its checker without a recorded deviation.
