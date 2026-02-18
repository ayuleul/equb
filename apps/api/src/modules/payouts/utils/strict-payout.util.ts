export interface StrictPayoutEligibility {
  requiredMemberIds: string[];
  confirmedMemberIds: string[];
  missingMemberIds: string[];
  eligible: boolean;
}

export function calculateStrictPayoutEligibility(
  requiredActiveMemberIds: string[],
  confirmedContributionUserIds: string[],
): StrictPayoutEligibility {
  const requiredSet = new Set(requiredActiveMemberIds);
  const confirmedSet = new Set(confirmedContributionUserIds);

  const confirmedMemberIds = [...requiredSet].filter((memberId) =>
    confirmedSet.has(memberId),
  );

  const missingMemberIds = [...requiredSet].filter(
    (memberId) => !confirmedSet.has(memberId),
  );

  return {
    requiredMemberIds: [...requiredSet],
    confirmedMemberIds,
    missingMemberIds,
    eligible: missingMemberIds.length === 0,
  };
}
