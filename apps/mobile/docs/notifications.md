# Notifications

## Overview
- In-app notifications are always available through `/notifications`.
- Push notifications are best-effort: if Firebase is not configured, the app still works with in-app notifications and API polling.

## API integration
- Device token registration: `POST /devices/register-token`
- List notifications: `GET /notifications?offset=<n>&limit=<n>&status=UNREAD|READ`
- Mark read: `PATCH /notifications/:id/read`

## Device token flow
- Token registration is triggered after auth success (OTP login and session restore).
- The app stores the last registered `(userId, token)` locally in secure storage and re-registers only when either value changes.

## Deep link mapping
- Mapping is centralized in `lib/features/notifications/deeplink_mapper.dart`.
- Rules:
  - `groupId + cycleId + contributionId` (or contribution type) -> contributions screen
  - `groupId + cycleId` -> cycle detail
  - `groupId` -> group detail

## Firebase setup (optional, for push)

### 1) Dependencies
- `firebase_core`
- `firebase_messaging`

### 2) Android
- Add `google-services.json` to `apps/mobile/android/app/google-services.json`.
- Add Google Services Gradle plugin if missing:
  - In `apps/mobile/android/settings.gradle.kts`:
    - `id("com.google.gms.google-services") version "<latest>" apply false`
  - In `apps/mobile/android/app/build.gradle.kts` plugins:
    - `id("com.google.gms.google-services")`
- Ensure Android 13+ notification permission is declared:
  - `android.permission.POST_NOTIFICATIONS` in `AndroidManifest.xml`.

### 3) iOS
- Add `GoogleService-Info.plist` to `apps/mobile/ios/Runner/GoogleService-Info.plist` and include it in the Xcode Runner target.
- Enable Push Notifications capability and Background Modes -> Remote notifications.

### 4) Runtime behavior
- On startup (after auth), the app initializes Firebase Messaging.
- Foreground push fallback: SnackBar is shown with title/body.
- Tap behavior (background/terminated): payload is mapped to in-app route and navigates there.

## Local testing

### Test in-app notifications only (no Firebase)
1. Login.
2. Open `/notifications`.
3. Trigger backend notifications (e.g. contribution submit/confirm/reject or payout confirm).
4. Pull to refresh and verify list + read state + navigation on tap.

### Test push with Firebase configured
1. Complete Firebase setup above.
2. Login once to register token (`POST /devices/register-token`).
3. Trigger a backend notification event.
4. Verify:
   - Foreground: SnackBar appears.
   - Background/terminated tap: app opens and navigates via deep link.

## Current fallback/TODO
- If Firebase init fails or is not configured, push listeners are skipped automatically.
- In-app notifications screen remains the source of truth in all environments.
