# bookie-breaker-infra-ops

[![CI](https://img.shields.io/github/actions/workflow/status/Bookie-Breaker/bookie-breaker-infra-ops/ci.yml?branch=main&label=CI&logo=githubactions&logoColor=white)](https://github.com/Bookie-Breaker/bookie-breaker-infra-ops/actions/workflows/ci.yml)
![Docker](https://img.shields.io/badge/Docker-Compose-2496ED?logo=docker&logoColor=white)
![GitHub_Actions](https://img.shields.io/badge/GitHub_Actions-reusable_workflows-2088FF?logo=githubactions&logoColor=white)
![PostgreSQL](https://img.shields.io/badge/PostgreSQL-16-4169E1?logo=postgresql&logoColor=white)
![Redis](https://img.shields.io/badge/Redis-7-DC382D?logo=redis&logoColor=white)

Shared infrastructure: Docker Compose, CI/CD reusable workflows, database init scripts, and operational tooling.

For installing, operating, and season-flipping the stack, see the operator playbooks
[01-installation](https://github.com/Bookie-Breaker/bookie-breaker-docs/blob/main/playbooks/01-installation.md),
[02-daily-operations](https://github.com/Bookie-Breaker/bookie-breaker-docs/blob/main/playbooks/02-daily-operations.md),
and [06-seasonal-operations](https://github.com/Bookie-Breaker/bookie-breaker-docs/blob/main/playbooks/06-seasonal-operations.md).

## Quickstart

```bash
cp .env.example .env  # fill in API keys
task bootstrap
```

## Docker Compose

From the `BookieBreaker/` root:

```bash
task up      # Start all services
task down    # Stop all services
task build   # Rebuild containers
task logs    # Tail logs
```

Fresh-stack startup order (migrations run from the host, not a compose
one-shot; lines-service tolerates an empty schema until they land):

```bash
task up && task db:migrate && task db:seed
```

The app services (`lines-service` on 8001, `statistics-service` on 8002)
build from their sibling repos, so clone all repos side by side
(`clone-all.sh`). Without an `ODDS_API_KEY`, lines-service disables its
ingestion scheduler but still serves the read API from seeded data.

## Architecture Decisions

- [Tech Stack Selection (ADR-010)](https://github.com/Bookie-Breaker/bookie-breaker-docs/blob/main/decisions/010-tech-stack-selection.md)

## Environment Variables

See `.env.example` for all variables with descriptions.
