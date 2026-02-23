-- CreateEnum
CREATE TYPE "public"."CycleState" AS ENUM (
    'DUE',
    'COLLECTING',
    'READY_FOR_PAYOUT',
    'DISBURSED',
    'CLOSED'
);

-- CreateEnum
CREATE TYPE "public"."LedgerEntryType" AS ENUM (
    'MEMBER_PAYMENT',
    'CONTRIBUTION_VERIFIED',
    'PAYOUT_DISBURSED'
);

-- AlterEnum
ALTER TYPE "public"."ContributionStatus" ADD VALUE IF NOT EXISTS 'PAID_SUBMITTED';
ALTER TYPE "public"."ContributionStatus" ADD VALUE IF NOT EXISTS 'VERIFIED';

-- AlterTable
ALTER TABLE "public"."EqubCycle"
ADD COLUMN "dueAt" TIMESTAMP(3),
ADD COLUMN "state" "public"."CycleState" NOT NULL DEFAULT 'DUE';

UPDATE "public"."EqubCycle"
SET "dueAt" = "dueDate"
WHERE "dueAt" IS NULL;

UPDATE "public"."EqubCycle"
SET "state" = CASE
    WHEN "status" = 'CLOSED' THEN 'CLOSED'::"public"."CycleState"
    ELSE 'COLLECTING'::"public"."CycleState"
END;

ALTER TABLE "public"."EqubCycle"
ALTER COLUMN "dueAt" SET NOT NULL;

-- AlterTable
ALTER TABLE "public"."Contribution"
ADD COLUMN "paymentMethod" "public"."GroupPaymentMethod";

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

-- CreateIndex
CREATE UNIQUE INDEX "ContributionReceipt_contributionId_key" ON "public"."ContributionReceipt"("contributionId");

-- CreateIndex
CREATE INDEX "ContributionReceipt_groupId_cycleId_idx" ON "public"."ContributionReceipt"("groupId", "cycleId");

-- CreateIndex
CREATE INDEX "ContributionReceipt_userId_createdAt_idx" ON "public"."ContributionReceipt"("userId", "createdAt");

-- CreateIndex
CREATE INDEX "LedgerEntry_groupId_cycleId_createdAt_idx" ON "public"."LedgerEntry"("groupId", "cycleId", "createdAt");

-- CreateIndex
CREATE INDEX "LedgerEntry_contributionId_idx" ON "public"."LedgerEntry"("contributionId");

-- CreateIndex
CREATE INDEX "LedgerEntry_payoutId_idx" ON "public"."LedgerEntry"("payoutId");

-- CreateIndex
CREATE INDEX "LedgerEntry_userId_createdAt_idx" ON "public"."LedgerEntry"("userId", "createdAt");

-- AddForeignKey
ALTER TABLE "public"."ContributionReceipt" ADD CONSTRAINT "ContributionReceipt_groupId_fkey" FOREIGN KEY ("groupId") REFERENCES "public"."EqubGroup"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "public"."ContributionReceipt" ADD CONSTRAINT "ContributionReceipt_cycleId_fkey" FOREIGN KEY ("cycleId") REFERENCES "public"."EqubCycle"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "public"."ContributionReceipt" ADD CONSTRAINT "ContributionReceipt_contributionId_fkey" FOREIGN KEY ("contributionId") REFERENCES "public"."Contribution"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "public"."ContributionReceipt" ADD CONSTRAINT "ContributionReceipt_userId_fkey" FOREIGN KEY ("userId") REFERENCES "public"."User"("id") ON DELETE CASCADE ON UPDATE CASCADE;

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
