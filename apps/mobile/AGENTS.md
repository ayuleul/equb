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
- Realtime sockets are an enhancement only: REST stays the source of truth for initial screen loads and full-state refreshes.

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
- Ethiopian naming is mandatory: `First Name` and `Father's Name` are required profile fields, and `Grandfather's Name` is optional.
- Profile completion status gates access to main tab routes (`/home`, `/groups`, `/settings`); incomplete profiles must be routed to `/onboarding/profile`.
- Onboarding/profile-completion screens must not render bottom navigation and must be non-back-navigable until completion succeeds.
- UI labels must be Ethiopia-friendly; never use `Middle Name` wording in user-facing screens.

## Groups rules
- Authenticated landing route is locked to `/home`.
- Admin group creation must route directly into full-screen group setup (`/groups/:id/setup`) with Rules step before normal group actions continue.
- Group setup flow is locked to a two-step gate:
  - Step 1: `Rules`
  - Step 2: `Invite & Verify` (member status pills + admin verify action)
- Group setup Step 1 must expose start configuration with only these canonical controls:
  - `Round size`
  - `Start policy` (`WHEN_FULL`, `ON_DATE`, `MANUAL`)
  - conditional `Start date` (only for `ON_DATE`)
  - conditional optional `Minimum to start` (for `ON_DATE`/`MANUAL`; blank means `roundSize`)
- Group setup policy controls must include `winnerSelectionTiming` with friendly labels `Before collection` and `After collection`; `AUCTION` and `DECISION` payout modes must force `After collection`.
- Start preview text in setup must reflect backend semantics using `requiredToStart`, member eligibility count, and waiting state (members/date).
- Group actions that depend on rules (`Invite members`, `Start cycle`) must stay disabled or redirect to setup until `rulesetConfigured` is true in group payloads.
- Cycle-start CTAs must respect backend `canStartCycle` (includes eligibility count and verification requirements), not rules-only assumptions.
- Group detail and members use repository-backed in-memory caches; manual refresh must invalidate cache and fetch fresh data.
- Group screens should route manual refresh and post-mutation cache invalidation through `group_detail_controller.dart` helpers instead of hand-rolling provider/repository invalidation inside widgets.
- Member identity display fallback is locked to: `fullName` -> `phone` -> `'Member'`.
- If a group has an open cycle, joining and invite acceptance are blocked; join surfaces must explain that joining is available after the cycle closes.
- Backend lock responses are source-of-truth; mobile must always handle `409` with reason code `GROUP_LOCKED_OPEN_CYCLE` even when UI pre-checks exist.
- Group detail header title is tappable and navigates to the full-screen Group Overview route (`/groups/:id/overview`).
- Members list lives only in Group Overview; there is no standalone Members screen route.
- Group detail is the current-cycle hub and must not render the members list.
- Group detail should favor collapsed summaries and a single primary member CTA over dense list sections.
- Group main page has two exclusive modes:
  - `PRE-START` before the first/open turn exists
  - `ACTIVE` once a turn exists
- Group main page `PRE-START` mode must replace empty-turn copy and show, in order:
  - setup progress for exactly three rules steps: `Basics`, `Timing`, `Policy`
  - inline `Members` invite/verify operations on the same page
  - a start-group/start-first-turn CTA with readiness guidance
- Group invite generation belongs to the main Group page members section and should open in a bottom sheet; do not keep or add a standalone invite screen route.
- Invite CTAs from other group surfaces (for example Group Overview admin actions) should open the same invite bottom sheet in place rather than navigate away first.
- Group main page `ACTIVE` mode must show turn operations only (`Current Turn` hero followed by `Past Turns`) and must not mix in setup or member-verification sections.
- Do not show `No active turn yet` on the group main page; use positive setup/start readiness copy instead.
- Group page is overview-only: compact past turns, one dominant current-turn card, and a contribution summary; operational detail belongs elsewhere.
- Group page layout is locked to one unified current-turn hero card followed by `Past Turns`; do not split the current turn into separate titled cards on the main group page.
- Current Turn must always be visually dominant over history; past turns are secondary and appear only below the unified hero card.
- Current-turn actions must be visible directly inside the hero card when relevant; do not move core actions behind bottom sheets or modal menus.
- Do not use internal hero-card titles like `Contribution summary`, `Admin actions`, or `Your action` inside the current-turn card; separate content with spacing and dividers instead.
- Use clear turn CTA copy such as `See turn details` instead of weaker phrasing like `View turn details`.
- Turn Details is the operational hub for a turn and should carry contribution, payout, auction, and dispute complexity instead of the main group page.
- Contributions live under a specific turn; the main group page must not render the full contributions list.
- Past turns on the group page use compact summary rows, while the current turn uses the highlighted hero card treatment.
- When the latest Equb round is fully paid out and no current turn is open, the main group hero must switch to a completed state (`Equb Completed` / `All members have received their payout`) and must not show next-turn/draw actions for the finished round.
- Admin controls in group detail must be grouped inside a collapsed Admin actions container/action sheet.
- Group Overview content must reuse existing group detail/members providers; do not introduce duplicate fetch pathways.

## Cycles rules
- No batch cycle generation in UI; cycle start is always a single "Start cycle" action (`POST /groups/:id/cycles/start`).
- After cycle mutations (`start-cycle`, payout, close), invalidate cycle providers (`current`, `list`, relevant details) and members cache/providers before refetching.
- Group detail current-turn summary must show due-date context and keep member payment entry as a primary `Pay now` CTA.
- Group detail contribution summary for admins must surface overdue/late counts and link to the contributions list for triage.
- Turn details routes should use user-facing `turn` language in navigation (`/groups/:groupId/turns/:turnId`) even when underlying providers/entities still use cycle identifiers.
- Cycle auction affects only the current cycle final recipient (`finalPayoutUserId`); no pre-generated payout order/schedule is shown in UI.
- Auction open/close actions are admin-only; non-admin members can only submit bids while auction is open.
- Bid visibility in UI is locked to backend scope: admins see all bids, other members see only their own bid entries.
- Winner information must come from cycle winner-selection/disbursement state; no UI element may imply pre-generated future winners.
- `selectedWinnerUserId` is the canonical winner signal in UI; do not show scheduled/final payout placeholders as the winner before selection actually happens.
- Turn payout CTA flow is locked to:
  - `Draw winner`
  - `Mark payout sent`
  - `Confirm receipt`
  - `Turn completed`
- Mobile must not show any `Close turn` action before the selected winner confirms payout receipt.
- Group Overview must show cycle summary (completed cycles, last winner, current status) and must not show future-turn lists.
- Group turn surfaces should show per-member payout progress for the latest round using explicit `Received` / `Pending` states plus the received turn number when available.
- Cycle-focused UI surfaces must group turn records by round and label completed Equb runs as `Cycle 1`, `Cycle 2`, etc.; a new cycle in the same group must restart visible turn numbering from `Turn 1` instead of continuing the previous round’s turn count.

## Realtime rules
- Realtime is used first only on Group Details and Turn Details; do not wire socket subscriptions into unrelated screens by default.
- Only Group Details and Turn Details own realtime room subscriptions. Auxiliary mutation/detail screens under those flows must not join their own socket rooms; they should rely on the underlying detail screen plus one-time fallback refresh if needed.
- Group and turn screens must join their socket rooms on open and leave them on dispose.
- Group Details should run one targeted catch-up refresh when it becomes the current route again after deeper group/turn flows are popped, so the page does not depend on manual pull-to-refresh after nested actions.
- For socket-covered entities, REST is used for initial load and mutation requests only; live state changes after mutation should come from socket events.
- Socket events should invalidate/refetch Riverpod providers through existing controllers; do not build per-field patch logic for Equb entities in the client.
- Do not manually refetch socket-covered entities after successful mutation when the same entity will be updated by socket.
- Use one fallback refetch only if the expected socket event does not arrive within a short timeout; never turn that fallback into polling.
- Socket is the primary live-update trigger for Group Details and Turn Details.
- Group-detail socket refresh for turn-state events must use targeted current-turn invalidation (`currentCycle`, `cyclesList`, turn contributions/payout) instead of full group-page reloads; reserve full group-page refresh for membership/setup changes.
- Realtime-driven refetch on a screen must coalesce burst events into a short debounce window instead of issuing one REST refresh per socket message.
- Repository read paths used by realtime-driven detail screens must dedupe in-flight requests so repeated invalidations collapse onto a single HTTP call per resource key before hitting Dio.
- Realtime failures must never block navigation or core REST actions; the screen should continue working with manual/REST refresh.

## Uploads & contributions rules
- Signed proof uploads must use a separate Dio client with no auth interceptors; never upload proof files through authenticated API endpoints.
- The `Content-Type` used for signed upload request must exactly match the `Content-Type` sent in signed PUT upload.
- Contribution payment submit payload is locked to include payment rail (`BANK` | `TELEBIRR` | `CASH_ACK`) plus receipt upload key (`receiptFileKey`) and optional reference.
- Contribution state transitions are backend-authoritative: submit/resubmit payment to `PAID_SUBMITTED`, admin verify to `VERIFIED`, and admin reject to `REJECTED`.
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
- Payout recipient must always follow cycle `finalPayoutUserId` in UI labels and actions.
- Strict payout failures must show guidance to review cycle contributions before retrying confirmation.
- Closing a cycle must invalidate and refresh cycle detail, current cycle, cycles list, and cycle payout state.

## Notifications rules
- Device token registration is best-effort and must only call `/devices/register-token` when token changed for the current authenticated user context.
- Deep-link resolution from notification payload must stay centralized in `features/notifications/deeplink_mapper.dart`.
- Notification deep-link mapper should prefer explicit payload `route` when present, then fall back to `groupId`/`cycleId` mapping.
- Tapping a notification row must mark it as read first, then navigate when a resolvable deep link exists.
- Push delivery is optional; the app must keep notifications UX functional without Firebase by relying on in-app list and graceful fallback behavior.

## App lock rules
- Biometric app lock is device-level only and must not be treated as account-authentication replacement.
- Biometric lock preferences must be stored in secure storage using `biometric_enabled` and `lock_timeout_seconds`.
- App lock must require biometric authentication on cold start when enabled, and on resume after background elapsed time exceeds configured timeout.
- Lock screen must be a full-screen blocking overlay (no interaction with underlying routes until unlock succeeds).
- Bottom navigation must never appear on the lock screen.
- Lock screen must prevent back navigation while locked.

## Polish & Navigation rules
- Main app sections must live under shell navigation with bottom tabs (`/home`, `/groups`, `/settings`); logout action belongs in Settings.
- Use `context.push` for drill-down/detail routes and `context.go` only for root section switches or auth roots.
- In tabbed flows, use `go()` only for root tab switches (`/home`, `/groups`, `/settings`) and `push()` for in-tab drill-down routes.
- App bars must render an explicit back button (`leading: BackButton()`) when `context.canPop()` is true.
- Shared UI under `lib/shared/ui/` is the default for layout and repeated visuals (cards, list rows, badges, empty/loading feedback, snackbars).
- Standard content padding is `16` horizontal (`AppSpacing.md`); section spacing should stay within `12-16` (`AppSpacing.sm` to `AppSpacing.md`).
- Settings root (`/settings`) must act as a navigation hub (profile card + menu rows); section details should open on dedicated sub-routes instead of rendering all settings sections on one page.

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
