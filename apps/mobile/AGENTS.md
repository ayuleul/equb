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

## Theming rules
- Theme tokens in `lib/app/theme/` are the single source of truth for app styling.
- Do not hardcode colors in feature/shared UI files; use `Theme.of(context).colorScheme` or theme extensions.
- Spacing and corner radii must use `AppSpacing` and `AppRadius` tokens.

## Auth rules
- Token refresh is attempted at most once per failing request (`401`) before surfacing an auth error.
- Logout must call backend refresh-token revocation when refresh token exists, and must always clear secure storage locally.
- Never log access tokens or refresh tokens.
- Router redirects are locked to:
  - `unknown` auth state -> `/splash`
  - unauthenticated users -> `/login` for protected routes; `/otp` is allowed and must handle missing phone gracefully in-screen
  - authenticated users cannot navigate back to `/login` or `/otp`

## Groups rules
- Authenticated landing route is locked to `/home`.
- Group detail and members use repository-backed in-memory caches; manual refresh must invalidate cache and fetch fresh data.
- Member identity display fallback is locked to: `fullName` -> `phone` -> `'Member'`.

## Cycles rules
- Payout order positions are always saved as contiguous `1..N` after reorder; the UI order is the source of truth.
- Admin-only cycle actions (set payout order, generate cycles) must only be shown when `membership.role == ADMIN`.
- After cycle mutations (`setPayoutOrder`, `generateCycles`), invalidate cycle providers (`current`, `list`, relevant details) and members cache/providers before refetching.

## Uploads & contributions rules
- Signed proof uploads must use a separate Dio client with no auth interceptors; never upload proof files through authenticated API endpoints.
- The `Content-Type` used for signed upload request must exactly match the `Content-Type` sent in signed PUT upload.
- Contribution state transitions are backend-authoritative: submit/resubmit to `SUBMITTED`, admin confirm to `CONFIRMED`, admin reject to `REJECTED`; treat `CONFIRMED` as immutable.
- Resubmission UX should only be offered when contribution is not `CONFIRMED`, and primarily after `REJECTED` as permitted by backend rules.

## Payout rules
- Payout flow order is locked to: create payout -> confirm payout -> close cycle.
- Strict payout failures must show guidance to review cycle contributions before retrying confirmation.
- Closing a cycle must invalidate and refresh cycle detail, current cycle, cycles list, and cycle payout state.

## Notifications rules
- Device token registration is best-effort and must only call `/devices/register-token` when token changed for the current authenticated user context.
- Deep-link resolution from notification payload must stay centralized in `features/notifications/deeplink_mapper.dart`.
- Tapping a notification row must mark it as read first, then navigate when a resolvable deep link exists.
- Push delivery is optional; the app must keep notifications UX functional without Firebase by relying on in-app list and graceful fallback behavior.

## Polish & Navigation rules
- Main app sections must live under shell navigation with bottom tabs (`/home`, `/groups`, `/settings`); logout action belongs in Settings.
- Use `context.push` for drill-down/detail routes and `context.go` only for root section switches or auth roots.
- App bars must render an explicit back button (`leading: BackButton()`) when `context.canPop()` is true.
- Shared UI under `lib/shared/ui/` is the default for layout and repeated visuals (cards, list rows, badges, empty/loading feedback, snackbars).
- Standard content padding is `16` horizontal (`AppSpacing.md`); section spacing should stay within `12-16` (`AppSpacing.sm` to `AppSpacing.md`).

## Tab architecture rules
- Bottom tabs are implemented with `StatefulShellRoute.indexedStack` using separate navigator keys (`home`, `groups`, `settings`) so each tab preserves its own navigation stack.
- Notifications are not a tab; `/notifications` is a root overlay route (`parentNavigatorKey: root`) opened from app-bar bell actions.
- Notification/deeplink navigation into groups must use centralized helper flow: switch to `/groups` first, then push the target group route.

## DX commands
- Install deps: `flutter pub get`
- Codegen: `flutter pub run build_runner build --delete-conflicting-outputs`
- Analyze: `flutter analyze`
- Test: `flutter test`
