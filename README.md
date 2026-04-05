# bookie-breaker-infra-ops

Shared infrastructure: Docker Compose, CI/CD reusable workflows, database init scripts, and operational tooling.

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

## Architecture Decisions

- [Tech Stack Selection (ADR-010)](https://github.com/Bookie-Breaker/bookie-breaker-docs/blob/main/decisions/010-tech-stack-selection.md)

## Environment Variables

See `.env.example` for all variables with descriptions.
