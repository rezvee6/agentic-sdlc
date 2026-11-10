# Embedded & cross-compiled targets

Load when: cross-compiling, bare-metal or `no_std` code, MCU/RTOS work, on-target tests, or a safety-related target.

## Find out first — from the project block and build files, never by guessing

- Target triple, toolchain file or SDK, sysroot, C library (glibc, musl, newlib, none).
- Hosted (embedded Linux) or freestanding (bare-metal, RTOS)?
- Flash and RAM budgets; stack size per thread or task; is heap allowed, and after initialisation?
- Exceptions, RTTI, FPU, endianness, alignment rules.
- Coding standard and the checker that enforces it.

## Structure for testability

- Three layers: **portable logic** (no hardware, no OS) · **hardware abstraction** (interfaces/traits) · **thin target layer** (registers, drivers, startup).
- Portable logic builds and unit-tests on the host, with sanitizers. Most tests live here.
- Keep the target layer thin enough to review by eye.

## Cross-compilation

| | C++ (CMake) | Rust |
|---|---|---|
| Select toolchain | Preset with `CMAKE_TOOLCHAIN_FILE`; never hard-code compiler paths in `CMakeLists.txt` | `rustup target add <triple>`; `--target <triple>` or `[build] target` in `.cargo/config.toml` |
| Sysroot / linker | `CMAKE_SYSROOT`; `CMAKE_FIND_ROOT_PATH_MODE_*` so host libraries are never found | Per-target `linker` in `.cargo/config.toml`; `cross` for containerised toolchains |
| Bare-metal | `CMAKE_SYSTEM_NAME Generic`; `CMAKE_TRY_COMPILE_TARGET_TYPE STATIC_LIBRARY` | `#![no_std]`, `#![no_main]`, a runtime crate (e.g. `cortex-m-rt`), linker script |
| Run tests under emulation | `CMAKE_CROSSCOMPILING_EMULATOR` (QEMU) so `ctest` works | Per-target `runner` in `.cargo/config.toml` (QEMU, `probe-rs run`) |

- Host tools (code generators) build for the host, not the target.
- Never assume `sizeof(long)`, `char` signedness, endianness, or alignment. Fixed-width types; explicit byte-order conversion; serialise field by field, never by copying a struct's bytes.
- CI builds host and target. A green host build proves nothing about the target.

## Freestanding C++

- No heap after initialisation. `-fno-exceptions -fno-rtti` if the project says so; then every fallible function returns a checked result.
- Fixed-capacity containers (ETL or the project's own). No iostreams, `std::function`, or `std::string` on constrained targets.
- No non-trivial global constructors — initialisation order is undefined across files. Prefer `constexpr` / `constinit` data.
- Size: `-ffunction-sections -fdata-sections` with `-Wl,--gc-sections`; read the linker map before and after.
- Stack: `-fstack-usage`, `-Wstack-usage=<bytes>`; no recursion, no large locals, no VLAs.
- Bounded loops; fixed-width integers.

## `no_std` Rust

- `core` first; `alloc` only if the project has an allocator and a policy for it.
- Library crates: put `std` behind an optional feature so the crate builds for host and target.
- Fixed-capacity collections (`heapless`). No `String` / `format!` without `alloc`.
- Choose the panic handler deliberately (`panic-halt`, `panic-probe`, or the project's own); `panic = "abort"`.
- Keep panicking paths out of firmware: `get` instead of indexing, checked or wrapping arithmetic, no `unwrap`.
- Drivers take `embedded-hal` traits so they test on the host against fakes.
- State shared with interrupts: `critical-section`, or the framework's primitives (RTIC, Embassy). Never `static mut`.
- Size: `opt-level = "s"` or `"z"`, `lto = "fat"`, `codegen-units = 1`; check with `cargo size` / `cargo bloat`. `flip-link` for stack-overflow protection.
- Every dependency must be `no_std`: verify with `cargo check --target <triple>`, not the host build.

## Interrupts, hardware, timing

- ISRs: short, bounded, no allocation, no blocking, no log formatting. Hand off through a lock-free queue or flag.
- Data shared with an ISR is atomic or guarded by a critical section — say which, in a comment.
- Registers through volatile access only (`volatile` in C++; `read_volatile` / `write_volatile` or a PAC crate in Rust). Never a plain reference to a register struct.
- Every wait on hardware has a timeout.
- Time-critical path: no allocation, no locks, bounded loops — and state the worst case.
- Service the watchdog from the main loop, not from a timer interrupt.

## Testing ladder

1. **Host unit tests** of portable logic, with sanitizers / Miri — every commit.
2. **Target build, link, size and stack check** — every commit. Catches `no_std`, ABI and size breaks.
3. **Emulator** (QEMU, Renode) integration tests — CI.
4. **On target / hardware-in-the-loop** (`probe-rs` with `defmt-test` or `embedded-test`, or the project's rig) — before release, and for anything touching drivers or timing.

An agent without hardware runs 1–3, says plainly that 4 was not run, and lists what must be run on target in `handoff.md`. Never claim on-target behaviour from a host test.

## Safety-related targets

- Follow the project's coding standard (e.g. MISRA C++, AUTOSAR C++14, CERT). Never suppress its checker without a recorded deviation.
- Keep traceability: requirement ID ↔ AC ID ↔ code ↔ test.
- Agents don't sign off safety arguments or deviations. A human does.
