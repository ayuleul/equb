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
- Mobile install: `flutter pub get` (in `apps/mobile`)
- Mobile run: `flutter run` (in `apps/mobile`, loads `apps/mobile/.env`)
- Mobile test: `flutter test` (in `apps/mobile`)
- Mobile analyze: `flutter analyze` (in `apps/mobile`)

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
- Every controller endpoint must include Swagger decorators at minimum:
  - `@ApiOperation`
  - success response decorator (`@ApiOkResponse`/equivalent)
  - auth/error response decorators where applicable (`401/403/400/404`)
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
- Group role/status transitions must never leave a group with zero ACTIVE admins.

## Profile completion rules
- Ethiopian-style legal profile names are mandatory before main app access:
  - `firstName` (First Name)
  - `middleName` (Father's Name)
  - `lastName` (Grandfather's Name)
- `profileComplete` is true only when `firstName`, `middleName`, and `lastName` are all non-empty after trim/whitespace normalization.
- Auth flows (`verify-otp`, session bootstrap, and refresh-backed user payloads) must expose the latest name fields and `profileComplete` so clients can enforce profile gating.

## Testing rules
- Add unit tests for services that implement business rules.
- Add e2e tests for auth and 1 critical group/cycle flow.
- Migrations must be deterministic and checked in.

## Group membership rules
- Invite codes are uppercase URL-safe strings (8 chars) and must be unique.
- Rejoin policy:
  - `INVITED` -> can activate membership by joining with invite
  - `LEFT` -> can rejoin with invite and become `ACTIVE`
  - `REMOVED` -> cannot self-rejoin via invite code

## Cycle rules
- Random-draw rounds use an immutable per-round schedule; manual payout order is not required for cycle generation in random mode.
- Only one `OPEN` cycle is allowed per group at any time.
- When generating multiple cycles in one request, earlier generated cycles are marked `CLOSED` and only the last generated cycle is `OPEN`.
- Due-date progression rules:
  - `WEEKLY`: add exactly 7 days
  - `MONTHLY`: add one calendar month and clamp to last day when day-of-month overflows (timezone-aware)
- Random-draw payout schedules are immutable per round after round start; cycle generation must consume schedule positions in order.
- Cycle auction impacts only the current cycle’s `finalPayoutUserId`; the scheduled recipient remains unchanged for round order continuity.
- Auction winner selection is deterministic: highest bid wins, and ties are resolved by earliest bid `createdAt`.
- Bid visibility rule is locked: active admins and the scheduled recipient can view all cycle bids; other active members can view only their own bid.

## Contribution rules
- Contribution proof object key format is locked to:
  - `groups/<groupId>/cycles/<cycleId>/users/<userId>/<uuid>_<sanitizedFileName>`
- Proof file keys must match the submitting member's `groupId/cycleId/userId` scope.
- Contribution state transitions:
  - submit/resubmit: `PENDING|REJECTED|SUBMITTED -> SUBMITTED`
  - confirm: `SUBMITTED -> CONFIRMED`
  - reject: `SUBMITTED -> REJECTED`
- `CONFIRMED` contributions are immutable (no resubmit/update).
- Privacy rule: contribution list responses expose member phone numbers only to ACTIVE admins; non-admin members receive `phone = null`.

## Payout rules
- Payout recipient is strict: payout `toUserId` must match `EqubCycle.finalPayoutUserId` (no override in MVP).
- Strict payout confirmation uses current ACTIVE members (MVP): every ACTIVE member must have a `CONFIRMED` contribution for the cycle.
- In non-strict mode, payout confirmation is allowed with missing confirmations, but audit metadata must include required/confirmed/missing counts.
- Cycle closure prerequisites:
  - `EqubCycle` must be `OPEN`
  - a payout must exist for the cycle
  - payout must be `CONFIRMED`
  - cycle transition is one-way: `OPEN -> CLOSED`
- Payout proof object key format is locked to:
  - `groups/<groupId>/cycles/<cycleId>/payouts/<uuid>_<sanitizedFileName>`

## Notification and jobs rules
- Notification types are locked to:
  - `MEMBER_JOINED`
  - `CONTRIBUTION_SUBMITTED`
  - `CONTRIBUTION_CONFIRMED`
  - `CONTRIBUTION_REJECTED`
  - `PAYOUT_CONFIRMED`
  - `DUE_REMINDER`
- Event triggers (MVP):
  - `MEMBER_JOINED` -> notify active group admins
  - `CONTRIBUTION_SUBMITTED` -> notify active group admins
  - `CONTRIBUTION_CONFIRMED` / `CONTRIBUTION_REJECTED` -> notify contributor
  - `PAYOUT_CONFIRMED` -> notify active group members
  - `DUE_REMINDER` -> notify active members missing `SUBMITTED|CONFIRMED` contribution
- Reminder scheduler runs daily at `09:00` in `Africa/Addis_Ababa` and enqueues a reminder-scan job.
- Reminder dedup strategy is locked to one reminder per `(userId, cycleId, type, local-date)` using `dataJson.dedupKey` and queue `jobId`.
- FCM config method is env-based (no JSON file path):
  - `FCM_DISABLED`
  - `FCM_PROJECT_ID`
  - `FCM_CLIENT_EMAIL`
  - `FCM_PRIVATE_KEY` (supports escaped newlines)

## Folder conventions
- `apps/api` is the canonical backend implementation path. If a legacy `server/` scaffold exists, treat it as deprecated bootstrap code and do not add new phase work there.
- `apps/api/src/modules/<module>/`
  - `<module>.module.ts`
  - `<module>.controller.ts`
  - `<module>.service.ts`
  - `dto/`
  - `entities/` (optional)
- Shared guards/decorators in `apps/api/src/common/`
- `apps/mobile` is the canonical Flutter client path.
- `apps/mobile/lib/` structure:
  - `app/` for bootstrap, router, and theme
  - `data/api/` for networking, token storage, and API errors
  - `data/models/` for Freezed models
  - `features/<feature>/` for feature screens and logic
  - `shared/widgets/` and `shared/utils/` for reusable UI and helpers

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
  - JOBS_DISABLED
  - JWT_ACCESS_SECRET
  - JWT_REFRESH_SECRET
  - OTP_TTL_SECONDS
  - S3_ENDPOINT
  - S3_BUCKET
  - S3_ACCESS_KEY
  - S3_SECRET_KEY
  - S3_REGION
  - S3_FORCE_PATH_STYLE
  - FCM_DISABLED
  - FCM_PROJECT_ID
  - FCM_CLIENT_EMAIL
  - FCM_PRIVATE_KEY
  - SENTRY_DSN
- Mobile env example: `apps/mobile/.env.example` must include `API_BASE_URL`.

## Mobile rules
- Env strategy is locked to `flutter_dotenv`:
  - Load `.env` at startup from `apps/mobile/.env`
  - `API_BASE_URL` is required and must fail-fast if missing
- Never hardcode API URLs or secrets in Flutter source.
- Dio client must attach bearer token when present and attempt one refresh-token rotation on `401` before failing.
- Default in-app back navigation UI must use the shared rounded-square chevron style (`KitBackButton` in `shared/kit/kit_app_bar.dart`) unless a screen has an explicit product exception.
- Shared `KitAppBar` should use the profile-style hierarchy (avatar + title + optional status/subtitle) app-wide, while preserving the existing `KitBackButton` visual style.
- Group detail screen is the canonical group landing page; avoid creating parallel group profile pages unless a product requirement explicitly adds one.
- Group detail content must render real Equb domain data (group/member fields and valid actions) and should avoid placeholder-only sections that are not backed by app data.
- Group detail headers should be implemented via `appBar` (sticky) instead of placing header rows inside scrollable content.
- Header "more actions" controls for group context should use the rounded-square popup menu style (`GroupMoreActionsButton`) with contextual actions (for example report/boost/leave).
- Group header/dropdown actions should include `Edit group` for admins.
- Group UI status labels must reflect `GroupStatusModel` values (for example `ACTIVE`/`ARCHIVED`) and should not use chat-presence wording such as "online".
- Group detail pages should present core actions (`Members`, `Cycles`, `Payout`) as segmented in-page tabs instead of navigating to separate top-level screens by default.
- Group invite actions should be exposed via the invite banner/CTA and menu actions, not as a default segmented tab.
- Group detail segmented tab controls must remain compact-width and text-scale safe (no `RenderFlex` overflow under high accessibility text scales).
- Group detail metadata badges and invite summary blocks must adapt to compact widths (horizontal scroll and/or stacked layout) so no `RenderFlex` overflow occurs on narrow devices.
- Feature screens should use `KitScaffold` + `KitCard` as the default page/surface primitives so gradient background treatment, width constraints, spacing rhythm, and card styling stay consistent app-wide.
- Root tab screens should start with a `KitSectionHeader` title/subtitle row and place top-right utility actions (for example notifications) in the header `action` slot for consistent page chrome.
- Decorative/motif colors should come from `AppBrandDecor` theme extension (`app/theme/app_theme_extensions.dart`) rather than hardcoded values in widgets.
- Decorative backgrounds must remain low-contrast with surfaces (subtle motif lines/glows and near-surface gradients) so content cards and form controls remain the visual focus.
- Default expanded CTA buttons in shared kit should be width-capped (not full-bleed on wide layouts) to keep action controls compact and readable.
- Shared kit buttons must clamp text to one line with ellipsis in icon+label rows to avoid `RenderFlex` overflow under high accessibility text scales.
- Notification bootstrap must not access `FirebaseMessaging.instance` before Firebase app initialization; push setup should degrade gracefully when Firebase config is unavailable.
- Bottom tab navigation must be docked to the bottom edge (no floating/lift), span left-to-right, and use the app primary color for the active tab state (`app/app_shell.dart`) unless a product requirement explicitly overrides it.
- Bottom tab taps should use subtle motion (reduced size delta and short animation) plus light haptic feedback (`HapticFeedback.selectionClick`) in `app/app_shell.dart`.
