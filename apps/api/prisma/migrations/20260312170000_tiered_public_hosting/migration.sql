ALTER TABLE "EqubGroup"
ADD COLUMN "hostTier" TEXT,
ADD COLUMN "hostReputationAtCreation" INTEGER;

CREATE INDEX "EqubGroup_hostTier_idx" ON "EqubGroup"("hostTier");
