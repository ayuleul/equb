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
- Group ruleset is a required gate after group creation; invite creation, invite acceptance/join, and cycle start must return `409` (`GROUP_RULESET_REQUIRED`) until rules are configured.
- Group response payloads must include computed flags: `rulesetConfigured`, `canInviteMembers`, and `canStartCycle` (invite/start flags are true only when rules are configured).
- Membership lifecycle is verification-based:
  - canonical statuses: `INVITED` -> `JOINED` -> `VERIFIED`
  - suspension/removal state: `SUSPENDED`
- Membership verification metadata is tracked with:
  - `verifiedAt`
  - `verifiedByUserId`
- Optional guarantor linkage for late alerts is tracked on membership via:
  - `guarantorUserId` (nullable)
- Invite codes are uppercase URL-safe strings (8 chars) and must be unique.
- Rejoin policy:
  - `INVITED` -> can activate membership by joining with invite
  - `SUSPENDED` -> cannot self-rejoin via invite code
- Membership is locked while a cycle is open (`EqubCycle.status == OPEN`); join/accept-invite/add-member paths must be blocked at API level with `409` (`GROUP_LOCKED_OPEN_CYCLE`).
- Invite creation is allowed during an open cycle, but invite acceptance remains blocked until the cycle closes.

## Cycle rules
- Only one `OPEN` cycle is allowed per group at any time.
- Cycle start endpoint is locked to `POST /groups/:id/cycles/start`; legacy round/draw-next/payout-order and batch-generation routes are removed.
- Cycle lifecycle state machine is locked to:
  - `DUE -> COLLECTING -> READY_FOR_PAYOUT -> DISBURSED -> CLOSED`
- Starting a cycle must create due contribution rows (`PENDING`) for every eligible member snapshot at cycle-start time.
- Collection readiness rule is locked:
  - `strictCollection = true`: cycle may move to `READY_FOR_PAYOUT` only when all due contribution rows are `VERIFIED|CONFIRMED`
  - `strictCollection = false`: payout readiness may proceed when at least one contribution is verified (admin can proceed after evaluation).
- Collection evaluation endpoint is locked to `POST /cycles/:cycleId/evaluate` (admin), and is the manual trigger for late/fine processing in MVP.
- Due-date progression rules:
  - `WEEKLY`: add exactly 7 days
  - `MONTHLY`: add one calendar month and clamp to last day when day-of-month overflows (timezone-aware)
  - `CUSTOM_INTERVAL` (ruleset frequency): add exactly `customIntervalDays` days (timezone-aware day boundaries)
- Cycle start eligibility gate is locked:
  - ruleset must be configured
  - eligible member count must be at least `2`
  - if `requiresMemberVerification = true`, only `VERIFIED` members are eligible
  - otherwise, joined/participating members are eligible.
- Cycle auction impacts only the current cycle’s `finalPayoutUserId`; no pre-generated payout order/schedule is used.
- Auction winner selection is deterministic: highest bid wins, and ties are resolved by earliest bid `createdAt`.
- Winner selection is explicit per cycle and must run only after cycle state reaches `READY_FOR_PAYOUT`.
- Bid visibility rule is locked: active admins can view all cycle bids; other active members can view only their own bid.

## Contribution rules
- Contribution proof object key format is locked to:
  - `groups/<groupId>/cycles/<cycleId>/users/<userId>/<uuid>_<sanitizedFileName>`
- Proof file keys must match the submitting member's `groupId/cycleId/userId` scope.
- Presigned `PutObject` upload URLs must be generated without flexible-checksum query params for MinIO compatibility (set S3 client `requestChecksumCalculation` to `WHEN_REQUIRED`).
- Upload signing must defensively re-presign via `S3RequestPresigner` when checksum query params are detected, to guarantee MinIO-compatible `PUT` URLs.
- Contribution state transitions:
  - submit/resubmit payment: `PENDING|REJECTED|PAID_SUBMITTED|SUBMITTED -> PAID_SUBMITTED`
  - verify: `PAID_SUBMITTED|SUBMITTED|LATE -> VERIFIED`
  - reject: `PAID_SUBMITTED|SUBMITTED|LATE -> REJECTED`
  - late marking: when `dueAt + graceDays` has passed and status is not `VERIFIED|CONFIRMED`, `status -> LATE`
  - confirm actions must preserve `VERIFIED` semantics for existing integrations.
- Verified/confirmed contributions are immutable (no resubmit/update).
- Each payment submission must create/update a `ContributionReceipt` record and append a `LedgerEntry` of type `MEMBER_PAYMENT`.
- Each admin verification must append a `LedgerEntry` of type `CONTRIBUTION_VERIFIED` with confirmer metadata.
- Late fine rule is locked: when ruleset fine policy is `FIXED_AMOUNT` and contribution becomes `LATE`, create one `LedgerEntry` of type `LATE_FINE` per contribution (idempotent).
- Dispute flow is locked:
  - create: `POST /contributions/:id/disputes`
  - mediate: `POST /disputes/:id/mediate`
  - resolve: `POST /disputes/:id/resolve`
  - states: `OPEN -> MEDIATING -> RESOLVED`
- Privacy rule: contribution list responses expose member phone numbers only to ACTIVE admins; non-admin members receive `phone = null`.

## Payout rules
- Canonical payout flow is locked to:
  - `POST /cycles/:cycleId/winner/select`
  - `POST /cycles/:cycleId/payout/disburse`
  - `POST /cycles/:cycleId/close` (optional `autoNext`)
- Payout recipient is strict: payout `toUserId` must match `EqubCycle.finalPayoutUserId` (no override in MVP).
- Strict payout confirmation uses current ACTIVE members (MVP): every ACTIVE member must have a `VERIFIED|CONFIRMED` contribution for the cycle.
- In non-strict mode, payout confirmation is allowed with missing confirmations, but audit metadata must include required/confirmed/missing counts.
- Cycle closure prerequisites:
  - `EqubCycle` must be `OPEN`
  - a payout must exist for the cycle
  - payout must be `CONFIRMED`
  - cycle transition is one-way: `OPEN -> CLOSED`
- Payout proof object key format is locked to:
  - `groups/<groupId>/cycles/<cycleId>/payouts/<uuid>_<sanitizedFileName>`
- Cycle close with `autoNext = true` should attempt next-cycle start; if auto-next fails, cycle close remains successful and next cycle can be started manually.

## Notification and jobs rules
- Notification types are locked to:
  - `MEMBER_JOINED`
  - `CONTRIBUTION_SUBMITTED`
  - `CONTRIBUTION_CONFIRMED`
  - `CONTRIBUTION_REJECTED`
  - `CONTRIBUTION_LATE`
  - `DISPUTE_OPENED`
  - `DISPUTE_MEDIATING`
  - `DISPUTE_RESOLVED`
  - `PAYOUT_CONFIRMED`
  - `DUE_REMINDER`
  - `LOTTERY_WINNER`
  - `LOTTERY_ANNOUNCEMENT`
- Event triggers (MVP):
  - `MEMBER_JOINED` -> notify active group admins
  - `CONTRIBUTION_SUBMITTED` -> notify active group admins
  - `CONTRIBUTION_CONFIRMED` / `CONTRIBUTION_REJECTED` -> notify contributor
  - `CONTRIBUTION_LATE` -> notify late member and configured guarantor
  - `DISPUTE_OPENED` -> notify active admins and involved contributor
  - `DISPUTE_MEDIATING` / `DISPUTE_RESOLVED` -> notify involved dispute parties
  - `PAYOUT_CONFIRMED` -> notify active group members
  - `DUE_REMINDER` -> notify active members missing `PAID_SUBMITTED|SUBMITTED|VERIFIED|CONFIRMED` contribution
  - `LOTTERY_WINNER` -> notify drawn cycle winner
  - `LOTTERY_ANNOUNCEMENT` -> notify all other active group members
- Lottery draw notifications are idempotent per user/event via `Notification.eventId` (for example `DRAW_<cycleId>_WINNER` and `DRAW_<cycleId>_ANNOUNCEMENT`).
- Winner selection/disbursement notifications are idempotent per user/event via `Notification.eventId`:
  - winner: `SELECT_<cycleId>_WINNER`
  - announcement: `SELECT_<cycleId>_ANNOUNCEMENT`
  - payout disbursed: `PAYOUT_DISBURSED_<cycleId>`
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
- MinIO upload buckets are not auto-created by the base `minio` image; ensure `S3_BUCKET` (default `equb-dev`) exists before signed `PUT` uploads, especially after `docker compose down -v`.
- Signed file URLs must use a client-reachable host via `S3_PUBLIC_ENDPOINT` (for Android emulator use `http://10.0.2.2:9000`; `localhost` is not reachable from emulator apps).

## Required files
- `docker-compose.yml` at repo root (or `/infra/docker/docker-compose.yml` but must be documented here)
- `.env.example` for API (apps/api/.env.example) includes:
  - DATABASE_URL
  - REDIS_URL
  - JOBS_DISABLED
  - JWT_ACCESS_SECRET
  - JWT_REFRESH_SECRET
  - DRAW_SEED_ENC_KEY
  - OTP_TTL_SECONDS
  - S3_ENDPOINT
  - S3_PUBLIC_ENDPOINT
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
