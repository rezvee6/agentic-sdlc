#!/usr/bin/env bash
# Fails if the core paths on this checkout differ from the source branch (main).
# Usage: scripts/check-core-parity.sh
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"
source scripts/core-paths.sh

git fetch -q --depth=1 origin "$SOURCE_BRANCH"
if git diff --quiet FETCH_HEAD HEAD -- "${CORE_PATHS[@]}"; then
  echo "core: in sync with $SOURCE_BRANCH"
  exit 0
fi

echo "::error::Core files differ from $SOURCE_BRANCH. Make core changes on $SOURCE_BRANCH; the sync workflow opens a pull request that brings them here."
git diff --stat FETCH_HEAD HEAD -- "${CORE_PATHS[@]}"
exit 1
