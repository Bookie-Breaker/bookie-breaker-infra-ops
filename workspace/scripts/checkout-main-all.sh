#!/usr/bin/env bash
#
# checkout-main-all.sh — switch every BookieBreaker repo to main.
#
# For each repo:
#   - If there are uncommitted changes (staged, unstaged, or untracked), prints
#     a warning listing the changed files and leaves the repo untouched.
#   - Otherwise switches to main (reporting success, or "already on main").
#
# Never stashes, fetches, or pulls — purely a local branch switch.

set -euo pipefail

SCRIPT_PATH="$(readlink -f "${BASH_SOURCE[0]}")"
SCRIPT_DIR="$(cd "$(dirname "$SCRIPT_PATH")" && pwd)"
# shellcheck source=lib/common.sh disable=SC1091
source "${SCRIPT_DIR}/lib/common.sh"

BASE_PROJ_DIR="$BB_ROOT_DIR"
mapfile -t REPOS < <(repo_list)

for repo in "${REPOS[@]}"; do
  repo_dir="${BASE_PROJ_DIR}/${repo}"
  header "$repo"

  if [[ ! -d "$repo_dir" ]]; then
    printf '  %s✗ directory not found%s\n' "$RED" "$RESET"
    continue
  fi
  if ! git -C "$repo_dir" rev-parse --git-dir >/dev/null 2>&1; then
    printf '  %s✗ not a git repository%s\n' "$RED" "$RESET"
    continue
  fi

  branch="$(git -C "$repo_dir" branch --show-current)"
  [[ -n "$branch" ]] || branch="(detached @ $(git -C "$repo_dir" rev-parse --short HEAD))"

  changes="$(git -C "$repo_dir" status --porcelain)"
  if [[ -n "$changes" ]]; then
    printf '  %s✗ not switched — uncommitted changes on %s%s\n' "$RED" "$branch" "$RESET"
    awk '{print "    " $0}' <<<"$changes"
    continue
  fi

  if [[ "$branch" == "main" ]]; then
    printf '  %s✓ already on main%s\n' "$GREEN" "$RESET"
    continue
  fi

  if git -C "$repo_dir" switch --quiet main 2>/dev/null; then
    printf '  %s✓ switched:%s %s → main\n' "$GREEN" "$RESET" "$branch"
  else
    printf '  %s✗ could not switch to main%s\n' "$RED" "$RESET"
  fi
done

printf '\n'
