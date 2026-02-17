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
