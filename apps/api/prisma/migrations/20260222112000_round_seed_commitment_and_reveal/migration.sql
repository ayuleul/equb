ALTER TABLE "public"."EqubRound"
ADD COLUMN "drawSeedHash" TEXT,
ADD COLUMN "drawSeedCiphertext" TEXT,
ADD COLUMN "drawSeedRevealedAt" TIMESTAMP(3),
ADD COLUMN "drawSeedRevealedByUserId" TEXT;

CREATE EXTENSION IF NOT EXISTS pgcrypto;

UPDATE "public"."EqubRound"
SET "drawSeedHash" = encode(digest(("id" || ':' || "groupId" || ':' || "roundNo")::text, 'sha256'), 'hex')
WHERE "drawSeedHash" IS NULL;

ALTER TABLE "public"."EqubRound"
ALTER COLUMN "drawSeedHash" SET NOT NULL;

CREATE INDEX "EqubRound_drawSeedRevealedByUserId_idx" ON "public"."EqubRound"("drawSeedRevealedByUserId");

ALTER TABLE "public"."EqubRound"
ADD CONSTRAINT "EqubRound_drawSeedRevealedByUserId_fkey"
FOREIGN KEY ("drawSeedRevealedByUserId") REFERENCES "public"."User"("id")
ON DELETE SET NULL ON UPDATE CASCADE;
