-- CreateEnum
CREATE TYPE "public"."DisputeStatus" AS ENUM ('OPEN', 'MEDIATING', 'RESOLVED');

-- AlterEnum
ALTER TYPE "public"."ContributionStatus" ADD VALUE 'LATE';

-- AlterEnum
ALTER TYPE "public"."LedgerEntryType" ADD VALUE 'LATE_FINE';

-- AlterEnum
-- This migration adds more than one value to an enum.
-- With PostgreSQL versions 11 and earlier, this is not possible
-- in a single migration. This can be worked around by creating
-- multiple migrations, each migration adding only one value to
-- the enum.


ALTER TYPE "public"."NotificationType" ADD VALUE 'CONTRIBUTION_LATE';
ALTER TYPE "public"."NotificationType" ADD VALUE 'DISPUTE_OPENED';
ALTER TYPE "public"."NotificationType" ADD VALUE 'DISPUTE_MEDIATING';
ALTER TYPE "public"."NotificationType" ADD VALUE 'DISPUTE_RESOLVED';

-- AlterTable
ALTER TABLE "public"."Contribution" ADD COLUMN     "lateMarkedAt" TIMESTAMP(3);

-- AlterTable
ALTER TABLE "public"."EqubCycle" ALTER COLUMN "dueAt" SET DATA TYPE DATE;

-- AlterTable
ALTER TABLE "public"."EqubMember" ADD COLUMN     "guarantorUserId" TEXT;

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
CREATE INDEX "EqubMember_guarantorUserId_idx" ON "public"."EqubMember"("guarantorUserId");

-- AddForeignKey
ALTER TABLE "public"."EqubMember" ADD CONSTRAINT "EqubMember_guarantorUserId_fkey" FOREIGN KEY ("guarantorUserId") REFERENCES "public"."User"("id") ON DELETE SET NULL ON UPDATE CASCADE;

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
