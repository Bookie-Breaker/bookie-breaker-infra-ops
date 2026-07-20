#!/usr/bin/env bash
#
# refresh-all-repos.sh — sync every BookieBreaker repo with its remote.
#
# For each repo:
#   1. Stashes any uncommitted changes (including untracked files)
#   2. Switches to the default branch if not already on it
#   3. Pulls with --ff-only and prunes deleted remote branches
#   4. Offers to delete local branches whose remote branch is gone
#   5. Switches back to the original branch and restores stashed changes
#
# Safe by design: fast-forward-only pulls, confirmation before any branch
# deletion, and stashes are kept if restoring them hits a conflict.

set -euo pipefail

SCRIPT_PATH="$(readlink -f "${BASH_SOURCE[0]}")"
SCRIPT_DIR="$(cd "$(dirname "$SCRIPT_PATH")" && pwd)"
# shellcheck source=lib/common.sh disable=SC1091
source "${SCRIPT_DIR}/lib/common.sh"

BASE_PROJ_DIR="$BB_ROOT_DIR"
mapfile -t REPOS < <(repo_list)

PROBLEMS=()

problem() {
  PROBLEMS+=("$1: $2")
  printf '  %s✗ %s%s\n' "$RED" "$2" "$RESET"
}

for repo in "${REPOS[@]}"; do
  repo_dir="${BASE_PROJ_DIR}/${repo}"
  header "$repo"

  if [[ ! -d "$repo_dir" ]]; then
    problem "$repo" "directory not found"
    continue
  fi
  if ! git -C "$repo_dir" rev-parse --git-dir >/dev/null 2>&1; then
    problem "$repo" "not a git repository"
    continue
  fi

  orig_branch="$(git -C "$repo_dir" branch --show-current)"
  if [[ -z "$orig_branch" ]]; then
    problem "$repo" "detached HEAD — skipping (check out a branch first)"
    continue
  fi

  default_branch="$(git -C "$repo_dir" symbolic-ref --short refs/remotes/origin/HEAD 2>/dev/null | sed 's|^origin/||' || true)"
  default_branch="${default_branch:-main}"

  # 1 & 2: stash uncommitted changes (including untracked files)
  stashed=false
  if [[ -n "$(git -C "$repo_dir" status --porcelain)" ]]; then
    git -C "$repo_dir" stash push --include-untracked --quiet -m "refresh-all-repos auto-stash"
    stashed=true
    printf '  %s● stashed uncommitted changes%s\n' "$YELLOW" "$RESET"
  fi

  # 3: switch to the default branch if we're not on it
  switched=false
  if [[ "$orig_branch" != "$default_branch" ]]; then
    if git -C "$repo_dir" switch --quiet "$default_branch" 2>/dev/null; then
      switched=true
      printf '  %sswitched:%s %s → %s\n' "$DIM" "$RESET" "$orig_branch" "$default_branch"
    else
      problem "$repo" "could not switch to ${default_branch}"
      if [[ "$stashed" == true ]]; then
        git -C "$repo_dir" stash pop --quiet || problem "$repo" "failed to restore stash — run 'git stash pop' manually"
      fi
      continue
    fi
  fi

  # 4: pull (fast-forward only) and prune deleted remote branches
  if git -C "$repo_dir" pull --ff-only --prune --quiet 2>/dev/null; then
    printf '  %s✓ %s pulled & pruned%s\n' "$GREEN" "$default_branch" "$RESET"
  else
    problem "$repo" "pull failed on ${default_branch} (diverged from remote, or no network?)"
  fi

  # 5: offer to delete local branches whose remote branch is gone
  gone_branches="$(git -C "$repo_dir" for-each-ref --format='%(refname:short) %(upstream:track)' refs/heads \
    | awk '$2 == "[gone]" {print $1}')"
  for br in $gone_branches; do
    [[ "$br" == "$default_branch" ]] && continue
    if [[ "$br" == "$orig_branch" ]]; then
      printf '  %s● remote for current branch %s is gone — not touching it%s\n' "$YELLOW" "$br" "$RESET"
      continue
    fi
    if [[ -t 0 ]]; then
      read -r -p "  delete stale local branch '${br}' (remote is gone)? [y/N] " answer
      if [[ "$answer" =~ ^[Yy]$ ]]; then
        git -C "$repo_dir" branch -D "$br" >/dev/null
        printf '  %s✓ deleted %s%s\n' "$GREEN" "$br" "$RESET"
      else
        printf '  %skept %s%s\n' "$DIM" "$br" "$RESET"
      fi
    else
      printf '  %s● stale branch (remote gone), rerun interactively to delete: %s%s\n' "$YELLOW" "$br" "$RESET"
    fi
  done

  # 6: switch back to the original branch
  if [[ "$switched" == true ]]; then
    git -C "$repo_dir" switch --quiet "$orig_branch"
    printf '  %sback on:%s %s%s%s\n' "$DIM" "$RESET" "$BOLD" "$orig_branch" "$RESET"
  fi

  # 7 & 8: restore stashed changes and alert on conflicts
  if [[ "$stashed" == true ]]; then
    if git -C "$repo_dir" stash pop --quiet 2>/dev/null; then
      printf '  %s✓ restored stashed changes%s\n' "$GREEN" "$RESET"
    elif [[ -n "$(git -C "$repo_dir" ls-files --unmerged)" ]]; then
      problem "$repo" "CONFLICTS restoring stashed changes — resolve manually (stash was kept)"
    else
      problem "$repo" "failed to restore stash — run 'git stash pop' manually"
    fi
  fi
done

printf '\n'
if [[ ${#PROBLEMS[@]} -eq 0 ]]; then
  printf '%s✓ all repos refreshed cleanly%s\n' "${BOLD}${GREEN}" "$RESET"
else
  printf '%s✗ %d problem(s) need attention:%s\n' "${BOLD}${RED}" "${#PROBLEMS[@]}" "$RESET"
  for p in "${PROBLEMS[@]}"; do
    printf '  %s✗%s %s\n' "$RED" "$RESET" "$p"
  done
  exit 1
fi
