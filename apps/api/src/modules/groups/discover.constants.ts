import { REPUTATION_THRESHOLDS } from '../reputation/reputation.constants';

export const DISCOVER_SECTION_KEYS = {
  recommended: 'recommended_for_you',
  fillingFast: 'filling_fast',
  trustedHosts: 'trusted_hosts',
  newEqubs: 'new_equbs',
  starterEqubs: 'starter_equbs',
} as const;

export const DISCOVER_SECTION_TITLES: Record<string, string> = {
  [DISCOVER_SECTION_KEYS.recommended]: 'Recommended for You',
  [DISCOVER_SECTION_KEYS.fillingFast]: 'Filling Fast',
  [DISCOVER_SECTION_KEYS.trustedHosts]: 'Trusted Hosts',
  [DISCOVER_SECTION_KEYS.newEqubs]: 'New Equbs',
  [DISCOVER_SECTION_KEYS.starterEqubs]: 'Starter Equbs',
};

export const DISCOVER_SCORE_WEIGHTS = {
  hostTrust: 0.35,
  averageMember: 0.2,
  fillPercent: 0.2,
  freshness: 0.15,
  joinVelocity: 0.1,
} as const;

export const DISCOVER_MATCH_WEIGHTS = {
  contribution: 0.5,
  duration: 0.25,
  groupSize: 0.25,
} as const;

export const DISCOVER_RECOMMENDED_BLEND = {
  discoverScore: 0.8,
  matchScore: 0.2,
} as const;

export const DISCOVER_LIMITS = {
  defaultSectionLimit: 6,
  maxSectionLimit: 12,
  metricsStaleAfterMs: 15 * 60 * 1000,
  newEqubWindowDays: 14,
  starterContributionCeiling: 2000,
  starterSizeCeiling: 12,
  starterDurationCeilingDays: 30,
  staleAgeDays: 21,
  staleLowFillPercent: 35,
  lowHostTrustPenalty: 15,
  lowGroupTrustPenalty: 10,
  stalePenalty: 15,
  hostCancellationPenaltyPerEvent: 3,
  hostCancellationPenaltyCap: 12,
  hostDisputePenaltyPerEvent: 4,
  hostDisputePenaltyCap: 12,
} as const;

export const DISCOVER_HIGH_VALUE_CONTRIBUTION_AMOUNT =
  REPUTATION_THRESHOLDS.highValueContributionAmount;

export const DISCOVER_REASON_LABELS = {
  recommended: 'Recommended for you',
  trustedHost: 'Trusted host',
  fillingFast: 'Filling fast',
  almostFull: 'Almost full',
  goodForNewMembers: 'Good for new members',
  newEqub: 'New Equb',
  highTrustGroup: 'High trust group',
  matchesContribution: 'Matches your usual contribution',
} as const;
