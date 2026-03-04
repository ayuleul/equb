DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'StartPolicy') THEN
    CREATE TYPE "public"."StartPolicy" AS ENUM ('WHEN_FULL', 'ON_DATE', 'MANUAL');
  END IF;
END
$$;

ALTER TABLE "public"."GroupRules"
ADD COLUMN IF NOT EXISTS "roundSize" INTEGER,
ADD COLUMN IF NOT EXISTS "startPolicy" "public"."StartPolicy" DEFAULT 'WHEN_FULL',
ADD COLUMN IF NOT EXISTS "startAt" TIMESTAMP(3),
ADD COLUMN IF NOT EXISTS "minToStart" INTEGER;

UPDATE "public"."GroupRules"
SET "roundSize" = COALESCE("roundSize", 2)
WHERE "roundSize" IS NULL;

ALTER TABLE "public"."GroupRules"
ALTER COLUMN "roundSize" SET NOT NULL,
ALTER COLUMN "startPolicy" SET NOT NULL,
ALTER COLUMN "startPolicy" SET DEFAULT 'WHEN_FULL';

-- Backward-compatible mapping for legacy start-config columns if they still exist.
DO $$
BEGIN
  IF EXISTS (
    SELECT 1
    FROM information_schema.columns
    WHERE table_schema = 'public'
      AND table_name = 'GroupRules'
      AND column_name = 'targetMembers'
  ) THEN
    EXECUTE 'UPDATE "public"."GroupRules" SET "roundSize" = COALESCE("roundSize", "targetMembers") WHERE "targetMembers" IS NOT NULL';
  END IF;

  IF EXISTS (
    SELECT 1
    FROM information_schema.columns
    WHERE table_schema = 'public'
      AND table_name = 'GroupRules'
      AND column_name = 'minMembers'
  ) THEN
    EXECUTE 'UPDATE "public"."GroupRules" SET "minToStart" = COALESCE("minToStart", "minMembers") WHERE "minMembers" IS NOT NULL';
  END IF;

  IF EXISTS (
    SELECT 1
    FROM information_schema.columns
    WHERE table_schema = 'public'
      AND table_name = 'GroupRules'
      AND column_name = 'startMode'
  ) THEN
    EXECUTE '
      UPDATE "public"."GroupRules"
      SET "startPolicy" = CASE
        WHEN UPPER("startMode"::text) IN (''ON_DATE'', ''SCHEDULED'') THEN ''ON_DATE''::"public"."StartPolicy"
        WHEN UPPER("startMode"::text) = ''MANUAL'' THEN ''MANUAL''::"public"."StartPolicy"
        ELSE ''WHEN_FULL''::"public"."StartPolicy"
      END
      WHERE "startMode" IS NOT NULL
    ';
  END IF;

  IF EXISTS (
    SELECT 1
    FROM information_schema.columns
    WHERE table_schema = 'public'
      AND table_name = 'GroupRules'
      AND column_name = 'allowStartEarly'
  ) THEN
    EXECUTE '
      UPDATE "public"."GroupRules"
      SET "minToStart" = NULL
      WHERE COALESCE("allowStartEarly", FALSE) = FALSE
    ';
  END IF;
END
$$;

ALTER TABLE "public"."GroupRules"
DROP CONSTRAINT IF EXISTS "GroupRules_round_size_min",
DROP CONSTRAINT IF EXISTS "GroupRules_min_to_start_range",
DROP CONSTRAINT IF EXISTS "GroupRules_start_policy_fields";

ALTER TABLE "public"."GroupRules"
ADD CONSTRAINT "GroupRules_round_size_min" CHECK ("roundSize" >= 2),
ADD CONSTRAINT "GroupRules_min_to_start_range" CHECK (
  "minToStart" IS NULL OR ("minToStart" >= 2 AND "minToStart" <= "roundSize")
),
ADD CONSTRAINT "GroupRules_start_policy_fields" CHECK (
  ("startPolicy" = 'WHEN_FULL' AND "startAt" IS NULL AND "minToStart" IS NULL)
  OR ("startPolicy" = 'ON_DATE' AND "startAt" IS NOT NULL)
  OR ("startPolicy" = 'MANUAL' AND "startAt" IS NULL)
);
