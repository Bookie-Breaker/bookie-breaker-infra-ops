#!/usr/bin/env bash
#
# git-status-all.sh — quick status overview of every BookieBreaker repo.
#
# Usage: ./git-status-all.sh [--no-gh] [--no-fetch]
#   --no-gh     Skip GitHub lookups (open PRs, CI health) and remote fetches —
#               faster, works offline (--no-prs is accepted as an alias)
#   --no-fetch  Skip the `git fetch` step; report sync status against whatever
#               remote-tracking refs are already local (may be stale)

set -euo pipefail

SCRIPT_PATH="$(readlink -f "${BASH_SOURCE[0]}")"
SCRIPT_DIR="$(cd "$(dirname "$SCRIPT_PATH")" && pwd)"
# shellcheck source=lib/common.sh disable=SC1091
source "${SCRIPT_DIR}/lib/common.sh"

BASE_PROJ_DIR="$BB_ROOT_DIR"
mapfile -t REPOS < <(repo_list)

SHOW_GH=true
DO_FETCH=true
for arg in "$@"; do
  case "$arg" in
    --no-gh | --no-prs)
      SHOW_GH=false
      DO_FETCH=false
      ;;
    --no-fetch) DO_FETCH=false ;;
  esac
done
if ! command -v gh >/dev/null 2>&1; then
  SHOW_GH=false
fi

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

  # Refresh remote-tracking refs so ahead/behind reflects the real remote state
  if [[ "$DO_FETCH" == true ]]; then
    if ! git -C "$repo_dir" fetch --quiet --prune 2>/dev/null; then
      printf '  %s⚠ fetch failed (offline?) — sync status may be stale%s\n' "$YELLOW" "$RESET"
    fi
  fi

  branch="$(git -C "$repo_dir" branch --show-current)"
  [[ -n "$branch" ]] || branch="(detached @ $(git -C "$repo_dir" rev-parse --short HEAD))"
  printf '  %sbranch:%s %s%s%s\n' "$DIM" "$RESET" "$BOLD" "$branch" "$RESET"

  # Sync status relative to the upstream tracking branch
  upstream=""
  ahead=0
  behind=0
  if upstream="$(git -C "$repo_dir" rev-parse --abbrev-ref --symbolic-full-name '@{upstream}' 2>/dev/null)"; then
    read -r behind ahead <<<"$(git -C "$repo_dir" rev-list --left-right --count "${upstream}...HEAD")"
    if [[ "$ahead" -gt 0 && "$behind" -gt 0 ]]; then
      printf '  %s⇅ diverged from %s — pull then push (↑%s ↓%s)%s\n' \
        "$RED" "$upstream" "$ahead" "$behind" "$RESET"
    elif [[ "$ahead" -gt 0 ]]; then
      printf '  %s↑ ahead of %s by %s — push needed%s\n' "$YELLOW" "$upstream" "$ahead" "$RESET"
    elif [[ "$behind" -gt 0 ]]; then
      printf '  %s↓ behind %s by %s — pull needed%s\n' "$YELLOW" "$upstream" "$behind" "$RESET"
    else
      printf '  %s✓ in sync with %s%s\n' "$GREEN" "$upstream" "$RESET"
    fi
  else
    printf '  %s⚠ no upstream (not tracking a remote branch)%s\n' "$YELLOW" "$RESET"
  fi

  # Working tree changes
  changes="$(git -C "$repo_dir" status --porcelain)"
  if [[ -z "$changes" ]]; then
    printf '  %s✓ clean%s\n' "$GREEN" "$RESET"
  else
    count="$(wc -l <<<"$changes")"
    printf '  %s● %s changed file(s):%s\n' "$YELLOW" "$count" "$RESET"
    awk '{print "    " $0}' <<<"$changes"
  fi

  # CI health: latest run of each workflow on the current branch
  if [[ "$SHOW_GH" == true && -n "$(git -C "$repo_dir" branch --show-current)" ]]; then
    # shellcheck disable=SC2016  # jq program placeholders, not shell expansions
    if ci="$(cd "$repo_dir" && gh api -X GET 'repos/{owner}/{repo}/actions/runs' \
      -f branch="$branch" -f per_page=20 \
      --jq '.workflow_runs | [group_by(.workflow_id)[] | .[0]] | .[] |
              if .conclusion == "success" or .conclusion == "skipped" or .conclusion == "neutral" then "OK \(.name)"
              elif .conclusion == null then "RUN \(.name)"
              else "FAIL \(.name) (\(.conclusion))" end' 2>/dev/null)"; then
      if [[ -z "$ci" ]]; then
        printf '  %sCI: no runs on this branch%s\n' "$DIM" "$RESET"
      elif grep -q '^FAIL' <<<"$ci"; then
        printf '  %s✗ CI: unhealthy%s\n' "$RED" "$RESET"
        grep '^FAIL' <<<"$ci" | sed "s/^FAIL /    ${RED}✗${RESET} /"
      elif grep -q '^RUN' <<<"$ci"; then
        printf '  %s● CI: running%s %s(%s)%s\n' "$YELLOW" "$RESET" "$DIM" \
          "$(grep '^RUN' <<<"$ci" | sed 's/^RUN //' | paste -sd, -)" "$RESET"
      else
        printf '  %s✓ CI: healthy%s\n' "$GREEN" "$RESET"
      fi
    else
      printf '  %sCI: unavailable%s\n' "$DIM" "$RESET"
    fi
  fi

  # Open PRs with their check status (best effort — skipped with --no-gh)
  if [[ "$SHOW_GH" == true ]]; then
    # shellcheck disable=SC2016  # jq program placeholders, not shell expansions
    if prs="$(cd "$repo_dir" && gh pr list --limit 10 \
      --json number,title,headRefName,statusCheckRollup \
      --jq '.[] |
          (.statusCheckRollup // []) as $checks |
          [$checks[] | ((.conclusion // .state) // "") as $c
            | select($c == "FAILURE" or $c == "ERROR" or $c == "TIMED_OUT"
                     or $c == "ACTION_REQUIRED" or $c == "STARTUP_FAILURE" or $c == "CANCELLED")
            | .name] as $failed |
          [$checks[] | select((.status // "COMPLETED") != "COMPLETED" or (.state // "") == "PENDING")] as $pending |
          "    #\(.number) \(.title) (\(.headRefName)) — " +
          (if ($checks | length) == 0 then "[NOCHK]"
           elif ($failed | length) > 0 then "[FAIL] \($failed | join(", "))"
           elif ($pending | length) > 0 then "[PEND]"
           else "[PASS]" end)' 2>/dev/null)"; then
      if [[ -n "$prs" ]]; then
        printf '  %sopen PRs:%s\n' "$DIM" "$RESET"
        sed -e "s/\[PASS\]$/${GREEN}✓ checks passing${RESET}/" \
          -e "s/\[PEND\]$/${YELLOW}● checks running${RESET}/" \
          -e "s/\[NOCHK\]$/${DIM}no checks${RESET}/" \
          -e "s/\[FAIL\] \(.*\)$/${RED}✗ failing: \1${RESET}/" <<<"$prs"
      else
        printf '  %sopen PRs: none%s\n' "$DIM" "$RESET"
      fi
    else
      printf '  %sopen PRs: unavailable%s\n' "$DIM" "$RESET"
    fi

    # Open issues
    if issues="$(cd "$repo_dir" && gh issue list --limit 10 --json number,title \
      --jq '.[] | "    #\(.number) \(.title)"' 2>/dev/null)"; then
      if [[ -n "$issues" ]]; then
        printf '  %sopen issues:%s\n%s\n' "$DIM" "$RESET" "$issues"
      else
        printf '  %sopen issues: none%s\n' "$DIM" "$RESET"
      fi
    else
      printf '  %sopen issues: unavailable%s\n' "$DIM" "$RESET"
    fi
  fi
done

printf '\n'
