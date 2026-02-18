# Equb API Endpoints (Phases 1-6)

This document is generated from the current NestJS controllers/DTOs and matches the implemented routes.

## API Basics
- Base URL (local): `http://localhost:3000`
- Versioning: none (no `/v1` prefix configured)
- Swagger UI (dev): `http://localhost:3000/docs`
- OpenAPI JSON export file: `docs/openapi.json`

## Auth Model
- Access token: JWT bearer token (`Authorization: Bearer <accessToken>`), short TTL (`JWT_ACCESS_TTL`).
- Refresh token: JWT containing `tokenId`, stored hashed in DB.
- Refresh rotation: every `POST /auth/refresh` revokes current token and issues a new pair.
- Logout: `POST /auth/logout` revokes the refresh token if valid.

## Common Error Codes
- `400 Bad Request`: DTO validation or domain rule failure.
- `401 Unauthorized`: missing/invalid access token or invalid OTP/refresh token.
- `403 Forbidden`: authenticated but missing required membership/role.
- `404 Not Found`: resource not found (group/cycle/contribution/payout/notification/invite).

## Auth

### `POST /auth/request-otp`
- Description: Request OTP code for phone login.
- Auth: not required.
- Roles/Guards: none.
- Request:
```json
{ "phone": "+251911111111" }
```
- Response:
```json
{ "message": "OTP sent" }
```
- Common errors: `400` invalid phone, `429` rate limit.

### `POST /auth/verify-otp`
- Description: Verify OTP and return token pair + user.
- Auth: not required.
- Roles/Guards: none.
- Request:
```json
{ "phone": "+251911111111", "code": "123456" }
```
- Response:
```json
{
  "accessToken": "<jwt>",
  "refreshToken": "<jwt>",
  "user": {
    "id": "user_id",
    "phone": "+251911111111",
    "fullName": null
  }
}
```
- Common errors: `401` OTP invalid/expired/attempts exceeded, `429` rate limit.

### `POST /auth/refresh`
- Description: Rotate refresh token and issue a new token pair.
- Auth: not required (refresh token in body).
- Roles/Guards: none.
- Request:
```json
{ "refreshToken": "<jwt>" }
```
- Response:
```json
{
  "accessToken": "<jwt>",
  "refreshToken": "<jwt>",
  "user": {
    "id": "user_id",
    "phone": "+251911111111",
    "fullName": null
  }
}
```
- Common errors: `401` malformed/invalid/revoked refresh token.

### `POST /auth/logout`
- Description: Revoke refresh token.
- Auth: not required (refresh token in body).
- Roles/Guards: none.
- Request:
```json
{ "refreshToken": "<jwt>" }
```
- Response:
```json
{ "success": true }
```
- Common errors: typically none; returns success even for invalid token.

## Groups

### `POST /groups`
- Description: Create Equb group and creator membership (`ADMIN`, `ACTIVE`).
- Auth: required.
- Roles/Guards: `JwtAuthGuard`.
- Request:
```json
{
  "name": "Family Equb",
  "contributionAmount": 500,
  "frequency": "MONTHLY",
  "startDate": "2026-03-01",
  "currency": "ETB"
}
```
- Response:
```json
{
  "id": "group_uuid",
  "name": "Family Equb",
  "currency": "ETB",
  "contributionAmount": 500,
  "frequency": "MONTHLY",
  "startDate": "2026-03-01T00:00:00.000Z",
  "status": "ACTIVE",
  "createdByUserId": "user_id",
  "createdAt": "2026-02-18T00:00:00.000Z",
  "strictPayout": false,
  "timezone": "Africa/Addis_Ababa",
  "membership": { "role": "ADMIN", "status": "ACTIVE" }
}
```
- Common errors: `401`, `400` validation failure.

### `GET /groups`
- Description: List groups where current user is active member.
- Auth: required.
- Roles/Guards: `JwtAuthGuard`.
- Response:
```json
[
  {
    "id": "group_uuid",
    "name": "Family Equb",
    "currency": "ETB",
    "contributionAmount": 500,
    "frequency": "MONTHLY",
    "startDate": "2026-03-01T00:00:00.000Z",
    "status": "ACTIVE"
  }
]
```
- Common errors: `401`.

### `POST /groups/join`
- Description: Join group by invite code.
- Auth: required.
- Roles/Guards: `JwtAuthGuard`.
- Request:
```json
{ "code": "A1B2C3D4" }
```
- Response:
```json
{
  "groupId": "group_uuid",
  "role": "MEMBER",
  "status": "ACTIVE",
  "joinedAt": "2026-02-18T00:00:00.000Z"
}
```
- Common errors: `400` invite invalid/revoked/expired/limit reached, `403` removed member, `404` invite not found, `401`.

### `GET /groups/:id`
- Description: Get group details for current member.
- Auth: required.
- Roles/Guards: `JwtAuthGuard`, `GroupMemberGuard`.
- Response: same shape as `POST /groups` response.
- Common errors: `401`, `403`, `404`.

### `POST /groups/:id/invite`
- Description: Create invite code.
- Auth: required.
- Roles/Guards: `JwtAuthGuard`, `GroupAdminGuard`.
- Request:
```json
{ "expiresAt": "2026-04-01T00:00:00.000Z", "maxUses": 20 }
```
- Response:
```json
{ "code": "A1B2C3D4", "joinUrl": "http://localhost:3000/join?code=A1B2C3D4" }
```
- Common errors: `401`, `403`, `400`, `404`.

## Members

### `GET /groups/:id/members`
- Description: List group members and roles/status/payout order.
- Auth: required.
- Roles/Guards: `JwtAuthGuard`, `GroupMemberGuard`.
- Response:
```json
[
  {
    "user": {
      "id": "user_id",
      "phone": "+2519...",
      "fullName": "Member"
    },
    "role": "MEMBER",
    "status": "ACTIVE",
    "payoutPosition": 2,
    "joinedAt": "2026-02-18T00:00:00.000Z"
  }
]
```
- Common errors: `401`, `403`.

### `PATCH /groups/:id/members/:userId/role`
- Description: Update member role (`MEMBER`/`ADMIN`).
- Auth: required.
- Roles/Guards: `JwtAuthGuard`, `GroupAdminGuard`.
- Request:
```json
{ "role": "ADMIN" }
```
- Response: one `GroupMemberResponseDto` item.
- Common errors: `401`, `403`, `400` last-admin protection, `404` member not found.

### `PATCH /groups/:id/members/:userId/status`
- Description: Member self-leave (`LEFT`) or admin removal (`REMOVED`).
- Auth: required.
- Roles/Guards: `JwtAuthGuard` (role/state rules enforced in service).
- Request:
```json
{ "status": "LEFT" }
```
- Response: one `GroupMemberResponseDto` item.
- Common errors: `401`, `403`, `400`, `404`.

## Cycles

### `PATCH /groups/:id/payout-order`
- Description: Set payout order for all active members.
- Auth: required.
- Roles/Guards: `JwtAuthGuard`, `GroupAdminGuard`.
- Request:
```json
[
  { "userId": "user_a", "payoutPosition": 1 },
  { "userId": "user_b", "payoutPosition": 2 }
]
```
- Response: updated member list with payout positions.
- Common errors: `401`, `403`, `400` (non-contiguous/duplicates/incomplete).

### `POST /groups/:id/cycles/generate`
- Description: Generate next cycle(s), max 12.
- Auth: required.
- Roles/Guards: `JwtAuthGuard`, `GroupAdminGuard`.
- Request:
```json
{ "count": 1 }
```
- Response:
```json
[
  {
    "id": "cycle_uuid",
    "groupId": "group_uuid",
    "cycleNo": 1,
    "dueDate": "2026-03-01T00:00:00.000Z",
    "payoutUserId": "user_id",
    "status": "OPEN",
    "createdByUserId": "admin_id",
    "createdAt": "2026-02-18T00:00:00.000Z",
    "payoutUser": {
      "id": "user_id",
      "phone": "+2519...",
      "fullName": "Member"
    }
  }
]
```
- Common errors: `401`, `403`, `400` constraints not met, `404` group not found.

### `GET /groups/:id/cycles/current`
- Description: Get current open cycle or `null`.
- Auth: required.
- Roles/Guards: `JwtAuthGuard`, `GroupMemberGuard`.
- Response: `GroupCycleResponseDto` or `null`.
- Common errors: `401`, `403`.

### `GET /groups/:id/cycles/:cycleId`
- Description: Get one cycle by id.
- Auth: required.
- Roles/Guards: `JwtAuthGuard`, `GroupMemberGuard`.
- Response: `GroupCycleResponseDto`.
- Common errors: `401`, `403`, `404`.

### `GET /groups/:id/cycles`
- Description: List cycles for group.
- Auth: required.
- Roles/Guards: `JwtAuthGuard`, `GroupMemberGuard`.
- Response: array of `GroupCycleResponseDto`.
- Common errors: `401`, `403`.

## Contributions

### `POST /cycles/:cycleId/contributions`
- Description: Submit or resubmit contribution for open cycle.
- Auth: required.
- Roles/Guards: `JwtAuthGuard` (active membership checks in service).
- Request:
```json
{
  "amount": 500,
  "proofFileKey": "groups/<groupId>/cycles/<cycleId>/users/<userId>/uuid_receipt.jpg",
  "paymentRef": "tx-001",
  "note": "bank transfer"
}
```
- Response: `ContributionResponseDto` with status `SUBMITTED`.
- Common errors: `401`, `403`, `400` cycle/proof/state violations, `404` cycle not found.

### `PATCH /contributions/:id/confirm`
- Description: Confirm submitted contribution.
- Auth: required.
- Roles/Guards: `JwtAuthGuard`, `GroupAdminGuard`.
- Request:
```json
{ "note": "verified" }
```
- Response: `ContributionResponseDto` with status `CONFIRMED`.
- Common errors: `401`, `403`, `400`, `404`.

### `PATCH /contributions/:id/reject`
- Description: Reject submitted contribution.
- Auth: required.
- Roles/Guards: `JwtAuthGuard`, `GroupAdminGuard`.
- Request:
```json
{ "reason": "Invalid proof" }
```
- Response: `ContributionResponseDto` with status `REJECTED`.
- Common errors: `401`, `403`, `400`, `404`.

### `GET /groups/:id/cycles/:cycleId/contributions`
- Description: List cycle contributions and summary counts.
- Auth: required.
- Roles/Guards: `JwtAuthGuard`, `GroupMemberGuard`.
- Response:
```json
{
  "items": [
    {
      "id": "contribution_uuid",
      "groupId": "group_uuid",
      "cycleId": "cycle_uuid",
      "userId": "user_id",
      "amount": 500,
      "status": "SUBMITTED",
      "proofFileKey": "groups/...",
      "paymentRef": "tx-001",
      "note": null,
      "submittedAt": "2026-02-18T00:00:00.000Z",
      "confirmedAt": null,
      "rejectedAt": null,
      "rejectReason": null,
      "createdAt": "2026-02-18T00:00:00.000Z",
      "user": {
        "id": "user_id",
        "fullName": "Member",
        "phone": null
      }
    }
  ],
  "summary": {
    "total": 1,
    "pending": 0,
    "submitted": 1,
    "confirmed": 0,
    "rejected": 0
  }
}
```
- Common errors: `401`, `403`, `404`.

## Payouts

### `POST /cycles/:cycleId/payout`
- Description: Create pending payout for cycle payout user.
- Auth: required.
- Roles/Guards: `JwtAuthGuard`, `GroupAdminGuard`.
- Request:
```json
{
  "amount": 500,
  "proofFileKey": "groups/<groupId>/cycles/<cycleId>/payouts/uuid_proof.jpg",
  "paymentRef": "payout-001",
  "note": "cash"
}
```
- Response: `PayoutResponseDto` with status `PENDING`.
- Common errors: `401`, `403`, `400`, `404`.

### `PATCH /payouts/:id/confirm`
- Description: Confirm pending payout (strict/non-strict group rules).
- Auth: required.
- Roles/Guards: `JwtAuthGuard`, `GroupAdminGuard`.
- Request:
```json
{ "paymentRef": "payout-001", "note": "confirmed" }
```
- Response: `PayoutResponseDto` with status `CONFIRMED`.
- Common errors: `401`, `403`, `400` strict checks/state violations, `404`.

### `POST /cycles/:cycleId/close`
- Description: Close open cycle after payout confirmed.
- Auth: required.
- Roles/Guards: `JwtAuthGuard`, `GroupAdminGuard`.
- Request: none.
- Response:
```json
{ "success": true }
```
- Common errors: `401`, `403`, `400`, `404`.

### `GET /cycles/:cycleId/payout`
- Description: Get payout for cycle (`null` if not created yet).
- Auth: required.
- Roles/Guards: `JwtAuthGuard`, `GroupMemberGuard`.
- Response: `PayoutResponseDto` or `null`.
- Common errors: `401`, `403`, `404`.

## Files

### `POST /files/signed-upload`
- Description: Create signed S3/MinIO upload URL.
- Auth: required.
- Roles/Guards: `JwtAuthGuard` (+ membership/admin checks in service by purpose).
- Request:
```json
{
  "purpose": "contribution_proof",
  "groupId": "group_uuid",
  "cycleId": "cycle_uuid",
  "contentType": "image/jpeg",
  "fileName": "receipt.jpg"
}
```
- Response:
```json
{
  "key": "groups/<groupId>/cycles/<cycleId>/users/<userId>/uuid_receipt.jpg",
  "uploadUrl": "https://...",
  "expiresInSeconds": 900
}
```
- Common errors: `401`, `403`, `400`, `404`.

### `GET /files/signed-download?key=...`
- Description: Create signed S3/MinIO download URL for scoped key.
- Auth: required.
- Roles/Guards: `JwtAuthGuard` (+ membership checks in service).
- Response:
```json
{
  "downloadUrl": "https://...",
  "expiresInSeconds": 900
}
```
- Common errors: `401`, `403`, `400` invalid key format.

## Devices

### `POST /devices/register-token`
- Description: Upsert user device token for push delivery.
- Auth: required.
- Roles/Guards: `JwtAuthGuard`.
- Request:
```json
{ "token": "fcm_device_token", "platform": "ANDROID" }
```
- Response:
```json
{
  "id": "device_uuid",
  "userId": "user_id",
  "token": "fcm_device_token",
  "platform": "ANDROID",
  "isActive": true,
  "lastSeenAt": "2026-02-18T00:00:00.000Z",
  "createdAt": "2026-02-18T00:00:00.000Z"
}
```
- Common errors: `401`, `400` payload validation.

## Notifications

### `GET /notifications`
- Description: List current user notifications with offset/limit and optional status filter.
- Auth: required.
- Roles/Guards: `JwtAuthGuard`.
- Query params:
- `status` (`UNREAD|READ`, optional)
- `offset` (default `0`)
- `limit` (default `20`, max `100`)
- Response:
```json
{
  "items": [
    {
      "id": "notification_uuid",
      "userId": "user_id",
      "groupId": "group_uuid",
      "type": "DUE_REMINDER",
      "title": "Contribution due reminder",
      "body": "Your contribution is due.",
      "dataJson": { "groupId": "group_uuid", "cycleId": "cycle_uuid" },
      "status": "UNREAD",
      "createdAt": "2026-02-18T00:00:00.000Z",
      "readAt": null
    }
  ],
  "total": 1,
  "offset": 0,
  "limit": 20
}
```
- Common errors: `401`, `400` invalid pagination/filter.

### `PATCH /notifications/:id/read`
- Description: Mark notification as read for the owner.
- Auth: required.
- Roles/Guards: `JwtAuthGuard`.
- Request: none.
- Response: one `NotificationResponseDto` item with `status: "READ"`.
- Common errors: `401`, `403` non-owner, `404` not found.

## System

### `GET /health`
- Description: Liveness/readiness check for DB and Redis.
- Auth: not required.
- Roles/Guards: none.
- Response:
```json
{
  "status": "ok",
  "checks": {
    "database": "up",
    "redis": "up"
  },
  "timestamp": "2026-02-18T00:00:00.000Z"
}
```
- Common errors: usually none; degraded status is returned in payload.

## Typical Flows

### 1) Create group -> invite -> join
1. `POST /groups` (creator becomes `ADMIN` + `ACTIVE`).
2. `POST /groups/:id/invite` to generate code.
3. `POST /groups/join` with invite code.
4. Optional: `GET /groups/:id/members` to verify membership.

### 2) Set payout order -> generate cycle
1. `PATCH /groups/:id/payout-order` with contiguous positions (`1..N`).
2. `POST /groups/:id/cycles/generate`.
3. `GET /groups/:id/cycles/current` to inspect open cycle.

### 3) Submit contribution -> confirm/reject
1. Optional upload key: `POST /files/signed-upload` (`contribution_proof`).
2. `POST /cycles/:cycleId/contributions` by member.
3. `PATCH /contributions/:id/confirm` or `PATCH /contributions/:id/reject` by admin.
4. `GET /groups/:id/cycles/:cycleId/contributions` for summary.

### 4) Create payout -> confirm -> close cycle
1. Optional upload key: `POST /files/signed-upload` (`payout_proof`).
2. `POST /cycles/:cycleId/payout` by admin.
3. `PATCH /payouts/:id/confirm` by admin.
4. `POST /cycles/:cycleId/close` by admin.

### 5) Register device token -> notifications lifecycle
1. `POST /devices/register-token`.
2. Trigger domain events (join/contribution/payout/reminder).
3. `GET /notifications` to fetch in-app notifications.
4. `PATCH /notifications/:id/read` to mark as read.

## How to Run Locally
1. Start dependencies:
```bash
docker compose up -d
```
2. Configure env:
```bash
cp apps/api/.env.example apps/api/.env
```
If API runs on host, use `localhost` hosts in `.env` (`DATABASE_URL`, `REDIS_URL`, `S3_ENDPOINT`).

3. Run migrations:
```bash
cd apps/api
npx prisma migrate dev
```

4. Start API:
```bash
npm run start:dev
```

5. Open Swagger:
- `http://localhost:3000/docs`

## OpenAPI Export
- Command:
```bash
npm --prefix apps/api run openapi:export
```
- Output file:
- `docs/openapi.json`

The export script boots the Nest app module and writes OpenAPI JSON directly from Swagger decorators/DTO schemas.
