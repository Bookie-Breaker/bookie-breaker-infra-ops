#!/usr/bin/env bash
#
# dev-env-setup.sh — bootstrap the full BookieBreaker development environment.
#
# Idempotent: safe to re-run at any time. From a fresh machine:
#
#   git clone git@github.com:Bookie-Breaker/bookie-breaker-infra-ops.git
#   ./bookie-breaker-infra-ops/workspace/scripts/dev-env-setup.sh
#
# Steps: preflight checks → clone missing repos → mise toolchains →
# lefthook hooks → root symlinks → .env files → knowledge graphs.
#
# Usage: dev-env-setup.sh [--dry-run] [--skip-clone] [--skip-graphs] [--help]

set -euo pipefail

SCRIPT_PATH="$(readlink -f "${BASH_SOURCE[0]}")"
SCRIPT_DIR="$(cd "$(dirname "$SCRIPT_PATH")" && pwd)"
# shellcheck source=lib/common.sh disable=SC1091
source "${SCRIPT_DIR}/lib/common.sh"

GITHUB_ORG="Bookie-Breaker"
WORKSPACE_REL="bookie-breaker-infra-ops/workspace"

DRY_RUN=false
SKIP_CLONE=false
SKIP_GRAPHS=false

usage() {
  cat <<'EOF'
dev-env-setup.sh — bootstrap the full BookieBreaker development environment.

Usage: dev-env-setup.sh [options]

Options:
  --dry-run      Print every mutating action without executing it
  --skip-clone   Do not clone missing repositories
  --skip-graphs  Do not build the knowledge graphs
  -h, --help     Show this help
EOF
}

for arg in "$@"; do
  case "$arg" in
    --dry-run) DRY_RUN=true ;;
    --skip-clone) SKIP_CLONE=true ;;
    --skip-graphs) SKIP_GRAPHS=true ;;
    -h | --help)
      usage
      exit 0
      ;;
    *)
      usage
      die "unknown option: ${arg}"
      ;;
  esac
done

# Execute a command, or narrate it under --dry-run
run_cmd() {
  if [[ "$DRY_RUN" == true ]]; then
    printf '  %s[dry-run]%s %s\n' "$DIM" "$RESET" "$*"
  else
    "$@"
  fi
}

# --- 1. Preflight ------------------------------------------------------------
preflight() {
  header "preflight"
  local missing=false
  local cmd
  for cmd in git mise task; do
    if command -v "$cmd" >/dev/null 2>&1; then
      log_ok "$cmd"
    else
      log_err "$cmd not found (required)"
      missing=true
    fi
  done
  for cmd in docker gh graphify flock; do
    if command -v "$cmd" >/dev/null 2>&1; then
      log_ok "$cmd"
    else
      log_warn "$cmd not found (optional — some steps will be skipped or degraded)"
    fi
  done
  if [[ "$missing" == true ]]; then
    die "install the required tools above, then re-run"
  fi
  if command -v docker >/dev/null 2>&1 && ! docker compose version >/dev/null 2>&1; then
    log_warn "docker compose plugin not available — 'task up' will not work"
  fi
}

# --- 2. Clone missing repositories -------------------------------------------
clone_repos() {
  header "repositories"
  if [[ "$SKIP_CLONE" == true ]]; then
    log_info "skipped (--skip-clone)"
    return 0
  fi
  local repo
  while IFS= read -r repo; do
    if [[ -d "${BB_ROOT_DIR}/${repo}/.git" ]]; then
      log_ok "${repo} (already cloned)"
    else
      log_info "cloning ${repo}"
      run_cmd git clone "git@github.com:${GITHUB_ORG}/${repo}.git" "${BB_ROOT_DIR}/${repo}"
    fi
  done < <(repo_list)
}

# --- 3. Toolchains (mise) ----------------------------------------------------
install_toolchains() {
  header "toolchains (mise)"
  local repo repo_dir
  while IFS= read -r repo; do
    repo_dir="${BB_ROOT_DIR}/${repo}"
    if [[ ! -f "${repo_dir}/.config/mise.toml" ]]; then
      log_warn "${repo}: no .config/mise.toml — skipped"
      continue
    fi
    if [[ "$DRY_RUN" == true ]]; then
      printf '  %s[dry-run]%s mise trust + install in %s\n' "$DIM" "$RESET" "$repo"
      continue
    fi
    if (cd "$repo_dir" \
      && mise trust --quiet .config/mise.toml \
      && MISE_CONFIG_FILE=.config/mise.toml mise install --quiet); then
      log_ok "$repo"
    else
      log_err "${repo}: mise install failed"
    fi
  done < <(repo_list)
}

# --- 4. Git hooks (lefthook) -------------------------------------------------
install_hooks() {
  header "git hooks (lefthook)"
  local repo repo_dir
  while IFS= read -r repo; do
    repo_dir="${BB_ROOT_DIR}/${repo}"
    if [[ ! -f "${repo_dir}/.config/lefthook.yml" || ! -d "${repo_dir}/.git" ]]; then
      log_warn "${repo}: not a repo with lefthook config — skipped"
      continue
    fi
    if [[ "$DRY_RUN" == true ]]; then
      printf '  %s[dry-run]%s lefthook install in %s\n' "$DIM" "$RESET" "$repo"
      continue
    fi
    if (cd "$repo_dir" && LEFTHOOK_CONFIG=.config/lefthook.yml run_lefthook install >/dev/null); then
      log_ok "$repo"
    else
      log_err "${repo}: lefthook install failed"
    fi
  done < <(repo_list)
}

# Prefer a lefthook on PATH; fall back to the repo's mise-pinned one
run_lefthook() {
  if command -v lefthook >/dev/null 2>&1; then
    lefthook "$@"
  else
    MISE_CONFIG_FILE=.config/mise.toml mise x -- lefthook "$@"
  fi
}

# --- 5. Root symlinks ---------------------------------------------------------
link_root_file() {
  local name="$1" target="$2"
  local link="${BB_ROOT_DIR}/${name}"
  if [[ -e "$link" && ! -L "$link" ]]; then
    log_warn "${name}: a real file exists at the root — not replacing it (move it aside and re-run)"
    return 0
  fi
  run_cmd ln -sfn "$target" "$link"
  if [[ "$DRY_RUN" != true ]]; then
    log_ok "${name} -> ${target}"
  fi
}

create_symlinks() {
  header "root symlinks"
  link_root_file CLAUDE.md "${WORKSPACE_REL}/CLAUDE.md"
  link_root_file Taskfile.yml "${WORKSPACE_REL}/Taskfile.yml"
  link_root_file repos.txt "${WORKSPACE_REL}/repos.txt"
  link_root_file .graphifyignore "${WORKSPACE_REL}/.graphifyignore"
  link_root_file bookie-breaker.code-workspace "${WORKSPACE_REL}/bookie-breaker.code-workspace"
  local script
  for script in dev-env-setup.sh update-graphify.sh clone-all.sh checkout-main-all.sh \
    git-status-all.sh refresh-all-repos.sh; do
    link_root_file "$script" "${WORKSPACE_REL}/scripts/${script}"
  done
}

# --- 6. Environment files -----------------------------------------------------
copy_env_files() {
  header "environment files"
  local repo repo_dir
  while IFS= read -r repo; do
    repo_dir="${BB_ROOT_DIR}/${repo}"
    if [[ ! -f "${repo_dir}/.env.example" ]]; then
      continue
    fi
    if [[ -f "${repo_dir}/.env" ]]; then
      log_ok "${repo}: .env exists (left untouched)"
    else
      run_cmd cp "${repo_dir}/.env.example" "${repo_dir}/.env"
      log_ok "${repo}: .env created from .env.example"
    fi
  done < <(repo_list)
}

# --- 7. Knowledge graphs ------------------------------------------------------
build_graphs() {
  header "knowledge graphs"
  if [[ "$SKIP_GRAPHS" == true ]]; then
    log_info "skipped (--skip-graphs)"
    return 0
  fi
  if ! command -v graphify >/dev/null 2>&1; then
    log_warn "graphify not installed — skipped (install with: uv tool install \"graphifyy[sql]\")"
    return 0
  fi
  run_cmd "${SCRIPT_DIR}/update-graphify.sh" build
}

# --- main ---------------------------------------------------------------------
main() {
  header "BookieBreaker dev environment setup"
  log_info "workspace root: ${BB_ROOT_DIR}"
  if [[ "$DRY_RUN" == true ]]; then
    log_warn "dry-run mode: no changes will be made"
  fi

  preflight
  clone_repos
  install_toolchains
  install_hooks
  create_symlinks
  copy_env_files
  build_graphs

  header "done"
  log_ok "environment ready"
  log_info "shell profile reminders (add once):"
  # shellcheck disable=SC2016  # printed literally for the user to paste
  printf '      eval "$(mise activate zsh)"\n'
  printf '      export MISE_CONFIG_FILE=".config/mise.toml"\n'
  printf '      export LEFTHOOK_CONFIG=".config/lefthook.yml"\n'
  log_info "start the stack with: task up"
}

main "$@"
