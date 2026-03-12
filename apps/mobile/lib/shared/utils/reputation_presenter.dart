import 'package:flutter/material.dart';

import '../../data/models/reputation_model.dart';
import '../kit/kit.dart';

class TrustLevelVisualSpec {
  const TrustLevelVisualSpec({
    required this.label,
    required this.icon,
    required this.tone,
  });

  final String label;
  final IconData icon;
  final KitBadgeTone tone;
}

class TrustProgressModel {
  const TrustProgressModel({
    required this.currentLevel,
    required this.nextLevel,
    required this.currentScore,
    required this.targetScore,
    required this.progress,
    required this.isMaxLevel,
  });

  final String currentLevel;
  final String nextLevel;
  final int currentScore;
  final int targetScore;
  final double progress;
  final bool isMaxLevel;
}

TrustLevelVisualSpec reputationVisualSpec(String trustLevel) {
  switch (trustLevel.trim().toLowerCase()) {
    case 'elite':
      return const TrustLevelVisualSpec(
        label: 'Elite',
        icon: Icons.auto_awesome_rounded,
        tone: KitBadgeTone.success,
      );
    case 'trusted':
      return const TrustLevelVisualSpec(
        label: 'Trusted',
        icon: Icons.star_rounded,
        tone: KitBadgeTone.success,
      );
    case 'reliable':
      return const TrustLevelVisualSpec(
        label: 'Reliable',
        icon: Icons.verified_rounded,
        tone: KitBadgeTone.info,
      );
    case 'risky':
      return const TrustLevelVisualSpec(
        label: 'Risky',
        icon: Icons.warning_amber_rounded,
        tone: KitBadgeTone.danger,
      );
    default:
      return const TrustLevelVisualSpec(
        label: 'New Member',
        icon: Icons.workspace_premium_outlined,
        tone: KitBadgeTone.warning,
      );
  }
}

String reputationHistoryLabel(String eventType) {
  switch (eventType) {
    case 'ROUND_COMPLETED':
      return 'Completed Equb cycle';
    case 'HOSTED_ROUND_COMPLETED':
      return 'Hosted successful Equb';
    case 'ON_TIME_PAYMENT_VERIFIED':
      return 'On-time contribution';
    case 'CONTRIBUTION_LATE_MARKED':
      return 'Late payment';
    case 'CONTRIBUTION_MISSED':
      return 'Missed contribution';
    case 'PAYOUT_RECEIVED':
      return 'Payout received';
    case 'PAYOUT_CONFIRMED':
      return 'Payout confirmed';
    case 'MEMBER_JOINED':
      return 'Joined an Equb';
    case 'GROUP_HOSTED':
      return 'Hosted a public Equb';
    case 'MEMBER_LEFT_GROUP':
      return 'Left an Equb early';
    case 'MEMBER_REMOVED_FROM_GROUP':
      return 'Removed from a group';
    case 'DISPUTE_OPENED':
    case 'HOST_DISPUTE_OPENED':
      return 'Dispute opened';
    case 'DISPUTE_RESOLVED':
    case 'HOST_DISPUTE_RESOLVED':
      return 'Dispute resolved';
    case 'TURN_PARTICIPATED':
      return 'Participated in a turn';
    default:
      return eventType
          .toLowerCase()
          .split('_')
          .map(
            (word) => word.isEmpty
                ? word
                : '${word[0].toUpperCase()}${word.substring(1)}',
          )
          .join(' ');
  }
}

TrustProgressModel buildTrustProgress(int trustScore) {
  const thresholds = <({String level, int start, int target})>[
    (level: 'Risky', start: 0, target: 40),
    (level: 'New', start: 40, target: 60),
    (level: 'Reliable', start: 60, target: 75),
    (level: 'Trusted', start: 75, target: 90),
    (level: 'Elite', start: 90, target: 100),
  ];

  if (trustScore >= 90) {
    return TrustProgressModel(
      currentLevel: 'Elite',
      nextLevel: 'Elite',
      currentScore: trustScore,
      targetScore: 100,
      progress: 1,
      isMaxLevel: true,
    );
  }

  final current = thresholds.firstWhere(
    (item) => trustScore >= item.start && trustScore < item.target,
    orElse: () => thresholds[1],
  );
  final next = thresholds.firstWhere((item) => item.start == current.target);
  final span = (current.target - current.start).clamp(1, 100);
  final progress = ((trustScore - current.start) / span).clamp(0, 1).toDouble();

  return TrustProgressModel(
    currentLevel: current.level,
    nextLevel: next.level,
    currentScore: trustScore,
    targetScore: current.target,
    progress: progress,
    isMaxLevel: false,
  );
}

String formatOnTimeRate(double? value) {
  if (value == null) {
    return 'No payment history yet';
  }
  return '${value.round()}%';
}

String hostRestrictionMessage(ReputationProfileModel profile) {
  final limits = profile.eligibility.allowedPublicEqubLimits;
  if (profile.eligibility.hostTier == null) {
    return 'A trust score of 50 is required to create a public Equb. Your current score: ${profile.trustScore}.';
  }
  if (profile.eligibility.hostTier == 'starter') {
    return 'Your score allows starter public Equbs only: up to ${limits.maxMembers ?? '-'} members, max ${limits.maxContributionAmount ?? '-'} contribution, and one active public Equb.';
  }
  if (profile.eligibility.hostTier == 'standard') {
    return 'You can host standard public Equbs. Reach 75 to unlock high-value public Equbs.';
  }
  return 'You can host high-value public Equbs with full marketplace visibility.';
}
