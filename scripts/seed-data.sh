#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
FIXTURES_DIR="$SCRIPT_DIR/../fixtures"

DB_HOST="${DB_HOST:-localhost}"
DB_PORT="${DB_PORT:-5432}"
DB_NAME="${DB_NAME:-bookiebreaker}"
DB_USER="${DB_USER:-bookiebreaker}"
DB_PASSWORD="${POSTGRES_PASSWORD:-localdev}"

export PGPASSWORD="$DB_PASSWORD"

echo "Seeding sportsbooks..."
psql -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d "$DB_NAME" -f "$FIXTURES_DIR/sportsbooks.sql"

echo "Seeding sample line snapshots..."
psql -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d "$DB_NAME" -f "$FIXTURES_DIR/sample-lines.sql"

echo ""
echo "Verifying seed data:"
echo -n "  Sportsbooks: "
psql -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d "$DB_NAME" -t -c "SELECT COUNT(*) FROM lines.sportsbooks;"
echo -n "  Line snapshots: "
psql -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d "$DB_NAME" -t -c "SELECT COUNT(*) FROM lines.line_snapshots;"

echo ""
echo "Seed data loaded successfully."
