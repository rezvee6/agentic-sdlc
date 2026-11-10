#!/usr/bin/env bash
# Copies the core paths from the source branch (main) onto a harness branch and
# opens or updates a pull request with the result. Harness files are untouched.
# Usage: scripts/sync-core.sh <harness-branch>
# Needs: GH_TOKEN with contents + pull-requests write.
#        SYNC_WORKFLOWS=1 only if that token may also push workflow files.
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"
source scripts/core-paths.sh

target="${1:?usage: sync-core.sh <harness-branch>}"
head="sync/${SOURCE_BRANCH}-to-${target}"

paths=()
for p in "${CORE_PATHS[@]}"; do
  # GITHUB_TOKEN may not push workflow changes, so those are flagged instead.
  [ "$p" = .github/workflows ] && [ "${SYNC_WORKFLOWS:-0}" != 1 ] && continue
  paths+=("$p")
done

git fetch -q origin "$SOURCE_BRANCH" "$target"
src_sha=$(git rev-parse --short "origin/$SOURCE_BRANCH")

git switch -q -C "$head" "origin/$target"
# Remove the core first so files deleted on the source branch go too.
git rm -rq --ignore-unmatch -- "${paths[@]}"
git checkout "origin/$SOURCE_BRANCH" -- "${paths[@]}"

workflow_note=""
if [ "${SYNC_WORKFLOWS:-0}" != 1 ] && ! git diff --quiet "origin/$SOURCE_BRANCH" HEAD -- .github/workflows; then
  workflow_note=$'\n\n**Workflow files also differ** and were not synced (the default token cannot push them). Copy `.github/workflows/` from `'"$SOURCE_BRANCH"$'` into `'"$target"$'` by hand, or add a `SYNC_TOKEN` secret.'
  echo "::warning::.github/workflows differs between $SOURCE_BRANCH and $target and was not synced"
fi

if git diff --cached --quiet; then
  echo "$target: core already in sync with $SOURCE_BRANCH@$src_sha"
  [ -z "$workflow_note" ] || exit 1
  exit 0
fi

git -c user.name="github-actions[bot]" \
    -c user.email="41898282+github-actions[bot]@users.noreply.github.com" \
    commit -q -m "chore(sync): core from $SOURCE_BRANCH@$src_sha"
# The sync branch belongs to this workflow, so overwriting it is safe.
git push -q --force origin "$head"

title="chore(sync): core from $SOURCE_BRANCH@$src_sha into $target"
body="Copies the core paths (\`${CORE_PATHS[*]}\`) from \`$SOURCE_BRANCH\` @ \`$src_sha\` onto \`$target\`. Harness-specific files are untouched.

$(git diff --stat "origin/$target" HEAD)${workflow_note}

Opened by \`.github/workflows/sync-core.yml\`."

if [ "$(gh pr view "$head" --json state -q .state 2>/dev/null || true)" = OPEN ]; then
  gh pr edit "$head" --title "$title" --body "$body" >/dev/null
  echo "$target: updated sync pull request"
else
  gh pr create --base "$target" --head "$head" --title "$title" --body "$body"
fi
