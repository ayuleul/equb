-- CreateEnum
CREATE TYPE "public"."CycleStatus" AS ENUM ('OPEN', 'CLOSED');

-- AlterTable
ALTER TABLE "public"."EqubGroup" ADD COLUMN     "strictPayout" BOOLEAN NOT NULL DEFAULT false,
ADD COLUMN     "timezone" TEXT NOT NULL DEFAULT 'Africa/Addis_Ababa';

-- CreateTable
CREATE TABLE "public"."EqubCycle" (
    "id" TEXT NOT NULL,
    "groupId" TEXT NOT NULL,
    "cycleNo" INTEGER NOT NULL,
    "dueDate" DATE NOT NULL,
    "payoutUserId" TEXT NOT NULL,
    "status" "public"."CycleStatus" NOT NULL DEFAULT 'OPEN',
    "createdByUserId" TEXT NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "EqubCycle_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE INDEX "EqubCycle_groupId_status_idx" ON "public"."EqubCycle"("groupId", "status");

-- CreateIndex
CREATE UNIQUE INDEX "EqubCycle_groupId_cycleNo_key" ON "public"."EqubCycle"("groupId", "cycleNo");

-- AddForeignKey
ALTER TABLE "public"."EqubCycle" ADD CONSTRAINT "EqubCycle_groupId_fkey" FOREIGN KEY ("groupId") REFERENCES "public"."EqubGroup"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "public"."EqubCycle" ADD CONSTRAINT "EqubCycle_payoutUserId_fkey" FOREIGN KEY ("payoutUserId") REFERENCES "public"."User"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "public"."EqubCycle" ADD CONSTRAINT "EqubCycle_createdByUserId_fkey" FOREIGN KEY ("createdByUserId") REFERENCES "public"."User"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
