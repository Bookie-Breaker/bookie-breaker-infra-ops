#!/usr/bin/env bash
#
# update-graphify.sh — keep the BookieBreaker knowledge graphs current.
#
# Graph layout: every repo owns a gitignored graphify-out/ built with
# `graphify extract <repo> --code-only` (pure AST — no LLM, no API key).
# The root graphify-out/graph.json is the merge of all per-repo graphs and
# is what `graphify query` and CLAUDE.md point at.
#
# Usage: update-graphify.sh <mode> [args]
#
# Modes:
#   notify <repo>  Record that <repo> changed and ensure a background runner
#                  is processing the queue. Called by the lefthook post-commit
#                  hook in every repo; returns in milliseconds.
#   run            Debounced worker: waits until commits settle
#                  (GRAPHIFY_SETTLE_SECONDS, default 60), then re-extracts
#                  each dirty repo and re-merges the root graph. Only one
#                  runner is active at a time (flock).
#   build          Full build: extract every repo in repos.txt, then merge.
#                  Honors GRAPHIFY_FORCE=1 for a from-scratch re-extract.
#   merge          Merge existing per-repo graphs into the root graph only.
#   status         Show runner/lock/queue state and recent log lines.

set -euo pipefail

SCRIPT_PATH="$(readlink -f "${BASH_SOURCE[0]}")"
SCRIPT_DIR="$(cd "$(dirname "$SCRIPT_PATH")" && pwd)"
# shellcheck source=lib/common.sh disable=SC1091
source "${SCRIPT_DIR}/lib/common.sh"

OUT_DIR="${BB_ROOT_DIR}/graphify-out"
DIRTY_DIR="${OUT_DIR}/.dirty"
LOCK_FILE="${OUT_DIR}/.update.lock"
LOG_FILE="${OUT_DIR}/update.log"
SETTLE="${GRAPHIFY_SETTLE_SECONDS:-60}"
MAX_RUNTIME="${GRAPHIFY_MAX_RUNTIME_SECONDS:-1800}"

usage() {
  cat <<'EOF'
update-graphify.sh — keep the BookieBreaker knowledge graphs current.

Usage: update-graphify.sh <mode> [args]

Modes:
  notify <repo>  Record that <repo> changed and ensure a background runner is
                 processing the queue (called by lefthook post-commit).
  run            Debounced worker: waits until commits settle
                 (GRAPHIFY_SETTLE_SECONDS, default 60), then re-extracts each
                 dirty repo and re-merges the root graph. flock-guarded.
  build          Full build: extract every repo in repos.txt, then merge.
                 Honors GRAPHIFY_FORCE=1 for a from-scratch re-extract.
  merge          Merge existing per-repo graphs into the root graph only.
  status         Show runner/lock/queue state and recent log lines.
EOF
}

# Timestamped log line — runner output is appended to update.log
rlog() {
  printf '[%s] %s\n' "$(date '+%F %T')" "$*"
}

trim_log() {
  if [[ -f "$LOG_FILE" ]] && [[ "$(stat -c %s "$LOG_FILE")" -gt 1048576 ]]; then
    tail -n 2000 "$LOG_FILE" >"${LOG_FILE}.tmp" && mv "${LOG_FILE}.tmp" "$LOG_FILE"
  fi
}

extract_repo() {
  local repo="$1"
  local repo_dir="${BB_ROOT_DIR}/${repo}"
  if [[ ! -d "$repo_dir" ]]; then
    rlog "skip ${repo}: directory not found"
    return 0
  fi
  rlog "extracting ${repo}"
  if ! graphify extract "$repo_dir" --code-only; then
    rlog "WARN extract failed for ${repo} (non-code repo or extractor error)"
  fi
}

merge_graphs() {
  local graphs=()
  local repo graph
  while IFS= read -r repo; do
    graph="${BB_ROOT_DIR}/${repo}/graphify-out/graph.json"
    if [[ -f "$graph" ]]; then
      graphs+=("$graph")
    fi
  done < <(repo_list)
  if ((${#graphs[@]} < 2)); then
    rlog "WARN fewer than two per-repo graphs exist — skipping merge (run 'build' first)"
    return 0
  fi
  rlog "merging ${#graphs[@]} graphs -> ${OUT_DIR}/graph.json"
  if ! graphify merge-graphs "${graphs[@]}" --out "${OUT_DIR}/graph.json"; then
    rlog "WARN merge-graphs failed"
    return 0
  fi
  # Keep the browsable visualization current (auto-aggregates >5000 nodes)
  if ! (cd "$BB_ROOT_DIR" && graphify export html >/dev/null 2>&1); then
    rlog "WARN graph.html export failed"
  fi
}

cmd_notify() {
  local repo="$1"
  # Never run from CI, and never queue work graphify can't do
  if [[ -n "${CI:-}${GITHUB_ACTIONS:-}" ]]; then
    return 0
  fi
  if ! command -v graphify >/dev/null 2>&1; then
    return 0
  fi
  if [[ ! -d "${BB_ROOT_DIR}/${repo}/.git" ]]; then
    return 0
  fi
  mkdir -p "$DIRTY_DIR"
  touch "${DIRTY_DIR}/${repo}"
  # Detach the runner so the commit returns immediately; the flock in
  # cmd_run collapses concurrent spawns down to a single active worker.
  # setsid must run in the foreground with --fork: an async `&` child is
  # still in the hook's process group when lefthook cleans up, and gets
  # killed before it can detach into its own session.
  setsid --fork nohup "$SCRIPT_PATH" run >>"$LOG_FILE" 2>&1 </dev/null
}

cmd_run() {
  mkdir -p "$DIRTY_DIR"
  trim_log
  exec 9>"$LOCK_FILE"
  # Wait up to 10s: adopts markers a just-exiting runner missed; a runner
  # that is actively working will see our marker in its own loop instead.
  if ! flock -w 10 9; then
    rlog "another runner holds the lock — exiting (pid $$)"
    return 0
  fi
  local deadline=$(($(date +%s) + MAX_RUNTIME))
  rlog "runner started (pid $$, settle ${SETTLE}s)"
  while true; do
    if (($(date +%s) > deadline)); then
      rlog "WARN max runtime reached — exiting; markers left for the next run"
      break
    fi
    local dirty=()
    mapfile -t dirty < <(find "$DIRTY_DIR" -mindepth 1 -maxdepth 1 -type f -printf '%f\n' 2>/dev/null | sort)
    if ((${#dirty[@]} == 0)); then
      break
    fi
    local newest now age
    newest="$(find "$DIRTY_DIR" -mindepth 1 -maxdepth 1 -type f -printf '%T@\n' 2>/dev/null \
      | sort -n | tail -1 | cut -d. -f1)"
    now="$(date +%s)"
    age=$((now - ${newest:-now}))
    if ((age < SETTLE)); then
      sleep $((SETTLE - age + 1))
      continue
    fi
    local repo
    for repo in "${dirty[@]}"; do
      # Remove the marker before extracting: a commit that lands mid-extract
      # re-dirties the repo and is picked up by the next loop iteration.
      rm -f "${DIRTY_DIR}/${repo}"
      extract_repo "$repo"
    done
    merge_graphs
  done
  rlog "runner done (pid $$)"
}

cmd_build() {
  require_cmd graphify "install with: uv tool install \"graphifyy[sql]\""
  header "graphify build"
  local repo
  while IFS= read -r repo; do
    extract_repo "$repo"
  done < <(repo_list)
  merge_graphs
  if [[ -f "${OUT_DIR}/graph.json" ]]; then
    log_ok "root graph ready: ${OUT_DIR}/graph.json"
  else
    log_warn "root graph missing — check extract output above"
  fi
}

cmd_status() {
  header "graphify updater status"
  if [[ -e "$LOCK_FILE" ]] && ! flock -n -E 99 "$LOCK_FILE" true 2>/dev/null; then
    log_warn "runner ACTIVE (lock held: ${LOCK_FILE})"
  else
    log_ok "runner idle"
  fi
  local markers
  markers="$(find "$DIRTY_DIR" -mindepth 1 -maxdepth 1 -type f -printf '%f\n' 2>/dev/null | sort || true)"
  if [[ -n "$markers" ]]; then
    log_warn "dirty repos queued:"
    awk '{print "      " $0}' <<<"$markers"
  else
    log_ok "queue empty"
  fi
  if [[ -f "${OUT_DIR}/graph.json" ]]; then
    log_ok "root graph: ${OUT_DIR}/graph.json ($(stat -c %y "${OUT_DIR}/graph.json" | cut -d. -f1))"
  else
    log_warn "root graph not built yet — run: update-graphify.sh build"
  fi
  if [[ -f "$LOG_FILE" ]]; then
    log_info "recent log (${LOG_FILE}):"
    tail -n 15 "$LOG_FILE" | sed 's/^/      /'
  fi
}

main() {
  local mode="${1:-}"
  case "$mode" in
    notify)
      [[ $# -eq 2 ]] || die "usage: update-graphify.sh notify <repo-name>"
      cmd_notify "$2"
      ;;
    run) cmd_run ;;
    build) cmd_build ;;
    merge) merge_graphs ;;
    status) cmd_status ;;
    -h | --help | help) usage ;;
    "")
      usage
      die "missing mode"
      ;;
    *)
      usage
      die "unknown mode: ${mode}"
      ;;
  esac
}

main "$@"
