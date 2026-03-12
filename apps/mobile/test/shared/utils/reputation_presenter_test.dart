import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/shared/kit/kit_badge.dart';
import 'package:mobile/shared/utils/reputation_presenter.dart';

void main() {
  group('reputationVisualSpec', () {
    test('maps trusted to star styling', () {
      final spec = reputationVisualSpec('Trusted');

      expect(spec.label, 'Trusted');
      expect(spec.icon, Icons.star_rounded);
      expect(spec.tone, KitBadgeTone.success);
    });

    test('maps new users to new member styling', () {
      final spec = reputationVisualSpec('New');

      expect(spec.label, 'New Member');
      expect(spec.tone, KitBadgeTone.warning);
    });
  });

  group('buildTrustProgress', () {
    test('returns reliable to trusted threshold progress', () {
      final progress = buildTrustProgress(74);

      expect(progress.currentLevel, 'Reliable');
      expect(progress.nextLevel, 'Trusted');
      expect(progress.targetScore, 75);
      expect(progress.isMaxLevel, isFalse);
    });

    test('caps elite users at max level', () {
      final progress = buildTrustProgress(92);

      expect(progress.currentLevel, 'Elite');
      expect(progress.isMaxLevel, isTrue);
      expect(progress.progress, 1);
    });
  });

  group('reputationHistoryLabel', () {
    test('maps backend event names to readable copy', () {
      expect(
        reputationHistoryLabel('HOSTED_ROUND_COMPLETED'),
        'Hosted successful Equb',
      );
      expect(
        reputationHistoryLabel('ON_TIME_PAYMENT_VERIFIED'),
        'On-time contribution',
      );
    });
  });
}
