-- CreateTable
CREATE TABLE "EqubDiscoverMetrics" (
    "equbId" TEXT NOT NULL,
    "hostUserId" TEXT NOT NULL,
    "hostTrustScore" INTEGER NOT NULL DEFAULT 50,
    "hostTrustLevel" TEXT NOT NULL DEFAULT 'New',
    "avgMemberScore" INTEGER NOT NULL DEFAULT 50,
    "groupTrustLevel" TEXT NOT NULL DEFAULT 'Low',
    "verifiedMembersPercent" INTEGER NOT NULL DEFAULT 0,
    "joinedCount" INTEGER NOT NULL DEFAULT 0,
    "maxMembers" INTEGER NOT NULL DEFAULT 0,
    "fillPercent" INTEGER NOT NULL DEFAULT 0,
    "pendingRequestCount" INTEGER NOT NULL DEFAULT 0,
    "waitlistCount" INTEGER NOT NULL DEFAULT 0,
    "joinVelocity24h" INTEGER NOT NULL DEFAULT 0,
    "joinVelocity7d" INTEGER NOT NULL DEFAULT 0,
    "hostCompletionRate" INTEGER NOT NULL DEFAULT 50,
    "freshnessScore" INTEGER NOT NULL DEFAULT 0,
    "discoverScore" INTEGER NOT NULL DEFAULT 0,
    "createdAt" TIMESTAMP(3) NOT NULL,
    "lastActivityAt" TIMESTAMP(3) NOT NULL,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "EqubDiscoverMetrics_pkey" PRIMARY KEY ("equbId")
);

-- CreateIndex
CREATE INDEX "EqubDiscoverMetrics_hostTrustScore_idx" ON "EqubDiscoverMetrics"("hostTrustScore");

-- CreateIndex
CREATE INDEX "EqubDiscoverMetrics_groupTrustLevel_idx" ON "EqubDiscoverMetrics"("groupTrustLevel");

-- CreateIndex
CREATE INDEX "EqubDiscoverMetrics_fillPercent_idx" ON "EqubDiscoverMetrics"("fillPercent");

-- CreateIndex
CREATE INDEX "EqubDiscoverMetrics_discoverScore_idx" ON "EqubDiscoverMetrics"("discoverScore" DESC);

-- CreateIndex
CREATE INDEX "EqubDiscoverMetrics_lastActivityAt_idx" ON "EqubDiscoverMetrics"("lastActivityAt" DESC);

-- CreateIndex
CREATE INDEX "EqubDiscoverMetrics_updatedAt_idx" ON "EqubDiscoverMetrics"("updatedAt" DESC);

-- AddForeignKey
ALTER TABLE "EqubDiscoverMetrics" ADD CONSTRAINT "EqubDiscoverMetrics_equbId_fkey" FOREIGN KEY ("equbId") REFERENCES "EqubGroup"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "EqubDiscoverMetrics" ADD CONSTRAINT "EqubDiscoverMetrics_hostUserId_fkey" FOREIGN KEY ("hostUserId") REFERENCES "User"("id") ON DELETE CASCADE ON UPDATE CASCADE;
