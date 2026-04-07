# bookie-breaker-infra-ops

## Purpose

Shared infrastructure: Docker Compose for local development, CI/CD reusable GitHub Actions workflows, database init scripts, seed data, and operational scripts.

## Conventions

- **Languages:** YAML, Shell, SQL, Dockerfile
- **Naming:** `kebab-case` for files, service names match repo names minus `bookie-breaker-` prefix

## Key Files

- `docker-compose.yml` — Full local stack (Postgres, Redis, all services)
- `init-db/` — Database schema creation scripts
- `scripts/` — Operational scripts (seed-data.sh, etc.)
- `fixtures/` — SQL/Python seed data files
- `.github/workflows/go-ci.yml` — Reusable Go CI workflow
- `.github/workflows/python-ci.yml` — Reusable Python CI workflow
- `.github/workflows/sveltekit-ci.yml` — Reusable SvelteKit CI workflow
- `.github/workflows/docker-build.yml` — Reusable Docker build + push workflow
- `renovate-config.json` — Shared Renovate preset for all repos

## Commands

```bash
task bootstrap    # Install tools and hooks
```

From root `BookieBreaker/`:

```bash
task up           # Start full stack
task down         # Stop all services
task build        # Rebuild containers
task logs         # Tail all logs
task db:migrate   # Run all migrations
task db:seed      # Seed development data
task db:reset     # Drop, recreate, migrate, seed
```

## Environment Variables

See `.env.example`. Key: `POSTGRES_PASSWORD`, `ODDS_API_KEY`, `ANTHROPIC_API_KEY`.
