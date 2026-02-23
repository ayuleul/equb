-- CreateEnum
CREATE TYPE "public"."GroupRuleFrequency" AS ENUM ('WEEKLY', 'MONTHLY', 'CUSTOM_INTERVAL');

-- CreateEnum
CREATE TYPE "public"."GroupRuleFineType" AS ENUM ('NONE', 'FIXED_AMOUNT');

-- CreateEnum
CREATE TYPE "public"."GroupRulePayoutMode" AS ENUM ('LOTTERY', 'AUCTION', 'ROTATION', 'DECISION');

-- CreateEnum
CREATE TYPE "public"."GroupPaymentMethod" AS ENUM ('BANK', 'TELEBIRR', 'CASH_ACK');

-- CreateTable
CREATE TABLE "public"."GroupRules" (
    "groupId" TEXT NOT NULL,
    "contributionAmount" INTEGER NOT NULL,
    "frequency" "public"."GroupRuleFrequency" NOT NULL,
    "customIntervalDays" INTEGER,
    "graceDays" INTEGER NOT NULL DEFAULT 0,
    "fineType" "public"."GroupRuleFineType" NOT NULL DEFAULT 'NONE',
    "fineAmount" INTEGER NOT NULL DEFAULT 0,
    "payoutMode" "public"."GroupRulePayoutMode" NOT NULL,
    "paymentMethods" "public"."GroupPaymentMethod"[] NOT NULL,
    "requiresMemberVerification" BOOLEAN NOT NULL DEFAULT false,
    "strictCollection" BOOLEAN NOT NULL DEFAULT false,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "GroupRules_pkey" PRIMARY KEY ("groupId"),
    CONSTRAINT "GroupRules_graceDays_non_negative" CHECK ("graceDays" >= 0),
    CONSTRAINT "GroupRules_fineAmount_non_negative" CHECK ("fineAmount" >= 0),
    CONSTRAINT "GroupRules_customIntervalDays_valid" CHECK (("frequency" = 'CUSTOM_INTERVAL' AND "customIntervalDays" IS NOT NULL AND "customIntervalDays" >= 1) OR ("frequency" <> 'CUSTOM_INTERVAL' AND "customIntervalDays" IS NULL)),
    CONSTRAINT "GroupRules_finePolicy_valid" CHECK (("fineType" = 'NONE' AND "fineAmount" = 0) OR ("fineType" = 'FIXED_AMOUNT' AND "fineAmount" > 0))
);

-- AddForeignKey
ALTER TABLE "public"."GroupRules" ADD CONSTRAINT "GroupRules_groupId_fkey" FOREIGN KEY ("groupId") REFERENCES "public"."EqubGroup"("id") ON DELETE CASCADE ON UPDATE CASCADE;
