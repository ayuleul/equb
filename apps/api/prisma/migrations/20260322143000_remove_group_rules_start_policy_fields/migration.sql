ALTER TABLE "GroupRules"
DROP COLUMN "startPolicy",
DROP COLUMN "startAt",
DROP COLUMN "minToStart";

DROP TYPE "public"."StartPolicy";
