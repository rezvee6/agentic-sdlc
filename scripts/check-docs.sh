#!/usr/bin/env bash
# Checks the agent docs stay within budget and internally consistent.
# shellcheck disable=SC2016  # backticks in patterns are literal
# Usage: scripts/check-docs.sh   (from anywhere in the repo)
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"

fail=0
err() { echo "::error file=$1::$2"; fail=1; }

# 1. Line budgets: AGENTS.md is always loaded; the rest load on demand.
n=$(wc -l < AGENTS.md)
[ "$n" -le 100 ] || err AGENTS.md "$n lines; budget is 100"
for f in docs/agents/*.md; do
  n=$(wc -l < "$f")
  [ "$n" -le 120 ] || err "$f" "$n lines; budget is 120"
done

# 2. The router and the docs agree: every doc is routed, every route exists.
for f in docs/agents/*.md; do
  grep -qF "\`$(basename "$f")\`" AGENTS.md || err "$f" "not referenced from the AGENTS.md routing table"
done
{ grep -oE '`[0-9a-z-]+\.md`' AGENTS.md || true; } | tr -d '`' | sort -u | while read -r p; do
  case "$p" in spec.md|design.md|plan.md|handoff.md|review.md|followups.md) continue ;; esac
  [ -e "docs/agents/$p" ] || { echo "::error file=AGENTS.md::routes to missing docs/agents/$p"; exit 1; }
done || fail=1

# 3. Backticked .md references inside the docs resolve.
#    Bare artifact names (spec.md, plan.md, ...) are per-task files under docs/work/<id>/.
for f in AGENTS.md docs/agents/*.md docs/agents/templates/*.md; do
  { grep -oE '`[A-Za-z0-9_/.-]+\.md`' "$f" || true; } | tr -d '`' | sort -u | while read -r p; do
    case "$p" in spec.md|design.md|plan.md|handoff.md|review.md|followups.md|AGENTS.md|README.md|CHANGELOG.md) continue ;; esac
    [ -e "$p" ] || [ -e "docs/agents/$p" ] || { echo "::error file=$f::broken reference: $p"; exit 1; }
  done || fail=1
done

# 4. Markdown tables keep a constant column count (a broken row renders as text).
for f in AGENTS.md README.md docs/agents/*.md docs/agents/templates/*.md; do
  awk -v f="$f" '
    /^\|/ { n = gsub(/\|/, "|"); if (prev && n != prev) { printf "::error file=%s,line=%d::table row has %d pipes, expected %d\n", f, NR, n, prev; bad = 1 } prev = n; next }
    { prev = 0 }
    END { exit bad }' "$f" || fail=1
done

[ "$fail" -eq 0 ] && echo "docs: ok"
exit "$fail"
