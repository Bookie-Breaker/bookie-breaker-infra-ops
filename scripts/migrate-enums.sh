#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

DB_HOST="${DB_HOST:-localhost}"
DB_PORT="${DB_PORT:-5432}"
DB_NAME="${DB_NAME:-bookiebreaker}"
DB_USER="${DB_USER:-bookiebreaker}"
DB_PASSWORD="${POSTGRES_PASSWORD:-localdev}"

export PGPASSWORD="$DB_PASSWORD"

echo "Extending shared enum types (idempotent)..."
psql -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d "$DB_NAME" \
  -v ON_ERROR_STOP=1 -f "$SCRIPT_DIR/migrate-enums.sql"

echo "Shared enums up to date."
