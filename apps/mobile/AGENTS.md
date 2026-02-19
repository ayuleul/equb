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
- `lib/data/api/`
  - `api_client.dart`, `auth_interceptor.dart`, `token_store.dart`, `api_error.dart`
- `lib/data/models/`
- `lib/features/<feature>/`
- `lib/shared/widgets/`
- `lib/shared/utils/`

## UI quality baseline
- Every screen should provide loading and error states.
- Reuse shared widgets for buttons, text fields, loading, and error views.
- Keep visuals minimal and clear; prioritize stable flow over complex design.

## DX commands
- Install deps: `flutter pub get`
- Codegen: `flutter pub run build_runner build --delete-conflicting-outputs`
- Analyze: `flutter analyze`
- Test: `flutter test`
