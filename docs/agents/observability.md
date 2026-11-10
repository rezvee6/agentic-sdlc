# Logging & observability

Load when: adding or changing logging, metrics, tracing, or diagnostics.

## Principles

- Use the project's logging and metrics facade. No `printf`, `std::cout`, `println!`, or `eprintln!` in library code. A new facade is a new dependency — ask first.
- Libraries emit; the application configures sinks, levels and format. A library never initialises a global logger.
- Write for someone debugging without the source: what happened, to which entity, with what values, what happens next.

## Levels

| Level | Use for | Production |
|---|---|---|
| error | an operation failed and will not be retried; someone must look | on |
| warn | unexpected but handled: retry, fallback, degraded mode | on |
| info | lifecycle and state changes: start, stop, config loaded, link up/down | on, low volume |
| debug | decisions and values useful for diagnosis | off by default |
| trace | per-item or per-iteration detail | off; compiled out of release where possible |

- Log an error once, where it is handled. Layers it passes through add context to the error, not another log line.
- Expected conditions (bad user input, end of file, cancellation) are not errors.
- Never log and carry on past a violated invariant. Fail.

## Structure

- A stable event name plus key-value fields, not an interpolated sentence: `event=frame_dropped reason=crc seq=1042`.
- Consistent field names and units across the codebase (`_ms`, `_bytes`).
- Carry a correlation ID (request, session, job) on every record of one operation.
- Monotonic clock for durations; UTC for wall-clock time; the sink adds the timestamp.

## Never log

- Secrets, tokens, keys, passwords, personal data.
- Whole payloads from untrusted input — log the size and a short prefix or hash.
- Unbounded or unescaped external strings. Truncate and escape them (log injection).

## Cost

- Nothing above debug on a hot path. The level check happens before arguments are built — logging macros do this, hand-built strings don't.
- No allocation, formatting, or I/O while holding a lock. Use a buffered or asynchronous sink for volume.
- Rate-limit or sample repeating messages, and count them in a metric instead.
- Interrupt or real-time context: no logging. Set a counter or flag and log from a non-critical context.

## Metrics

- Counter for events, gauge for a current value, histogram for latency and size. Never average a latency.
- Follow the existing naming scheme; otherwise `<component>_<what>_<unit>`.
- Labels are low-cardinality: never IDs, paths, or user input.
- Each external call and queue gets: count, error count, latency histogram, depth.
- Every numeric budget in the spec has a metric that shows whether it is being met.

## Tracing

- One span per unit of work; carry context across threads, tasks, and process boundaries.
- Use it where the project already has it. Don't introduce a tracing stack inside a feature task.

## Language notes

- C++: `fmt`-style format strings checked at compile time (`spdlog` or the project's wrapper); level macros that compile out.
- Rust: `tracing` (spans and fields) or the `log` facade in libraries; `#[instrument]` sparingly, skipping large arguments; the `metrics` facade.
- `no_std`: `defmt`, with formatting deferred to the host.

## Testing

- Don't assert on log text. Assert on the metric or event when it is the behaviour ("a dropped frame is counted").
- Each new failure path is exercised by a test at least once, so its logging code runs.
