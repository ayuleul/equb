-- Extend member lifecycle with verification-focused statuses.
ALTER TYPE "public"."MemberStatus" ADD VALUE IF NOT EXISTS 'JOINED';
ALTER TYPE "public"."MemberStatus" ADD VALUE IF NOT EXISTS 'VERIFIED';
ALTER TYPE "public"."MemberStatus" ADD VALUE IF NOT EXISTS 'SUSPENDED';

-- Add verification metadata fields to group memberships.
ALTER TABLE "public"."EqubMember"
ADD COLUMN "verifiedAt" TIMESTAMP(3),
ADD COLUMN "verifiedByUserId" TEXT;

-- Verification actor relation and lookup index.
ALTER TABLE "public"."EqubMember"
ADD CONSTRAINT "EqubMember_verifiedByUserId_fkey"
FOREIGN KEY ("verifiedByUserId")
REFERENCES "public"."User"("id")
ON DELETE SET NULL
ON UPDATE CASCADE;

CREATE INDEX "EqubMember_verifiedByUserId_idx"
ON "public"."EqubMember"("verifiedByUserId");
