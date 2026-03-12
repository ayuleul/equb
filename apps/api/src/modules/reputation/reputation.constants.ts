export const REPUTATION_BASELINE_SCORE = 50;
export const REPUTATION_SCORE_MIN = 0;
export const REPUTATION_SCORE_MAX = 100;
export const REPUTATION_BASE_SCORE_DEFAULT = 55;
export const REPUTATION_ACTIVITY_FACTOR_FLOOR = 0.7;
export const REPUTATION_ACTIVITY_DECAY_PER_MONTH = 0.02;
export const REPUTATION_CONFIDENCE_DENOMINATOR = 10;
export const REPUTATION_MIN_PAYMENT_SAMPLE = 3;
export const REPUTATION_MONTH_IN_MS = 30 * 24 * 60 * 60 * 1000;

export const REPUTATION_COMPONENT_WEIGHTS = {
  payment: 0.4,
  completion: 0.3,
  behavior: 0.2,
  experience: 0.1,
} as const;

export const REPUTATION_THRESHOLDS = {
  starterPublicHostMinScore: 50,
  publicHostMinScore: 60,
  highValuePublicHostMinScore: 75,
  highValuePublicJoinMinScore: 45,
  highValueContributionAmount: 5000,
  highValueMemberCount: 20,
  lendingEligibilityMinScore: 70,
  marketplaceEligibilityMinScore: 65,
  earlyAdopterCutoff: new Date('2026-06-01T00:00:00.000Z'),
} as const;

export const HOST_TIER = {
  starter: 'starter',
  standard: 'standard',
  highValue: 'high_value',
} as const;

export type HostTier = (typeof HOST_TIER)[keyof typeof HOST_TIER];

export const TRUST_LEVEL_RANGES = {
  riskyMax: 39,
  newMax: 59,
  reliableMax: 74,
  trustedMax: 89,
} as const;

export const REPUTATION_EVENT_TYPES = {
  groupHosted: 'GROUP_HOSTED',
  memberJoined: 'MEMBER_JOINED',
  roundCompleted: 'ROUND_COMPLETED',
  hostedRoundCompleted: 'HOSTED_ROUND_COMPLETED',
  turnParticipated: 'TURN_PARTICIPATED',
  onTimePaymentVerified: 'ON_TIME_PAYMENT_VERIFIED',
  contributionLateMarked: 'CONTRIBUTION_LATE_MARKED',
  contributionMissed: 'CONTRIBUTION_MISSED',
  payoutReceived: 'PAYOUT_RECEIVED',
  payoutConfirmed: 'PAYOUT_CONFIRMED',
  memberLeftGroup: 'MEMBER_LEFT_GROUP',
  memberRemovedFromGroup: 'MEMBER_REMOVED_FROM_GROUP',
  disputeOpened: 'DISPUTE_OPENED',
  disputeResolved: 'DISPUTE_RESOLVED',
  hostDisputeOpened: 'HOST_DISPUTE_OPENED',
  hostDisputeResolved: 'HOST_DISPUTE_RESOLVED',
  hostGroupCancelled: 'HOST_GROUP_CANCELLED',
} as const;

export type ReputationEventType =
  (typeof REPUTATION_EVENT_TYPES)[keyof typeof REPUTATION_EVENT_TYPES];
