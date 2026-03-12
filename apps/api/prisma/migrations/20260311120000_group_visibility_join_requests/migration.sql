-- CreateEnum
CREATE TYPE "GroupVisibility" AS ENUM ('PRIVATE', 'PUBLIC');

-- CreateEnum
CREATE TYPE "JoinRequestStatus" AS ENUM ('REQUESTED', 'APPROVED', 'REJECTED', 'WITHDRAWN');

-- AlterTable
ALTER TABLE "EqubGroup"
ADD COLUMN "description" TEXT,
ADD COLUMN "visibility" "GroupVisibility" NOT NULL DEFAULT 'PRIVATE';

-- CreateTable
CREATE TABLE "JoinRequest" (
    "id" TEXT NOT NULL,
    "groupId" TEXT NOT NULL,
    "userId" TEXT NOT NULL,
    "status" "JoinRequestStatus" NOT NULL DEFAULT 'REQUESTED',
    "message" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "reviewedAt" TIMESTAMP(3),
    "reviewedByUserId" TEXT,

    CONSTRAINT "JoinRequest_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE INDEX "EqubGroup_visibility_status_idx" ON "EqubGroup"("visibility", "status");

-- CreateIndex
CREATE INDEX "JoinRequest_groupId_status_createdAt_idx" ON "JoinRequest"("groupId", "status", "createdAt" DESC);

-- CreateIndex
CREATE INDEX "JoinRequest_userId_status_createdAt_idx" ON "JoinRequest"("userId", "status", "createdAt" DESC);

-- CreateIndex
CREATE UNIQUE INDEX "JoinRequest_groupId_userId_requested_unique"
ON "JoinRequest"("groupId", "userId")
WHERE "status" = 'REQUESTED';

-- AddForeignKey
ALTER TABLE "JoinRequest"
ADD CONSTRAINT "JoinRequest_groupId_fkey"
FOREIGN KEY ("groupId") REFERENCES "EqubGroup"("id")
ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "JoinRequest"
ADD CONSTRAINT "JoinRequest_userId_fkey"
FOREIGN KEY ("userId") REFERENCES "User"("id")
ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "JoinRequest"
ADD CONSTRAINT "JoinRequest_reviewedByUserId_fkey"
FOREIGN KEY ("reviewedByUserId") REFERENCES "User"("id")
ON DELETE SET NULL ON UPDATE CASCADE;
