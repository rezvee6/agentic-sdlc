# shellcheck shell=bash disable=SC2034
# Sourced by the other scripts. The harness-neutral core: identical on every branch.
# Anything not listed here (README.md, harness/, .kiro/, ...) is branch-specific.
CORE_PATHS=(AGENTS.md LICENSE docs/agents scripts .github/workflows)
SOURCE_BRANCH="${SOURCE_BRANCH:-main}"
