import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/shared/kit/kit_badge.dart';
import 'package:mobile/shared/utils/reputation_presenter.dart';

void main() {
  group('reputationVisualSpec', () {
    test('maps earned pro styling to success tone', () {
      final spec = reputationVisualSpec('Pro');

      expect(spec.tone, KitBadgeTone.success);
    });

    test('maps rising styling without a default new-member label', () {
      final spec = reputationVisualSpec('Rising');

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
