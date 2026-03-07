CREATE TYPE "WinnerSelectionTiming" AS ENUM ('BEFORE_COLLECTION', 'AFTER_COLLECTION');

ALTER TYPE "NotificationType" ADD VALUE IF NOT EXISTS 'PAYOUT_SENT';
ALTER TYPE "NotificationType" ADD VALUE IF NOT EXISTS 'TURN_COMPLETED';

ALTER TABLE "GroupRules"
ADD COLUMN "winnerSelectionTiming" "WinnerSelectionTiming" NOT NULL DEFAULT 'BEFORE_COLLECTION';

ALTER TABLE "EqubCycle"
ADD COLUMN "winnerSelectedAt" TIMESTAMP(3),
ADD COLUMN "payoutSentAt" TIMESTAMP(3),
ADD COLUMN "payoutSentByUserId" TEXT,
ADD COLUMN "payoutReceivedConfirmedAt" TIMESTAMP(3),
ADD COLUMN "payoutReceivedConfirmedByUserId" TEXT;

CREATE TYPE "CycleState_new" AS ENUM (
  'SETUP',
  'COLLECTING',
  'READY_FOR_WINNER_SELECTION',
  'READY_FOR_PAYOUT',
  'PAYOUT_SENT',
  'COMPLETED'
);

ALTER TABLE "EqubCycle"
ALTER COLUMN "state" DROP DEFAULT;

ALTER TABLE "EqubCycle"
ALTER COLUMN "state" TYPE "CycleState_new"
USING (
  CASE "state"::text
    WHEN 'DUE' THEN 'COLLECTING'
    WHEN 'COLLECTING' THEN 'COLLECTING'
    WHEN 'READY_FOR_PAYOUT' THEN 'READY_FOR_PAYOUT'
    WHEN 'DISBURSED' THEN 'PAYOUT_SENT'
    WHEN 'CLOSED' THEN 'COMPLETED'
  END
)::"CycleState_new";

DROP TYPE "CycleState";
ALTER TYPE "CycleState_new" RENAME TO "CycleState";

ALTER TABLE "EqubCycle"
ALTER COLUMN "state" SET DEFAULT 'SETUP';

CREATE INDEX "EqubCycle_payoutSentByUserId_idx" ON "EqubCycle"("payoutSentByUserId");
CREATE INDEX "EqubCycle_payoutReceivedConfirmedByUserId_idx" ON "EqubCycle"("payoutReceivedConfirmedByUserId");

ALTER TABLE "EqubCycle"
ADD CONSTRAINT "EqubCycle_payoutSentByUserId_fkey"
FOREIGN KEY ("payoutSentByUserId") REFERENCES "User"("id")
ON DELETE SET NULL ON UPDATE CASCADE;

ALTER TABLE "EqubCycle"
ADD CONSTRAINT "EqubCycle_payoutReceivedConfirmedByUserId_fkey"
FOREIGN KEY ("payoutReceivedConfirmedByUserId") REFERENCES "User"("id")
ON DELETE SET NULL ON UPDATE CASCADE;
