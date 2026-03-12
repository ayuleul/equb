-- CreateEnum
CREATE TYPE "public"."GroupFrequency" AS ENUM ('WEEKLY', 'MONTHLY');

-- CreateEnum
CREATE TYPE "public"."GroupRuleFrequency" AS ENUM ('WEEKLY', 'MONTHLY', 'CUSTOM_INTERVAL');

-- CreateEnum
CREATE TYPE "public"."GroupRuleFineType" AS ENUM ('NONE', 'FIXED_AMOUNT');

-- CreateEnum
CREATE TYPE "public"."GroupRulePayoutMode" AS ENUM ('LOTTERY', 'AUCTION', 'ROTATION', 'DECISION');

-- CreateEnum
CREATE TYPE "public"."WinnerSelectionTiming" AS ENUM ('BEFORE_COLLECTION', 'AFTER_COLLECTION');

-- CreateEnum
CREATE TYPE "public"."GroupPaymentMethod" AS ENUM ('BANK', 'TELEBIRR', 'CASH_ACK');

-- CreateEnum
CREATE TYPE "public"."StartPolicy" AS ENUM ('WHEN_FULL', 'ON_DATE', 'MANUAL');

-- CreateEnum
CREATE TYPE "public"."GroupStatus" AS ENUM ('ACTIVE', 'ARCHIVED');

-- CreateEnum
CREATE TYPE "public"."GroupVisibility" AS ENUM ('PRIVATE', 'PUBLIC');

-- CreateEnum
CREATE TYPE "public"."MemberRole" AS ENUM ('ADMIN', 'MEMBER');

-- CreateEnum
CREATE TYPE "public"."MemberStatus" AS ENUM ('INVITED', 'JOINED', 'VERIFIED', 'SUSPENDED', 'ACTIVE', 'LEFT', 'REMOVED');

-- CreateEnum
CREATE TYPE "public"."CycleStatus" AS ENUM ('OPEN', 'CLOSED');

-- CreateEnum
CREATE TYPE "public"."CycleState" AS ENUM ('SETUP', 'COLLECTING', 'READY_FOR_WINNER_SELECTION', 'READY_FOR_PAYOUT', 'PAYOUT_SENT', 'COMPLETED');

-- CreateEnum
CREATE TYPE "public"."PayoutMode" AS ENUM ('RANDOM_DRAW');

-- CreateEnum
CREATE TYPE "public"."AuctionStatus" AS ENUM ('NONE', 'OPEN', 'CLOSED');

-- CreateEnum
CREATE TYPE "public"."ContributionStatus" AS ENUM ('PENDING', 'LATE', 'PAID_SUBMITTED', 'VERIFIED', 'SUBMITTED', 'CONFIRMED', 'REJECTED');

-- CreateEnum
CREATE TYPE "public"."PayoutStatus" AS ENUM ('PENDING', 'CONFIRMED');

-- CreateEnum
CREATE TYPE "public"."LedgerEntryType" AS ENUM ('MEMBER_PAYMENT', 'CONTRIBUTION_VERIFIED', 'PAYOUT_DISBURSED', 'LATE_FINE');

-- CreateEnum
CREATE TYPE "public"."DisputeStatus" AS ENUM ('OPEN', 'MEDIATING', 'RESOLVED');

-- CreateEnum
CREATE TYPE "public"."JoinRequestStatus" AS ENUM ('REQUESTED', 'APPROVED', 'REJECTED', 'WITHDRAWN');

-- CreateEnum
CREATE TYPE "public"."Platform" AS ENUM ('IOS', 'ANDROID', 'WEB');

-- CreateEnum
CREATE TYPE "public"."NotificationType" AS ENUM ('MEMBER_JOINED', 'CONTRIBUTION_SUBMITTED', 'CONTRIBUTION_CONFIRMED', 'CONTRIBUTION_REJECTED', 'CONTRIBUTION_LATE', 'DISPUTE_OPENED', 'DISPUTE_MEDIATING', 'DISPUTE_RESOLVED', 'PAYOUT_CONFIRMED', 'DUE_REMINDER', 'LOTTERY_WINNER', 'LOTTERY_ANNOUNCEMENT', 'PAYOUT_SENT', 'TURN_COMPLETED');

-- CreateEnum
CREATE TYPE "public"."NotificationStatus" AS ENUM ('UNREAD', 'READ');

-- CreateTable
CREATE TABLE "public"."User" (
    "id" TEXT NOT NULL,
    "phone" TEXT NOT NULL,
    "firstName" TEXT,
    "middleName" TEXT,
    "lastName" TEXT,
    "fullName" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "User_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "public"."OtpCode" (
    "id" TEXT NOT NULL,
    "phone" TEXT NOT NULL,
    "codeHash" TEXT NOT NULL,
    "expiresAt" TIMESTAMP(3) NOT NULL,
    "attempts" INTEGER NOT NULL DEFAULT 0,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "OtpCode_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "public"."RefreshToken" (
    "id" TEXT NOT NULL,
    "userId" TEXT NOT NULL,
    "tokenHash" TEXT NOT NULL,
    "expiresAt" TIMESTAMP(3) NOT NULL,
    "revokedAt" TIMESTAMP(3),
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "RefreshToken_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "public"."EqubGroup" (
    "id" TEXT NOT NULL,
    "name" TEXT NOT NULL,
    "description" TEXT,
    "currency" TEXT NOT NULL DEFAULT 'ETB',
    "contributionAmount" INTEGER NOT NULL,
    "frequency" "public"."GroupFrequency" NOT NULL,
    "startDate" DATE NOT NULL,
    "status" "public"."GroupStatus" NOT NULL DEFAULT 'ACTIVE',
    "visibility" "public"."GroupVisibility" NOT NULL DEFAULT 'PRIVATE',
    "strictPayout" BOOLEAN NOT NULL DEFAULT false,
    "timezone" TEXT NOT NULL DEFAULT 'Africa/Addis_Ababa',
    "createdByUserId" TEXT NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "EqubGroup_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "public"."JoinRequest" (
    "id" TEXT NOT NULL,
    "groupId" TEXT NOT NULL,
    "userId" TEXT NOT NULL,
    "status" "public"."JoinRequestStatus" NOT NULL DEFAULT 'REQUESTED',
    "message" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "reviewedAt" TIMESTAMP(3),
    "reviewedByUserId" TEXT,

    CONSTRAINT "JoinRequest_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "public"."GroupRules" (
    "groupId" TEXT NOT NULL,
    "contributionAmount" INTEGER NOT NULL,
    "frequency" "public"."GroupRuleFrequency" NOT NULL,
    "customIntervalDays" INTEGER,
    "roundSize" INTEGER NOT NULL,
    "startPolicy" "public"."StartPolicy" NOT NULL DEFAULT 'WHEN_FULL',
    "startAt" TIMESTAMP(3),
    "minToStart" INTEGER,
    "graceDays" INTEGER NOT NULL DEFAULT 0,
    "fineType" "public"."GroupRuleFineType" NOT NULL DEFAULT 'NONE',
    "fineAmount" INTEGER NOT NULL DEFAULT 0,
    "payoutMode" "public"."GroupRulePayoutMode" NOT NULL,
    "winnerSelectionTiming" "public"."WinnerSelectionTiming" NOT NULL DEFAULT 'BEFORE_COLLECTION',
    "paymentMethods" "public"."GroupPaymentMethod"[],
    "requiresMemberVerification" BOOLEAN NOT NULL DEFAULT false,
    "strictCollection" BOOLEAN NOT NULL DEFAULT false,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "GroupRules_pkey" PRIMARY KEY ("groupId")
);

-- CreateTable
CREATE TABLE "public"."EqubMember" (
    "id" TEXT NOT NULL,
    "groupId" TEXT NOT NULL,
    "userId" TEXT NOT NULL,
    "role" "public"."MemberRole" NOT NULL DEFAULT 'MEMBER',
    "status" "public"."MemberStatus" NOT NULL DEFAULT 'INVITED',
    "payoutPosition" INTEGER,
    "joinedAt" TIMESTAMP(3),
    "verifiedAt" TIMESTAMP(3),
    "verifiedByUserId" TEXT,
    "guarantorUserId" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "EqubMember_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "public"."EqubRound" (
    "id" TEXT NOT NULL,
    "groupId" TEXT NOT NULL,
    "roundNo" INTEGER NOT NULL,
    "payoutMode" "public"."PayoutMode" NOT NULL DEFAULT 'RANDOM_DRAW',
    "drawSeedHash" TEXT NOT NULL,
    "drawSeedCiphertext" TEXT,
    "drawSeedRevealedAt" TIMESTAMP(3),
    "drawSeedRevealedByUserId" TEXT,
    "startedByUserId" TEXT NOT NULL,
    "startedAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "closedAt" TIMESTAMP(3),

    CONSTRAINT "EqubRound_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "public"."PayoutSchedule" (
    "roundId" TEXT NOT NULL,
    "position" INTEGER NOT NULL,
    "userId" TEXT NOT NULL,

    CONSTRAINT "PayoutSchedule_pkey" PRIMARY KEY ("roundId","position")
);

-- CreateTable
CREATE TABLE "public"."InviteCode" (
    "id" TEXT NOT NULL,
    "groupId" TEXT NOT NULL,
    "code" TEXT NOT NULL,
    "createdByUserId" TEXT NOT NULL,
    "expiresAt" TIMESTAMP(3),
    "maxUses" INTEGER,
    "usedCount" INTEGER NOT NULL DEFAULT 0,
    "isRevoked" BOOLEAN NOT NULL DEFAULT false,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "InviteCode_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "public"."EqubCycle" (
    "id" TEXT NOT NULL,
    "groupId" TEXT NOT NULL,
    "roundId" TEXT NOT NULL,
    "cycleNo" INTEGER NOT NULL,
    "dueDate" DATE NOT NULL,
    "dueAt" DATE NOT NULL,
    "state" "public"."CycleState" NOT NULL DEFAULT 'SETUP',
    "scheduledPayoutUserId" TEXT NOT NULL,
    "finalPayoutUserId" TEXT NOT NULL,
    "selectedWinnerUserId" TEXT,
    "winnerSelectedAt" TIMESTAMP(3),
    "selectionMethod" "public"."GroupRulePayoutMode",
    "selectionMetadata" JSONB,
    "auctionStatus" "public"."AuctionStatus" NOT NULL DEFAULT 'NONE',
    "winningBidAmount" INTEGER,
    "winningBidUserId" TEXT,
    "status" "public"."CycleStatus" NOT NULL DEFAULT 'OPEN',
    "contributionsConfirmedCount" INTEGER NOT NULL DEFAULT 0,
    "contributionsSubmittedCount" INTEGER NOT NULL DEFAULT 0,
    "payoutSentAt" TIMESTAMP(3),
    "payoutSentByUserId" TEXT,
    "payoutReceivedConfirmedAt" TIMESTAMP(3),
    "payoutReceivedConfirmedByUserId" TEXT,
    "closedAt" TIMESTAMP(3),
    "closedByUserId" TEXT,
    "createdByUserId" TEXT NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "EqubCycle_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "public"."UserReputationMetrics" (
    "userId" TEXT NOT NULL,
    "trustScore" INTEGER NOT NULL DEFAULT 50,
    "trustLevel" TEXT NOT NULL DEFAULT 'New',
    "paymentScore" DOUBLE PRECISION NOT NULL DEFAULT 50,
    "completionScore" DOUBLE PRECISION NOT NULL DEFAULT 50,
    "behaviorScore" DOUBLE PRECISION NOT NULL DEFAULT 100,
    "experienceScore" DOUBLE PRECISION NOT NULL DEFAULT 0,
    "baseScore" DOUBLE PRECISION NOT NULL DEFAULT 55,
    "activityFactor" DOUBLE PRECISION NOT NULL DEFAULT 1,
    "adjustedScore" DOUBLE PRECISION NOT NULL DEFAULT 55,
    "confidenceFactor" DOUBLE PRECISION NOT NULL DEFAULT 0,
    "equbsJoined" INTEGER NOT NULL DEFAULT 0,
    "equbsCompleted" INTEGER NOT NULL DEFAULT 0,
    "equbsLeftEarly" INTEGER NOT NULL DEFAULT 0,
    "equbsHosted" INTEGER NOT NULL DEFAULT 0,
    "hostedEqubsCompleted" INTEGER NOT NULL DEFAULT 0,
    "onTimePayments" INTEGER NOT NULL DEFAULT 0,
    "latePayments" INTEGER NOT NULL DEFAULT 0,
    "missedPayments" INTEGER NOT NULL DEFAULT 0,
    "turnsParticipated" INTEGER NOT NULL DEFAULT 0,
    "payoutsReceived" INTEGER NOT NULL DEFAULT 0,
    "payoutsConfirmed" INTEGER NOT NULL DEFAULT 0,
    "removalsCount" INTEGER NOT NULL DEFAULT 0,
    "disputesCount" INTEGER NOT NULL DEFAULT 0,
    "cancelledGroupsCount" INTEGER NOT NULL DEFAULT 0,
    "hostDisputesCount" INTEGER NOT NULL DEFAULT 0,
    "lastEqubActivityAt" TIMESTAMP(3),
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "UserReputationMetrics_pkey" PRIMARY KEY ("userId")
);

-- CreateTable
CREATE TABLE "public"."ReputationHistory" (
    "id" TEXT NOT NULL,
    "userId" TEXT NOT NULL,
    "eventType" TEXT NOT NULL,
    "scoreDelta" INTEGER NOT NULL,
    "metricChanges" JSONB NOT NULL,
    "relatedGroupId" TEXT,
    "relatedCycleId" TEXT,
    "idempotencyKey" TEXT NOT NULL,
    "metadata" JSONB,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "ReputationHistory_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "public"."CycleAuction" (
    "id" TEXT NOT NULL,
    "cycleId" TEXT NOT NULL,
    "openedByUserId" TEXT NOT NULL,
    "status" "public"."AuctionStatus" NOT NULL,
    "openedAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "closedAt" TIMESTAMP(3),

    CONSTRAINT "CycleAuction_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "public"."CycleBid" (
    "id" TEXT NOT NULL,
    "cycleId" TEXT NOT NULL,
    "userId" TEXT NOT NULL,
    "amount" INTEGER NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "CycleBid_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "public"."Contribution" (
    "id" TEXT NOT NULL,
    "groupId" TEXT NOT NULL,
    "cycleId" TEXT NOT NULL,
    "userId" TEXT NOT NULL,
    "amount" INTEGER NOT NULL,
    "status" "public"."ContributionStatus" NOT NULL DEFAULT 'PENDING',
    "paymentMethod" "public"."GroupPaymentMethod",
    "proofFileKey" TEXT,
    "paymentRef" TEXT,
    "note" TEXT,
    "submittedAt" TIMESTAMP(3),
    "confirmedByUserId" TEXT,
    "confirmedAt" TIMESTAMP(3),
    "rejectedByUserId" TEXT,
    "rejectedAt" TIMESTAMP(3),
    "rejectReason" TEXT,
    "lateMarkedAt" TIMESTAMP(3),
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "Contribution_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "public"."ContributionDispute" (
    "id" TEXT NOT NULL,
    "groupId" TEXT NOT NULL,
    "cycleId" TEXT NOT NULL,
    "contributionId" TEXT NOT NULL,
    "reportedByUserId" TEXT NOT NULL,
    "status" "public"."DisputeStatus" NOT NULL DEFAULT 'OPEN',
    "reason" TEXT NOT NULL,
    "note" TEXT,
    "mediationNote" TEXT,
    "mediatedAt" TIMESTAMP(3),
    "mediatedByUserId" TEXT,
    "resolutionOutcome" TEXT,
    "resolutionNote" TEXT,
    "resolvedAt" TIMESTAMP(3),
    "resolvedByUserId" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "ContributionDispute_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "public"."ContributionReceipt" (
    "id" TEXT NOT NULL,
    "groupId" TEXT NOT NULL,
    "cycleId" TEXT NOT NULL,
    "contributionId" TEXT NOT NULL,
    "userId" TEXT NOT NULL,
    "method" "public"."GroupPaymentMethod" NOT NULL,
    "reference" TEXT,
    "receiptFileKey" TEXT,
    "note" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "ContributionReceipt_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "public"."Payout" (
    "id" TEXT NOT NULL,
    "groupId" TEXT NOT NULL,
    "cycleId" TEXT NOT NULL,
    "toUserId" TEXT NOT NULL,
    "amount" INTEGER NOT NULL,
    "status" "public"."PayoutStatus" NOT NULL DEFAULT 'PENDING',
    "proofFileKey" TEXT,
    "paymentRef" TEXT,
    "note" TEXT,
    "metadata" JSONB,
    "createdByUserId" TEXT NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "confirmedByUserId" TEXT,
    "confirmedAt" TIMESTAMP(3),

    CONSTRAINT "Payout_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "public"."LedgerEntry" (
    "id" TEXT NOT NULL,
    "groupId" TEXT NOT NULL,
    "cycleId" TEXT,
    "contributionId" TEXT,
    "payoutId" TEXT,
    "userId" TEXT NOT NULL,
    "type" "public"."LedgerEntryType" NOT NULL,
    "amount" INTEGER NOT NULL,
    "method" "public"."GroupPaymentMethod",
    "reference" TEXT,
    "receiptFileKey" TEXT,
    "note" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "confirmedAt" TIMESTAMP(3),
    "confirmedByUserId" TEXT,

    CONSTRAINT "LedgerEntry_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "public"."AuditLog" (
    "id" TEXT NOT NULL,
    "groupId" TEXT,
    "action" TEXT NOT NULL,
    "actorUserId" TEXT,
    "metadata" JSONB,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "AuditLog_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "public"."DeviceToken" (
    "id" TEXT NOT NULL,
    "userId" TEXT NOT NULL,
    "token" TEXT NOT NULL,
    "platform" "public"."Platform" NOT NULL,
    "isActive" BOOLEAN NOT NULL DEFAULT true,
    "lastSeenAt" TIMESTAMP(3) NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "DeviceToken_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "public"."Notification" (
    "id" TEXT NOT NULL,
    "userId" TEXT NOT NULL,
    "groupId" TEXT,
    "eventId" TEXT,
    "type" "public"."NotificationType" NOT NULL,
    "title" TEXT NOT NULL,
    "body" TEXT NOT NULL,
    "dataJson" JSONB,
    "status" "public"."NotificationStatus" NOT NULL DEFAULT 'UNREAD',
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "readAt" TIMESTAMP(3),

    CONSTRAINT "Notification_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE UNIQUE INDEX "User_phone_key" ON "public"."User"("phone");

-- CreateIndex
CREATE INDEX "OtpCode_phone_createdAt_idx" ON "public"."OtpCode"("phone", "createdAt" DESC);

-- CreateIndex
CREATE INDEX "RefreshToken_userId_idx" ON "public"."RefreshToken"("userId");

-- CreateIndex
CREATE INDEX "EqubGroup_createdByUserId_idx" ON "public"."EqubGroup"("createdByUserId");

-- CreateIndex
CREATE INDEX "EqubGroup_visibility_status_idx" ON "public"."EqubGroup"("visibility", "status");

-- CreateIndex
CREATE INDEX "JoinRequest_groupId_status_createdAt_idx" ON "public"."JoinRequest"("groupId", "status", "createdAt" DESC);

-- CreateIndex
CREATE INDEX "JoinRequest_userId_status_createdAt_idx" ON "public"."JoinRequest"("userId", "status", "createdAt" DESC);

-- CreateIndex
CREATE INDEX "EqubMember_userId_idx" ON "public"."EqubMember"("userId");

-- CreateIndex
CREATE INDEX "EqubMember_verifiedByUserId_idx" ON "public"."EqubMember"("verifiedByUserId");

-- CreateIndex
CREATE INDEX "EqubMember_guarantorUserId_idx" ON "public"."EqubMember"("guarantorUserId");

-- CreateIndex
CREATE INDEX "EqubMember_groupId_status_role_idx" ON "public"."EqubMember"("groupId", "status", "role");

-- CreateIndex
CREATE UNIQUE INDEX "EqubMember_groupId_userId_key" ON "public"."EqubMember"("groupId", "userId");

-- CreateIndex
CREATE INDEX "EqubRound_groupId_closedAt_idx" ON "public"."EqubRound"("groupId", "closedAt");

-- CreateIndex
CREATE INDEX "EqubRound_drawSeedRevealedByUserId_idx" ON "public"."EqubRound"("drawSeedRevealedByUserId");

-- CreateIndex
CREATE UNIQUE INDEX "EqubRound_groupId_roundNo_key" ON "public"."EqubRound"("groupId", "roundNo");

-- CreateIndex
CREATE INDEX "PayoutSchedule_userId_idx" ON "public"."PayoutSchedule"("userId");

-- CreateIndex
CREATE UNIQUE INDEX "PayoutSchedule_roundId_userId_key" ON "public"."PayoutSchedule"("roundId", "userId");

-- CreateIndex
CREATE UNIQUE INDEX "InviteCode_code_key" ON "public"."InviteCode"("code");

-- CreateIndex
CREATE INDEX "InviteCode_groupId_idx" ON "public"."InviteCode"("groupId");

-- CreateIndex
CREATE INDEX "EqubCycle_groupId_status_idx" ON "public"."EqubCycle"("groupId", "status");

-- CreateIndex
CREATE INDEX "EqubCycle_groupId_roundId_idx" ON "public"."EqubCycle"("groupId", "roundId");

-- CreateIndex
CREATE INDEX "EqubCycle_selectedWinnerUserId_idx" ON "public"."EqubCycle"("selectedWinnerUserId");

-- CreateIndex
CREATE INDEX "EqubCycle_payoutSentByUserId_idx" ON "public"."EqubCycle"("payoutSentByUserId");

-- CreateIndex
CREATE INDEX "EqubCycle_payoutReceivedConfirmedByUserId_idx" ON "public"."EqubCycle"("payoutReceivedConfirmedByUserId");

-- CreateIndex
CREATE UNIQUE INDEX "EqubCycle_roundId_cycleNo_key" ON "public"."EqubCycle"("roundId", "cycleNo");

-- CreateIndex
CREATE UNIQUE INDEX "EqubCycle_roundId_selectedWinnerUserId_key" ON "public"."EqubCycle"("roundId", "selectedWinnerUserId");

-- CreateIndex
CREATE INDEX "UserReputationMetrics_trustScore_idx" ON "public"."UserReputationMetrics"("trustScore");

-- CreateIndex
CREATE INDEX "UserReputationMetrics_updatedAt_idx" ON "public"."UserReputationMetrics"("updatedAt" DESC);

-- CreateIndex
CREATE UNIQUE INDEX "ReputationHistory_idempotencyKey_key" ON "public"."ReputationHistory"("idempotencyKey");

-- CreateIndex
CREATE INDEX "ReputationHistory_userId_createdAt_idx" ON "public"."ReputationHistory"("userId", "createdAt" DESC);

-- CreateIndex
CREATE INDEX "ReputationHistory_createdAt_idx" ON "public"."ReputationHistory"("createdAt" DESC);

-- CreateIndex
CREATE INDEX "ReputationHistory_relatedGroupId_idx" ON "public"."ReputationHistory"("relatedGroupId");

-- CreateIndex
CREATE INDEX "ReputationHistory_eventType_createdAt_idx" ON "public"."ReputationHistory"("eventType", "createdAt" DESC);

-- CreateIndex
CREATE UNIQUE INDEX "CycleAuction_cycleId_key" ON "public"."CycleAuction"("cycleId");

-- CreateIndex
CREATE INDEX "CycleAuction_status_openedAt_idx" ON "public"."CycleAuction"("status", "openedAt");

-- CreateIndex
CREATE INDEX "CycleBid_cycleId_amount_createdAt_idx" ON "public"."CycleBid"("cycleId", "amount", "createdAt");

-- CreateIndex
CREATE INDEX "CycleBid_userId_idx" ON "public"."CycleBid"("userId");

-- CreateIndex
CREATE UNIQUE INDEX "CycleBid_cycleId_userId_key" ON "public"."CycleBid"("cycleId", "userId");

-- CreateIndex
CREATE INDEX "Contribution_groupId_cycleId_idx" ON "public"."Contribution"("groupId", "cycleId");

-- CreateIndex
CREATE UNIQUE INDEX "Contribution_cycleId_userId_key" ON "public"."Contribution"("cycleId", "userId");

-- CreateIndex
CREATE INDEX "ContributionDispute_groupId_cycleId_status_idx" ON "public"."ContributionDispute"("groupId", "cycleId", "status");

-- CreateIndex
CREATE INDEX "ContributionDispute_contributionId_createdAt_idx" ON "public"."ContributionDispute"("contributionId", "createdAt");

-- CreateIndex
CREATE INDEX "ContributionDispute_reportedByUserId_status_idx" ON "public"."ContributionDispute"("reportedByUserId", "status");

-- CreateIndex
CREATE INDEX "ContributionDispute_mediatedByUserId_idx" ON "public"."ContributionDispute"("mediatedByUserId");

-- CreateIndex
CREATE INDEX "ContributionDispute_resolvedByUserId_idx" ON "public"."ContributionDispute"("resolvedByUserId");

-- CreateIndex
CREATE UNIQUE INDEX "ContributionReceipt_contributionId_key" ON "public"."ContributionReceipt"("contributionId");

-- CreateIndex
CREATE INDEX "ContributionReceipt_groupId_cycleId_idx" ON "public"."ContributionReceipt"("groupId", "cycleId");

-- CreateIndex
CREATE INDEX "ContributionReceipt_userId_createdAt_idx" ON "public"."ContributionReceipt"("userId", "createdAt");

-- CreateIndex
CREATE UNIQUE INDEX "Payout_cycleId_key" ON "public"."Payout"("cycleId");

-- CreateIndex
CREATE INDEX "Payout_groupId_cycleId_idx" ON "public"."Payout"("groupId", "cycleId");

-- CreateIndex
CREATE INDEX "LedgerEntry_groupId_cycleId_createdAt_idx" ON "public"."LedgerEntry"("groupId", "cycleId", "createdAt");

-- CreateIndex
CREATE INDEX "LedgerEntry_contributionId_idx" ON "public"."LedgerEntry"("contributionId");

-- CreateIndex
CREATE INDEX "LedgerEntry_payoutId_idx" ON "public"."LedgerEntry"("payoutId");

-- CreateIndex
CREATE INDEX "LedgerEntry_userId_createdAt_idx" ON "public"."LedgerEntry"("userId", "createdAt");

-- CreateIndex
CREATE INDEX "AuditLog_groupId_idx" ON "public"."AuditLog"("groupId");

-- CreateIndex
CREATE INDEX "AuditLog_actorUserId_idx" ON "public"."AuditLog"("actorUserId");

-- CreateIndex
CREATE INDEX "AuditLog_action_createdAt_idx" ON "public"."AuditLog"("action", "createdAt" DESC);

-- CreateIndex
CREATE INDEX "DeviceToken_userId_isActive_idx" ON "public"."DeviceToken"("userId", "isActive");

-- CreateIndex
CREATE UNIQUE INDEX "DeviceToken_userId_token_key" ON "public"."DeviceToken"("userId", "token");

-- CreateIndex
CREATE INDEX "Notification_userId_status_createdAt_idx" ON "public"."Notification"("userId", "status", "createdAt" DESC);

-- CreateIndex
CREATE UNIQUE INDEX "Notification_userId_eventId_key" ON "public"."Notification"("userId", "eventId");

-- AddForeignKey
ALTER TABLE "public"."RefreshToken" ADD CONSTRAINT "RefreshToken_userId_fkey" FOREIGN KEY ("userId") REFERENCES "public"."User"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "public"."EqubGroup" ADD CONSTRAINT "EqubGroup_createdByUserId_fkey" FOREIGN KEY ("createdByUserId") REFERENCES "public"."User"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "public"."JoinRequest" ADD CONSTRAINT "JoinRequest_groupId_fkey" FOREIGN KEY ("groupId") REFERENCES "public"."EqubGroup"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "public"."JoinRequest" ADD CONSTRAINT "JoinRequest_userId_fkey" FOREIGN KEY ("userId") REFERENCES "public"."User"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "public"."JoinRequest" ADD CONSTRAINT "JoinRequest_reviewedByUserId_fkey" FOREIGN KEY ("reviewedByUserId") REFERENCES "public"."User"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "public"."GroupRules" ADD CONSTRAINT "GroupRules_groupId_fkey" FOREIGN KEY ("groupId") REFERENCES "public"."EqubGroup"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "public"."EqubMember" ADD CONSTRAINT "EqubMember_groupId_fkey" FOREIGN KEY ("groupId") REFERENCES "public"."EqubGroup"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "public"."EqubMember" ADD CONSTRAINT "EqubMember_userId_fkey" FOREIGN KEY ("userId") REFERENCES "public"."User"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "public"."EqubMember" ADD CONSTRAINT "EqubMember_verifiedByUserId_fkey" FOREIGN KEY ("verifiedByUserId") REFERENCES "public"."User"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "public"."EqubMember" ADD CONSTRAINT "EqubMember_guarantorUserId_fkey" FOREIGN KEY ("guarantorUserId") REFERENCES "public"."User"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "public"."EqubRound" ADD CONSTRAINT "EqubRound_groupId_fkey" FOREIGN KEY ("groupId") REFERENCES "public"."EqubGroup"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "public"."EqubRound" ADD CONSTRAINT "EqubRound_startedByUserId_fkey" FOREIGN KEY ("startedByUserId") REFERENCES "public"."User"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "public"."EqubRound" ADD CONSTRAINT "EqubRound_drawSeedRevealedByUserId_fkey" FOREIGN KEY ("drawSeedRevealedByUserId") REFERENCES "public"."User"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "public"."PayoutSchedule" ADD CONSTRAINT "PayoutSchedule_roundId_fkey" FOREIGN KEY ("roundId") REFERENCES "public"."EqubRound"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "public"."PayoutSchedule" ADD CONSTRAINT "PayoutSchedule_userId_fkey" FOREIGN KEY ("userId") REFERENCES "public"."User"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "public"."InviteCode" ADD CONSTRAINT "InviteCode_groupId_fkey" FOREIGN KEY ("groupId") REFERENCES "public"."EqubGroup"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "public"."InviteCode" ADD CONSTRAINT "InviteCode_createdByUserId_fkey" FOREIGN KEY ("createdByUserId") REFERENCES "public"."User"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "public"."EqubCycle" ADD CONSTRAINT "EqubCycle_groupId_fkey" FOREIGN KEY ("groupId") REFERENCES "public"."EqubGroup"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "public"."EqubCycle" ADD CONSTRAINT "EqubCycle_roundId_fkey" FOREIGN KEY ("roundId") REFERENCES "public"."EqubRound"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "public"."EqubCycle" ADD CONSTRAINT "EqubCycle_scheduledPayoutUserId_fkey" FOREIGN KEY ("scheduledPayoutUserId") REFERENCES "public"."User"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "public"."EqubCycle" ADD CONSTRAINT "EqubCycle_finalPayoutUserId_fkey" FOREIGN KEY ("finalPayoutUserId") REFERENCES "public"."User"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "public"."EqubCycle" ADD CONSTRAINT "EqubCycle_selectedWinnerUserId_fkey" FOREIGN KEY ("selectedWinnerUserId") REFERENCES "public"."User"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "public"."EqubCycle" ADD CONSTRAINT "EqubCycle_winningBidUserId_fkey" FOREIGN KEY ("winningBidUserId") REFERENCES "public"."User"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "public"."EqubCycle" ADD CONSTRAINT "EqubCycle_payoutSentByUserId_fkey" FOREIGN KEY ("payoutSentByUserId") REFERENCES "public"."User"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "public"."EqubCycle" ADD CONSTRAINT "EqubCycle_payoutReceivedConfirmedByUserId_fkey" FOREIGN KEY ("payoutReceivedConfirmedByUserId") REFERENCES "public"."User"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "public"."EqubCycle" ADD CONSTRAINT "EqubCycle_closedByUserId_fkey" FOREIGN KEY ("closedByUserId") REFERENCES "public"."User"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "public"."EqubCycle" ADD CONSTRAINT "EqubCycle_createdByUserId_fkey" FOREIGN KEY ("createdByUserId") REFERENCES "public"."User"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "public"."UserReputationMetrics" ADD CONSTRAINT "UserReputationMetrics_userId_fkey" FOREIGN KEY ("userId") REFERENCES "public"."User"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "public"."ReputationHistory" ADD CONSTRAINT "ReputationHistory_userId_fkey" FOREIGN KEY ("userId") REFERENCES "public"."User"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "public"."ReputationHistory" ADD CONSTRAINT "ReputationHistory_relatedGroupId_fkey" FOREIGN KEY ("relatedGroupId") REFERENCES "public"."EqubGroup"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "public"."ReputationHistory" ADD CONSTRAINT "ReputationHistory_relatedCycleId_fkey" FOREIGN KEY ("relatedCycleId") REFERENCES "public"."EqubCycle"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "public"."CycleAuction" ADD CONSTRAINT "CycleAuction_cycleId_fkey" FOREIGN KEY ("cycleId") REFERENCES "public"."EqubCycle"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "public"."CycleAuction" ADD CONSTRAINT "CycleAuction_openedByUserId_fkey" FOREIGN KEY ("openedByUserId") REFERENCES "public"."User"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "public"."CycleBid" ADD CONSTRAINT "CycleBid_cycleId_fkey" FOREIGN KEY ("cycleId") REFERENCES "public"."EqubCycle"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "public"."CycleBid" ADD CONSTRAINT "CycleBid_userId_fkey" FOREIGN KEY ("userId") REFERENCES "public"."User"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "public"."Contribution" ADD CONSTRAINT "Contribution_groupId_fkey" FOREIGN KEY ("groupId") REFERENCES "public"."EqubGroup"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "public"."Contribution" ADD CONSTRAINT "Contribution_cycleId_fkey" FOREIGN KEY ("cycleId") REFERENCES "public"."EqubCycle"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "public"."Contribution" ADD CONSTRAINT "Contribution_userId_fkey" FOREIGN KEY ("userId") REFERENCES "public"."User"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "public"."Contribution" ADD CONSTRAINT "Contribution_confirmedByUserId_fkey" FOREIGN KEY ("confirmedByUserId") REFERENCES "public"."User"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "public"."Contribution" ADD CONSTRAINT "Contribution_rejectedByUserId_fkey" FOREIGN KEY ("rejectedByUserId") REFERENCES "public"."User"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "public"."ContributionDispute" ADD CONSTRAINT "ContributionDispute_groupId_fkey" FOREIGN KEY ("groupId") REFERENCES "public"."EqubGroup"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "public"."ContributionDispute" ADD CONSTRAINT "ContributionDispute_cycleId_fkey" FOREIGN KEY ("cycleId") REFERENCES "public"."EqubCycle"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "public"."ContributionDispute" ADD CONSTRAINT "ContributionDispute_contributionId_fkey" FOREIGN KEY ("contributionId") REFERENCES "public"."Contribution"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "public"."ContributionDispute" ADD CONSTRAINT "ContributionDispute_reportedByUserId_fkey" FOREIGN KEY ("reportedByUserId") REFERENCES "public"."User"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "public"."ContributionDispute" ADD CONSTRAINT "ContributionDispute_mediatedByUserId_fkey" FOREIGN KEY ("mediatedByUserId") REFERENCES "public"."User"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "public"."ContributionDispute" ADD CONSTRAINT "ContributionDispute_resolvedByUserId_fkey" FOREIGN KEY ("resolvedByUserId") REFERENCES "public"."User"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "public"."ContributionReceipt" ADD CONSTRAINT "ContributionReceipt_contributionId_fkey" FOREIGN KEY ("contributionId") REFERENCES "public"."Contribution"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "public"."ContributionReceipt" ADD CONSTRAINT "ContributionReceipt_groupId_fkey" FOREIGN KEY ("groupId") REFERENCES "public"."EqubGroup"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "public"."ContributionReceipt" ADD CONSTRAINT "ContributionReceipt_cycleId_fkey" FOREIGN KEY ("cycleId") REFERENCES "public"."EqubCycle"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "public"."ContributionReceipt" ADD CONSTRAINT "ContributionReceipt_userId_fkey" FOREIGN KEY ("userId") REFERENCES "public"."User"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "public"."Payout" ADD CONSTRAINT "Payout_groupId_fkey" FOREIGN KEY ("groupId") REFERENCES "public"."EqubGroup"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "public"."Payout" ADD CONSTRAINT "Payout_cycleId_fkey" FOREIGN KEY ("cycleId") REFERENCES "public"."EqubCycle"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "public"."Payout" ADD CONSTRAINT "Payout_toUserId_fkey" FOREIGN KEY ("toUserId") REFERENCES "public"."User"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "public"."Payout" ADD CONSTRAINT "Payout_createdByUserId_fkey" FOREIGN KEY ("createdByUserId") REFERENCES "public"."User"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "public"."Payout" ADD CONSTRAINT "Payout_confirmedByUserId_fkey" FOREIGN KEY ("confirmedByUserId") REFERENCES "public"."User"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "public"."LedgerEntry" ADD CONSTRAINT "LedgerEntry_groupId_fkey" FOREIGN KEY ("groupId") REFERENCES "public"."EqubGroup"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "public"."LedgerEntry" ADD CONSTRAINT "LedgerEntry_cycleId_fkey" FOREIGN KEY ("cycleId") REFERENCES "public"."EqubCycle"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "public"."LedgerEntry" ADD CONSTRAINT "LedgerEntry_contributionId_fkey" FOREIGN KEY ("contributionId") REFERENCES "public"."Contribution"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "public"."LedgerEntry" ADD CONSTRAINT "LedgerEntry_payoutId_fkey" FOREIGN KEY ("payoutId") REFERENCES "public"."Payout"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "public"."LedgerEntry" ADD CONSTRAINT "LedgerEntry_userId_fkey" FOREIGN KEY ("userId") REFERENCES "public"."User"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "public"."LedgerEntry" ADD CONSTRAINT "LedgerEntry_confirmedByUserId_fkey" FOREIGN KEY ("confirmedByUserId") REFERENCES "public"."User"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "public"."AuditLog" ADD CONSTRAINT "AuditLog_actorUserId_fkey" FOREIGN KEY ("actorUserId") REFERENCES "public"."User"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "public"."AuditLog" ADD CONSTRAINT "AuditLog_groupId_fkey" FOREIGN KEY ("groupId") REFERENCES "public"."EqubGroup"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "public"."DeviceToken" ADD CONSTRAINT "DeviceToken_userId_fkey" FOREIGN KEY ("userId") REFERENCES "public"."User"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "public"."Notification" ADD CONSTRAINT "Notification_userId_fkey" FOREIGN KEY ("userId") REFERENCES "public"."User"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "public"."Notification" ADD CONSTRAINT "Notification_groupId_fkey" FOREIGN KEY ("groupId") REFERENCES "public"."EqubGroup"("id") ON DELETE SET NULL ON UPDATE CASCADE;
