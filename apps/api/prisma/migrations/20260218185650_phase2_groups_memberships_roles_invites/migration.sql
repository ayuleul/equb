-- CreateEnum
CREATE TYPE "public"."GroupFrequency" AS ENUM ('WEEKLY', 'MONTHLY');

-- CreateEnum
CREATE TYPE "public"."GroupStatus" AS ENUM ('ACTIVE', 'ARCHIVED');

-- CreateEnum
CREATE TYPE "public"."MemberRole" AS ENUM ('ADMIN', 'MEMBER');

-- CreateEnum
CREATE TYPE "public"."MemberStatus" AS ENUM ('INVITED', 'ACTIVE', 'LEFT', 'REMOVED');

-- AlterTable
ALTER TABLE "public"."AuditLog" ADD COLUMN     "groupId" TEXT;

-- CreateTable
CREATE TABLE "public"."EqubGroup" (
    "id" TEXT NOT NULL,
    "name" TEXT NOT NULL,
    "currency" TEXT NOT NULL DEFAULT 'ETB',
    "contributionAmount" INTEGER NOT NULL,
    "frequency" "public"."GroupFrequency" NOT NULL,
    "startDate" DATE NOT NULL,
    "status" "public"."GroupStatus" NOT NULL DEFAULT 'ACTIVE',
    "createdByUserId" TEXT NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "EqubGroup_pkey" PRIMARY KEY ("id")
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
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "EqubMember_pkey" PRIMARY KEY ("id")
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

-- CreateIndex
CREATE INDEX "EqubGroup_createdByUserId_idx" ON "public"."EqubGroup"("createdByUserId");

-- CreateIndex
CREATE INDEX "EqubMember_userId_idx" ON "public"."EqubMember"("userId");

-- CreateIndex
CREATE INDEX "EqubMember_groupId_status_role_idx" ON "public"."EqubMember"("groupId", "status", "role");

-- CreateIndex
CREATE UNIQUE INDEX "EqubMember_groupId_userId_key" ON "public"."EqubMember"("groupId", "userId");

-- CreateIndex
CREATE UNIQUE INDEX "InviteCode_code_key" ON "public"."InviteCode"("code");

-- CreateIndex
CREATE INDEX "InviteCode_groupId_idx" ON "public"."InviteCode"("groupId");

-- CreateIndex
CREATE INDEX "AuditLog_groupId_idx" ON "public"."AuditLog"("groupId");

-- AddForeignKey
ALTER TABLE "public"."EqubGroup" ADD CONSTRAINT "EqubGroup_createdByUserId_fkey" FOREIGN KEY ("createdByUserId") REFERENCES "public"."User"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "public"."EqubMember" ADD CONSTRAINT "EqubMember_groupId_fkey" FOREIGN KEY ("groupId") REFERENCES "public"."EqubGroup"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "public"."EqubMember" ADD CONSTRAINT "EqubMember_userId_fkey" FOREIGN KEY ("userId") REFERENCES "public"."User"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "public"."InviteCode" ADD CONSTRAINT "InviteCode_groupId_fkey" FOREIGN KEY ("groupId") REFERENCES "public"."EqubGroup"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "public"."InviteCode" ADD CONSTRAINT "InviteCode_createdByUserId_fkey" FOREIGN KEY ("createdByUserId") REFERENCES "public"."User"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "public"."AuditLog" ADD CONSTRAINT "AuditLog_groupId_fkey" FOREIGN KEY ("groupId") REFERENCES "public"."EqubGroup"("id") ON DELETE SET NULL ON UPDATE CASCADE;
