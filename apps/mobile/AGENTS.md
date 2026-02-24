# AGENTS.md — Equb Mobile (Flutter) Rules

## Prime directive
- Any new mobile-wide convention or rule discovered while implementing must be added to this file before finishing.

## Tech stack (locked)
- Flutter + Dart
- Riverpod for state management
- GoRouter for navigation
- Dio for HTTP
- flutter_secure_storage for token persistence
- Freezed + json_serializable for models

## Env rules (locked)
- Use `flutter_dotenv` only.
- Load `apps/mobile/.env` during app bootstrap.
- `API_BASE_URL` is mandatory; app must fail-fast with a clear message if missing.
- `API_TIMEOUT_MS` configures Dio timeout and defaults only via env parsing logic.
- Never hardcode API URLs/secrets in source code.

## Auth/network rules
- Access token must be attached as `Authorization: Bearer <token>` when present.
- On `401`, attempt refresh once using `/auth/refresh` and retry original request exactly once.
- If refresh fails, clear stored tokens and mark session expired for router redirect to `/login`.
- Router baseline is locked to:
  - `/splash` as initial route while checking token presence
  - `/login` for unauthenticated sessions
  - `/home` for authenticated sessions

## Folder conventions
- `lib/app/`
  - `app.dart`, `router.dart`, `theme.dart`, `bootstrap.dart`
- `lib/app/theme/`
  - `app_theme.dart`, `app_colors.dart`, `app_typography.dart`
  - `app_spacing.dart`, `app_components.dart`, `app_theme_extensions.dart`
- `lib/data/api/`
  - `api_client.dart`, `api_error.dart`
- `lib/data/auth/`
  - `token_store.dart`, `auth_api.dart`, `auth_repository.dart`
- `lib/data/groups/`
  - `groups_api.dart`, `groups_repository.dart`
- `lib/data/models/`
- `lib/features/<feature>/`
- `lib/features/auth/screens/`
  - `phone_screen.dart`, `otp_screen.dart`
- `lib/features/groups/screens/`
  - `groups_list_screen.dart`, `create_group_screen.dart`, `join_group_screen.dart`
  - `group_detail_screen.dart`, `group_members_screen.dart`, `group_invite_screen.dart`
- `lib/shared/widgets/`
- `lib/shared/utils/`

## UI quality baseline
- Every screen should provide loading and error states.
- Reuse shared widgets for buttons, text fields, loading, and error views.
- Keep visuals minimal and clear; prioritize stable flow over complex design.
- User-facing error surfaces must show mapped friendly messages (`mapFriendlyError` / `mapApiErrorToMessage`) instead of raw exception `toString()`.

## Theming rules
- Theme tokens in `lib/app/theme/` are the single source of truth for app styling.
- Do not hardcode colors in feature/shared UI files; use `Theme.of(context).colorScheme` or theme extensions.
- No feature screen should use raw `Colors.*`; use theme tokens/extensions only.
- All pills/badges must use semantic tint palettes from `AppSemanticColors` (`context.colors`).
- Spacing and corner radii must use `AppSpacing` and `AppRadius` tokens.
- Standard content padding is `16` (`AppSpacing.md`) unless a component explicitly defines otherwise.

## Auth rules
- Token refresh is attempted at most once per failing request (`401`) before surfacing an auth error.
- Logout must call backend refresh-token revocation when refresh token exists, and must always clear secure storage locally.
- Never log access tokens or refresh tokens.
- Router redirects are locked to:
  - `unknown` auth state -> `/splash`
  - unauthenticated users -> `/login` for protected routes; `/otp` is allowed and must handle missing phone gracefully in-screen
  - authenticated users cannot navigate back to `/login` or `/otp`

## Profile onboarding rules
- Ethiopian naming is mandatory: `First Name`, `Father's Name`, and `Grandfather's Name` are all required profile fields.
- Profile completion status gates access to main tab routes (`/home`, `/groups`, `/settings`); incomplete profiles must be routed to `/onboarding/profile`.
- Onboarding/profile-completion screens must not render bottom navigation and must be non-back-navigable until completion succeeds.
- UI labels must be Ethiopia-friendly; never use `Middle Name` wording in user-facing screens.

## Groups rules
- Authenticated landing route is locked to `/home`.
- Admin group creation must route directly into full-screen group setup (`/groups/:id/setup`) with Rules step before normal group actions continue.
- Group setup flow is locked to a two-step gate:
  - Step 1: `Rules`
  - Step 2: `Invite & Verify` (member status pills + admin verify action)
- Group actions that depend on rules (`Invite members`, `Draw winner` / cycle start) must stay disabled or redirect to setup until `rulesetConfigured` is true in group payloads.
- Cycle-start CTAs must respect backend `canStartCycle` (includes eligibility count and verification requirements), not rules-only assumptions.
- Group detail and members use repository-backed in-memory caches; manual refresh must invalidate cache and fetch fresh data.
- Member identity display fallback is locked to: `fullName` -> `phone` -> `'Member'`.
- If a group has an active round, joining and invite acceptance are blocked; join surfaces must explain that joining is available after the round ends.
- Backend lock responses are source-of-truth; mobile must always handle `409` with reason code `GROUP_LOCKED_ACTIVE_ROUND` even when UI pre-checks exist.
- Group detail header title is tappable and navigates to the full-screen Group Overview route (`/groups/:id/overview`).
- Members list lives only in Group Overview; there is no standalone Members screen route.
- Group detail is the current-round hub and must not render the members list.
- Group detail should favor collapsed summaries and a single primary member CTA over dense list sections.
- Admin controls in group detail must be grouped inside a collapsed Admin actions container/action sheet.
- Group Overview content must reuse existing group detail/members providers; do not introduce duplicate fetch pathways.

## Cycles rules
- Payout order positions are always saved as contiguous `1..N` after reorder; the UI order is the source of truth.
- Admin-only cycle actions (set payout order, generate cycles) must only be shown when `membership.role == ADMIN`.
- No batch cycle generation in UI; cycle start is always a single "Start cycle" action (`POST /groups/:id/cycles/start`).
- After cycle mutations (`setPayoutOrder`, `generateCycles`/start-cycle), invalidate cycle providers (`current`, `list`, relevant details) and members cache/providers before refetching.
- Group detail current-turn summary must show due-date context and keep member payment entry as a primary `Pay now` CTA.
- Group detail contribution summary for admins must surface overdue/late counts and link to the contributions list for triage.
- Cycle auction affects only the current cycle final recipient (`finalPayoutUserId`); it must not mutate the scheduled recipient or round order.
- Scheduled recipient (and admins) can open/close cycle auction; non-admin, non-scheduled members can only submit bids while auction is open.
- Bid visibility in UI is locked to backend scope: admins/scheduled recipient see all bids, other members see only their own bid entries.
- User-facing round language is locked to `🎲 Lottery`.
- Lottery is per-turn only; future winners must never be visible in UI.
- No UI element may imply a pre-generated visible winner list/order.
- Admins must manually initiate each turn by tapping `🎲 Draw winner`.
- Draw reveal animation is cosmetic only; winner data must come from backend draw response.
- Group Overview must show lottery summary (turns completed, last winner, round status) and must not show future-turn lists.

## Uploads & contributions rules
- Signed proof uploads must use a separate Dio client with no auth interceptors; never upload proof files through authenticated API endpoints.
- The `Content-Type` used for signed upload request must exactly match the `Content-Type` sent in signed PUT upload.
- Contribution payment submit payload is locked to include payment rail (`BANK` | `TELEBIRR` | `CASH_ACK`) plus receipt upload key (`receiptFileKey`) and optional reference.
- Contribution state transitions are backend-authoritative: submit/resubmit payment to `PAID_SUBMITTED`, admin verify to `VERIFIED`, admin reject to `REJECTED`; legacy `SUBMITTED`/`CONFIRMED` remain compatibility states.
- Late handling is backend-authoritative: `LATE` contributions must be shown with warning emphasis and member-facing copy should mention grace/fine implications.
- Admin contributions screen must expose a manual cycle evaluation action (`POST /cycles/:cycleId/evaluate`) and refresh cycle/contribution providers after evaluation.
- Dispute workflow UI is required from contribution context:
  - open via `Report mismatch`
  - show dispute statuses (`OPEN`, `MEDIATING`, `RESOLVED`) and resolution outcome/note
  - admins can mediate/resolve from dispute status screen.
- Resubmission UX should only be offered when contribution is not `VERIFIED|CONFIRMED`, and primarily after `REJECTED` as permitted by backend rules.

## Payout rules
- Payout flow order is locked to: select winner -> disburse payout -> close cycle.
- Admin payout screen must show winner-selection controls only when cycle state is `READY_FOR_PAYOUT`.
- Winner-selection UI must adapt to ruleset payout mode (`LOTTERY`, `AUCTION`, `ROTATION`, `DECISION`).
- Close-cycle UI should support `autoNext` and, on success, refresh current-cycle state so the next due cycle appears when created.
- Payout recipient must always follow cycle `finalPayoutUserId` (not scheduled recipient) in UI labels and actions.
- Strict payout failures must show guidance to review cycle contributions before retrying confirmation.
- Closing a cycle must invalidate and refresh cycle detail, current cycle, cycles list, and cycle payout state.

## Notifications rules
- Device token registration is best-effort and must only call `/devices/register-token` when token changed for the current authenticated user context.
- Deep-link resolution from notification payload must stay centralized in `features/notifications/deeplink_mapper.dart`.
- Notification deep-link mapper should prefer explicit payload `route` when present, then fall back to `groupId`/`cycleId` mapping.
- Tapping a notification row must mark it as read first, then navigate when a resolvable deep link exists.
- Push delivery is optional; the app must keep notifications UX functional without Firebase by relying on in-app list and graceful fallback behavior.

## Polish & Navigation rules
- Main app sections must live under shell navigation with bottom tabs (`/home`, `/groups`, `/settings`); logout action belongs in Settings.
- Use `context.push` for drill-down/detail routes and `context.go` only for root section switches or auth roots.
- In tabbed flows, use `go()` only for root tab switches (`/home`, `/groups`, `/settings`) and `push()` for in-tab drill-down routes.
- App bars must render an explicit back button (`leading: BackButton()`) when `context.canPop()` is true.
- Shared UI under `lib/shared/ui/` is the default for layout and repeated visuals (cards, list rows, badges, empty/loading feedback, snackbars).
- Standard content padding is `16` horizontal (`AppSpacing.md`); section spacing should stay within `12-16` (`AppSpacing.sm` to `AppSpacing.md`).

## Header rules
- Feature pages must use `KitScaffold(appBar: KitAppBar(...))` instead of defining custom `AppBar` widgets.
- `KitAppBar` is the single header primitive: centered title, optional subtitle, optional leading override, optional right actions, and auto-back when route can pop.
- Root tab pages (`/home`, `/groups`, `/settings`) must force `showBackButton: false`.
- Pushed/detail pages rely on `KitAppBar` default back behavior (`context.canPop()`).
- Headerless exceptions are allowed for auth screens (`/login`, `/otp`) and root tab pages (`/home`, `/groups`, `/settings`) when the product design calls for immersive top content.

## Tab architecture rules
- Bottom tabs are implemented with `StatefulShellRoute.indexedStack` using separate navigator keys (`home`, `groups`, `settings`) so each tab preserves its own navigation stack.
- Notifications are not a tab; `/notifications` is a root overlay route (`parentNavigatorKey: root`) opened from app-bar bell actions.
- Notifications must always open as an overlay on the root navigator, independent of active tab stack.
- Notification/deeplink navigation into groups must use centralized helper flow: switch to `/groups` first, then push the target group route.

## Bottom nav visibility rules
- Bottom nav is visible only on exact root tab paths: `/home`, `/groups`, `/settings`.
- Bottom nav must be hidden for all pushed/detail and overlay paths (for example: `/groups/create`, `/groups/join`, `/groups/:id/...`, `/notifications`).
- In `AppShell`, tab bar visibility is determined from current location exact-match checks against root tab paths.
- Detail navigation must use `context.push(...)` to preserve per-tab history stacks; tab switching uses shell branch switching (`goBranch`) or root `go(...)`.

## DX commands
- Install deps: `flutter pub get`
- Codegen: `flutter pub run build_runner build --delete-conflicting-outputs`
- Analyze: `flutter analyze`
- Test: `flutter test`
