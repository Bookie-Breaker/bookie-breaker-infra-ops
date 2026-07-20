#!/usr/bin/env bash
#
# clone-all.sh — clone any missing BookieBreaker repos into the workspace root.
#
# Clone-only: for the full environment bootstrap (toolchains, hooks, symlinks,
# .env files, knowledge graphs) run dev-env-setup.sh instead.

set -euo pipefail

SCRIPT_PATH="$(readlink -f "${BASH_SOURCE[0]}")"
SCRIPT_DIR="$(cd "$(dirname "$SCRIPT_PATH")" && pwd)"
# shellcheck source=lib/common.sh disable=SC1091
source "${SCRIPT_DIR}/lib/common.sh"

GITHUB_ORG="Bookie-Breaker"

header "cloning BookieBreaker repos into ${BB_ROOT_DIR}"

while IFS= read -r repo; do
  if [[ -d "${BB_ROOT_DIR}/${repo}/.git" ]]; then
    log_ok "${repo} (already cloned)"
  else
    log_info "cloning ${repo}"
    git clone "git@github.com:${GITHUB_ORG}/${repo}.git" "${BB_ROOT_DIR}/${repo}"
  fi
done < <(repo_list)

printf '\n'
log_info "next: run dev-env-setup.sh for toolchains, hooks, symlinks, and graphs"
