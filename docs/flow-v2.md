# Flow V2 (Canonical)

## Overview
This document defines the only supported Equb flow in V2:

1. Create group
2. Configure ruleset (required)
3. Invite and verify members (required for verification-enabled groups)
4. Start cycle (creates due contributions)
5. Members submit contributions with receipt metadata and ledger writes
6. Admin verifies contributions
7. Evaluate collection and late/fine/dispute loop
8. Select winner
9. Disburse payout
10. Close cycle (optional auto-next)

Legacy round/schedule/payout-order generation is retired.

## Gates

### Gate 1: Ruleset
- `Group.rulesetConfigured` must be `true` before invite acceptance/join flow and cycle start.
- Group payload computed flags:
  - `rulesetConfigured`
  - `canInviteMembers`
  - `canStartCycle`

### Gate 2: Invite & Verify
- Member statuses: `INVITED | JOINED | VERIFIED | SUSPENDED`
- If `requiresMemberVerification = true`, only `VERIFIED` members are cycle-eligible.
- Minimum eligible members to start cycle: `>= 2`

### Lock rule
- Join/accept-invite is blocked while a cycle is open.
- Conflict reason code: `GROUP_LOCKED_OPEN_CYCLE`.

## Cycle State Machine
`DUE -> COLLECTING -> READY_FOR_PAYOUT -> DISBURSED -> CLOSED`

Rules:
- Start cycle creates due contribution rows (`PENDING`) for all eligible members.
- `strictCollection = true`: transition to `READY_FOR_PAYOUT` requires all eligible contributions verified.
- `strictCollection = false`: `READY_FOR_PAYOUT` can be reached when at least one contribution is verified.
- Late evaluation uses `dueAt + graceDays`; overdue non-verified contributions become `LATE`.

## Winner Selection and Payout
Winner mode comes from ruleset `payoutMode`:
- `LOTTERY`: per-cycle random draw
- `AUCTION`: highest bid wins, tie by earliest `createdAt`
- `ROTATION`: next eligible rotation member
- `DECISION`: admin-provided `userId`

Persisted winner fields on cycle:
- `selectedWinnerUserId`
- `selectionMethod`
- `selectionMetadata`

Disbursement:
- Creates/updates payout
- Writes payout ledger entry
- Moves cycle to `DISBURSED`

Close:
- `POST /cycles/:cycleId/close`
- Optional `autoNext` creates next cycle in `DUE`

## Endpoints (V2)

### Groups / Setup
- `POST /groups`
- `GET /groups`
- `GET /groups/:id`
- `GET /groups/:id/rules`
- `PUT /groups/:id/rules`

### Members / Invites
- `POST /groups/:id/invites`
- `POST /groups/:id/invites/:code/accept`
- `POST /groups/join`
- `GET /groups/:id/members`
- `POST /groups/:id/members/:memberId/verify`

### Cycles
- `POST /groups/:id/cycles/start`
- `GET /groups/:id/cycles/current`
- `GET /groups/:id/cycles`
- `GET /groups/:id/cycles/:cycleId`
- `POST /cycles/:cycleId/evaluate`

### Contributions / Receipts / Disputes
- `POST /cycles/:cycleId/contributions/submit`
- `POST /contributions/:id/verify`
- `POST /contributions/:id/reject`
- `GET /groups/:id/cycles/:cycleId/contributions`
- `POST /contributions/:id/disputes`
- `POST /disputes/:id/mediate`
- `POST /disputes/:id/resolve`

### Winner / Payout / Close
- `POST /cycles/:cycleId/winner/select`
- `POST /cycles/:cycleId/payout/disburse`
- `POST /cycles/:cycleId/close`

## Removed Legacy Surface
- `PATCH /groups/:id/payout-order`
- `POST /groups/:id/rounds/start`
- `GET /groups/:id/rounds/current/schedule`
- `POST /groups/:id/rounds/current/reveal-seed`
- `POST /groups/:id/rounds/current/draw-next`
- Batch cycle generation routes
