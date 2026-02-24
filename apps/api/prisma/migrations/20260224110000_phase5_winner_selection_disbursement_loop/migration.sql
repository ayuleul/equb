-- AlterTable
ALTER TABLE "public"."EqubCycle"
ADD COLUMN IF NOT EXISTS "selectedWinnerUserId" TEXT,
ADD COLUMN IF NOT EXISTS "selectionMethod" "public"."GroupRulePayoutMode",
ADD COLUMN IF NOT EXISTS "selectionMetadata" JSONB;

-- CreateIndex
CREATE INDEX IF NOT EXISTS "EqubCycle_selectedWinnerUserId_idx" ON "public"."EqubCycle"("selectedWinnerUserId");

-- AddForeignKey
DO $$
BEGIN
  ALTER TABLE "public"."EqubCycle"
    ADD CONSTRAINT "EqubCycle_selectedWinnerUserId_fkey"
    FOREIGN KEY ("selectedWinnerUserId") REFERENCES "public"."User"("id")
    ON DELETE SET NULL ON UPDATE CASCADE;
EXCEPTION
  WHEN duplicate_object THEN NULL;
END $$;
