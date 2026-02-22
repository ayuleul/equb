-- Add notification types for per-turn lottery draw events.
ALTER TYPE "public"."NotificationType" ADD VALUE IF NOT EXISTS 'LOTTERY_WINNER';
ALTER TYPE "public"."NotificationType" ADD VALUE IF NOT EXISTS 'LOTTERY_ANNOUNCEMENT';

-- Add idempotency event id for user-targeted notification events.
ALTER TABLE "public"."Notification"
ADD COLUMN "eventId" TEXT;

CREATE UNIQUE INDEX "Notification_userId_eventId_key"
ON "public"."Notification"("userId", "eventId");
