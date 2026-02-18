-- CreateEnum
CREATE TYPE "public"."ContributionStatus" AS ENUM ('PENDING', 'SUBMITTED', 'CONFIRMED', 'REJECTED');

-- AlterTable
ALTER TABLE "public"."EqubCycle" ADD COLUMN     "contributionsConfirmedCount" INTEGER NOT NULL DEFAULT 0,
ADD COLUMN     "contributionsSubmittedCount" INTEGER NOT NULL DEFAULT 0;

-- CreateTable
CREATE TABLE "public"."Contribution" (
    "id" TEXT NOT NULL,
    "groupId" TEXT NOT NULL,
    "cycleId" TEXT NOT NULL,
    "userId" TEXT NOT NULL,
    "amount" INTEGER NOT NULL,
    "status" "public"."ContributionStatus" NOT NULL DEFAULT 'PENDING',
    "proofFileKey" TEXT,
    "paymentRef" TEXT,
    "note" TEXT,
    "submittedAt" TIMESTAMP(3),
    "confirmedByUserId" TEXT,
    "confirmedAt" TIMESTAMP(3),
    "rejectedByUserId" TEXT,
    "rejectedAt" TIMESTAMP(3),
    "rejectReason" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "Contribution_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE INDEX "Contribution_groupId_cycleId_idx" ON "public"."Contribution"("groupId", "cycleId");

-- CreateIndex
CREATE UNIQUE INDEX "Contribution_cycleId_userId_key" ON "public"."Contribution"("cycleId", "userId");

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
