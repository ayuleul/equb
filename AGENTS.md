# AGENTS.md — Equb (NestJS) Agent Rules

## Prime directive
- Any new “general rule” discovered while implementing (conventions, constraints, patterns, decisions) MUST be added to this AGENTS.md in the appropriate section before finishing the change.

## Setup commands
- Install: `pnpm install` (or `npm install` if repo uses npm)
- Dev: `pnpm -C apps/api start:dev`
- Test: `pnpm -C apps/api test`
- Lint: `pnpm -C apps/api lint`
- Typecheck: `pnpm -C apps/api typecheck`
- DB: `pnpm -C apps/api prisma migrate dev`

## Tech decisions (locked)
- NestJS + TypeScript
- PostgreSQL + Prisma
- JWT access + refresh tokens (refresh stored hashed)
- OTP-based login (phone)
- BullMQ + Redis for async jobs (notifications, reminders)
- S3-compatible storage for proof uploads (signed URLs)
- Validation: use `class-validator` + `class-transformer`
- API docs: Swagger enabled in dev

## Coding standards
- Prefer small diffs and incremental commits.
- No business logic in controllers: use services + use-cases.
- Always create/extend DTOs, never accept `any`.
- Every write endpoint must:
  - validate input
  - enforce auth + role checks
  - write an audit log entry
- Prefer database constraints over app-only checks (unique indexes, FK, etc).

## Security rules
- Never store OTP codes in plaintext; store hashed + TTL.
- Refresh tokens stored hashed; rotate on refresh; allow revoke on logout.
- Signed upload URLs must be scoped to authenticated user and group membership.
- Use rate limiting on OTP endpoints.

## Testing rules
- Add unit tests for services that implement business rules.
- Add e2e tests for auth and 1 critical group/cycle flow.
- Migrations must be deterministic and checked in.

## Folder conventions
- `apps/api` is the canonical backend implementation path. If a legacy `server/` scaffold exists, treat it as deprecated bootstrap code and do not add new phase work there.
- `apps/api/src/modules/<module>/`
  - `<module>.module.ts`
  - `<module>.controller.ts`
  - `<module>.service.ts`
  - `dto/`
  - `entities/` (optional)
- Shared guards/decorators in `apps/api/src/common/`

## Phase delivery rule
- Implement phases strictly in order (1 → 6).
- Each phase must end with:
  - migrations (if any)
  - minimal tests
  - updated Swagger endpoints
  - updated AGENTS.md if new general rules were learned

## Docker rule (locked)
- Local development MUST run dependencies via Docker Compose:
  - PostgreSQL
  - Redis (BullMQ)
  - MinIO (S3-compatible) for proof uploads in dev
- No developer should install Postgres/Redis locally for this repo.
- All connection strings must come from env vars and default to Compose service names (postgres, redis, minio).

## Dev environment
- Start dependencies: `docker compose up -d`
- Stop dependencies: `docker compose down`
- Reset DB (dev only): `docker compose down -v` (wipes volumes)
- If API runs on host (not in Docker), use `localhost` for DATABASE_URL/REDIS_URL/S3 endpoint hosts; Docker service names (`postgres`, `redis`, `minio`) are for container-to-container networking.

## Required files
- `docker-compose.yml` at repo root (or `/infra/docker/docker-compose.yml` but must be documented here)
- `.env.example` for API (apps/api/.env.example) includes:
  - DATABASE_URL
  - REDIS_URL
  - JWT_ACCESS_SECRET
  - JWT_REFRESH_SECRET
  - OTP_TTL_SECONDS
  - S3_ENDPOINT
  - S3_BUCKET
  - S3_ACCESS_KEY
  - S3_SECRET_KEY
  - S3_REGION
  - S3_FORCE_PATH_STYLE
