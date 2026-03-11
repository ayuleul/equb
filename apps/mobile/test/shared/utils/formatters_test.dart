import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/shared/utils/formatters.dart';

void main() {
  group('getDueCountdown', () {
    final now = DateTime(2026, 3, 10, 9, 30);

    test('returns due in X days for dates more than one day away', () {
      final result = getDueCountdown(DateTime(2026, 3, 15), now: now);

      expect(result.label, 'Due in 5 days');
      expect(result.tone, DueCountdownTone.neutral);
      expect(result.dayDelta, 5);
      expect(result.isOverdue, isFalse);
    });

    test('returns due tomorrow for next-day deadlines', () {
      final result = getDueCountdown(DateTime(2026, 3, 11, 23, 59), now: now);

      expect(result.label, 'Due tomorrow');
      expect(result.tone, DueCountdownTone.warning);
      expect(result.dayDelta, 1);
      expect(result.isOverdue, isFalse);
    });

    test('returns due today for same-day deadlines', () {
      final result = getDueCountdown(DateTime(2026, 3, 10, 1), now: now);

      expect(result.label, 'Due today');
      expect(result.tone, DueCountdownTone.warning);
      expect(result.dayDelta, 0);
      expect(result.isOverdue, isFalse);
    });

    test('returns overdue by X days for past deadlines', () {
      final result = getDueCountdown(DateTime(2026, 3, 8, 23, 59), now: now);

      expect(result.label, 'Overdue by 2 days');
      expect(result.tone, DueCountdownTone.danger);
      expect(result.dayDelta, -2);
      expect(result.isOverdue, isTrue);
    });
  });
}
