-- CreateEnum
CREATE TYPE "public"."PayoutMode" AS ENUM ('RANDOM_DRAW');

-- CreateEnum
CREATE TYPE "public"."AuctionStatus" AS ENUM ('NONE', 'OPEN', 'CLOSED');

-- CreateTable
CREATE TABLE "public"."EqubRound" (
    "id" TEXT NOT NULL,
    "groupId" TEXT NOT NULL,
    "roundNo" INTEGER NOT NULL,
    "payoutMode" "public"."PayoutMode" NOT NULL DEFAULT 'RANDOM_DRAW',
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

-- AlterTable
ALTER TABLE "public"."EqubCycle"
ADD COLUMN     "auctionStatus" "public"."AuctionStatus" NOT NULL DEFAULT 'NONE',
ADD COLUMN     "finalPayoutUserId" TEXT,
ADD COLUMN     "roundId" TEXT,
ADD COLUMN     "scheduledPayoutUserId" TEXT,
ADD COLUMN     "winningBidAmount" INTEGER,
ADD COLUMN     "winningBidUserId" TEXT;

-- AlterTable
ALTER TABLE "public"."Payout" ADD COLUMN     "metadata" JSONB;

-- Backfill legacy rounds for existing groups.
INSERT INTO "public"."EqubRound" (
    "id",
    "groupId",
    "roundNo",
    "payoutMode",
    "startedByUserId",
    "startedAt"
)
SELECT
    'legacy-round-' || g."id",
    g."id",
    1,
    'RANDOM_DRAW'::"public"."PayoutMode",
    g."createdByUserId",
    CURRENT_TIMESTAMP
FROM "public"."EqubGroup" g
WHERE NOT EXISTS (
    SELECT 1
    FROM "public"."EqubRound" r
    WHERE r."groupId" = g."id"
);

-- Backfill a deterministic legacy payout schedule from active memberships.
INSERT INTO "public"."PayoutSchedule" (
    "roundId",
    "position",
    "userId"
)
SELECT
    'legacy-round-' || m."groupId",
    ROW_NUMBER() OVER (
        PARTITION BY m."groupId"
        ORDER BY
            COALESCE(m."payoutPosition", 2147483647),
            m."createdAt",
            m."userId"
    ),
    m."userId"
FROM "public"."EqubMember" m
WHERE m."status" = 'ACTIVE'
ON CONFLICT ("roundId", "position") DO NOTHING;

-- Backfill existing cycles to scheduled/final payout recipients and a legacy round.
UPDATE "public"."EqubCycle" c
SET
    "roundId" = 'legacy-round-' || c."groupId",
    "scheduledPayoutUserId" = c."payoutUserId",
    "finalPayoutUserId" = c."payoutUserId"
WHERE
    c."roundId" IS NULL
    OR c."scheduledPayoutUserId" IS NULL
    OR c."finalPayoutUserId" IS NULL;

-- Enforce non-null after backfill.
ALTER TABLE "public"."EqubCycle"
ALTER COLUMN "roundId" SET NOT NULL,
ALTER COLUMN "scheduledPayoutUserId" SET NOT NULL,
ALTER COLUMN "finalPayoutUserId" SET NOT NULL;

-- Drop legacy payout recipient column.
ALTER TABLE "public"."EqubCycle" DROP CONSTRAINT "EqubCycle_payoutUserId_fkey";
ALTER TABLE "public"."EqubCycle" DROP COLUMN "payoutUserId";

-- Replace uniqueness by group+cycleNo with round+cycleNo.
DROP INDEX "public"."EqubCycle_groupId_cycleNo_key";

-- CreateIndex
CREATE UNIQUE INDEX "EqubRound_groupId_roundNo_key" ON "public"."EqubRound"("groupId", "roundNo");

-- CreateIndex
CREATE INDEX "EqubRound_groupId_closedAt_idx" ON "public"."EqubRound"("groupId", "closedAt");

-- CreateIndex
CREATE UNIQUE INDEX "PayoutSchedule_roundId_userId_key" ON "public"."PayoutSchedule"("roundId", "userId");

-- CreateIndex
CREATE INDEX "PayoutSchedule_userId_idx" ON "public"."PayoutSchedule"("userId");

-- CreateIndex
CREATE UNIQUE INDEX "CycleAuction_cycleId_key" ON "public"."CycleAuction"("cycleId");

-- CreateIndex
CREATE INDEX "CycleAuction_status_openedAt_idx" ON "public"."CycleAuction"("status", "openedAt");

-- CreateIndex
CREATE UNIQUE INDEX "CycleBid_cycleId_userId_key" ON "public"."CycleBid"("cycleId", "userId");

-- CreateIndex
CREATE INDEX "CycleBid_cycleId_amount_createdAt_idx" ON "public"."CycleBid"("cycleId", "amount", "createdAt");

-- CreateIndex
CREATE INDEX "CycleBid_userId_idx" ON "public"."CycleBid"("userId");

-- CreateIndex
CREATE UNIQUE INDEX "EqubCycle_roundId_cycleNo_key" ON "public"."EqubCycle"("roundId", "cycleNo");

-- CreateIndex
CREATE INDEX "EqubCycle_groupId_roundId_idx" ON "public"."EqubCycle"("groupId", "roundId");

-- AddForeignKey
ALTER TABLE "public"."EqubRound" ADD CONSTRAINT "EqubRound_groupId_fkey" FOREIGN KEY ("groupId") REFERENCES "public"."EqubGroup"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "public"."EqubRound" ADD CONSTRAINT "EqubRound_startedByUserId_fkey" FOREIGN KEY ("startedByUserId") REFERENCES "public"."User"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "public"."PayoutSchedule" ADD CONSTRAINT "PayoutSchedule_roundId_fkey" FOREIGN KEY ("roundId") REFERENCES "public"."EqubRound"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "public"."PayoutSchedule" ADD CONSTRAINT "PayoutSchedule_userId_fkey" FOREIGN KEY ("userId") REFERENCES "public"."User"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "public"."EqubCycle" ADD CONSTRAINT "EqubCycle_roundId_fkey" FOREIGN KEY ("roundId") REFERENCES "public"."EqubRound"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "public"."EqubCycle" ADD CONSTRAINT "EqubCycle_scheduledPayoutUserId_fkey" FOREIGN KEY ("scheduledPayoutUserId") REFERENCES "public"."User"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "public"."EqubCycle" ADD CONSTRAINT "EqubCycle_finalPayoutUserId_fkey" FOREIGN KEY ("finalPayoutUserId") REFERENCES "public"."User"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "public"."EqubCycle" ADD CONSTRAINT "EqubCycle_winningBidUserId_fkey" FOREIGN KEY ("winningBidUserId") REFERENCES "public"."User"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "public"."CycleAuction" ADD CONSTRAINT "CycleAuction_cycleId_fkey" FOREIGN KEY ("cycleId") REFERENCES "public"."EqubCycle"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "public"."CycleAuction" ADD CONSTRAINT "CycleAuction_openedByUserId_fkey" FOREIGN KEY ("openedByUserId") REFERENCES "public"."User"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "public"."CycleBid" ADD CONSTRAINT "CycleBid_cycleId_fkey" FOREIGN KEY ("cycleId") REFERENCES "public"."EqubCycle"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "public"."CycleBid" ADD CONSTRAINT "CycleBid_userId_fkey" FOREIGN KEY ("userId") REFERENCES "public"."User"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- CycleAuction may only be OPEN/CLOSED.
ALTER TABLE "public"."CycleAuction" ADD CONSTRAINT "CycleAuction_status_check" CHECK ("status" <> 'NONE');
