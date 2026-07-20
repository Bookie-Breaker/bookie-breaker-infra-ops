#!/usr/bin/env bash
#
# common.sh — shared helpers for BookieBreaker workspace scripts.
#
# Source this file; do not execute it. Callers resolve their own real path
# first so sourcing works through the root-level symlinks:
#
#   SCRIPT_PATH="$(readlink -f "${BASH_SOURCE[0]}")"
#   SCRIPT_DIR="$(cd "$(dirname "$SCRIPT_PATH")" && pwd)"
#   # shellcheck source=lib/common.sh
#   source "${SCRIPT_DIR}/lib/common.sh"

# Colors (disabled when stdout is not a terminal or NO_COLOR is set)
# shellcheck disable=SC2034  # consumed by sourcing scripts
if [[ -t 1 && -z "${NO_COLOR:-}" ]]; then
  BOLD="$(tput bold)" DIM="$(tput dim)" RESET="$(tput sgr0)"
  RED="$(tput setaf 1)" GREEN="$(tput setaf 2)" YELLOW="$(tput setaf 3)" CYAN="$(tput setaf 6)"
else
  BOLD="" DIM="" RESET="" RED="" GREEN="" YELLOW="" CYAN=""
fi

# Workspace geometry, derived from this file's real location:
#   <root>/bookie-breaker-infra-ops/workspace/scripts/lib/common.sh
_COMMON_LIB_DIR="$(cd "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")" && pwd)"
BB_WORKSPACE_DIR="$(cd "${_COMMON_LIB_DIR}/../.." && pwd)"
BB_ROOT_DIR="$(cd "${BB_WORKSPACE_DIR}/../.." && pwd)"
BB_REPOS_FILE="${BB_WORKSPACE_DIR}/repos.txt"

header() {
  printf '\n%s%s══ %s %s%s\n' "$BOLD" "$CYAN" "$1" \
    "$(printf '═%.0s' $(seq 1 $((60 - ${#1}))))" "$RESET"
}

log_info() { printf '  %s→%s %s\n' "$CYAN" "$RESET" "$*"; }
log_ok() { printf '  %s✓%s %s\n' "$GREEN" "$RESET" "$*"; }
log_warn() { printf '  %s●%s %s\n' "$YELLOW" "$RESET" "$*"; }
log_err() { printf '  %s✗%s %s\n' "$RED" "$RESET" "$*" >&2; }

die() {
  log_err "$*"
  exit 1
}

require_cmd() {
  command -v "$1" >/dev/null 2>&1 || die "required command not found: $1${2:+ — $2}"
}

# Repository manifest accessors (see repos.txt for the column layout)
repo_list() {
  awk 'NF && $1 !~ /^#/ {print $1}' "$BB_REPOS_FILE"
}

repo_stack() {
  awk -v r="$1" 'NF && $1 == r {print $2}' "$BB_REPOS_FILE"
}

repo_ci_check() {
  awk -v r="$1" 'NF && $1 == r {sub(/^[[:space:]]*[^[:space:]]+[[:space:]]+[^[:space:]]+[[:space:]]+/, ""); print}' \
    "$BB_REPOS_FILE"
}
