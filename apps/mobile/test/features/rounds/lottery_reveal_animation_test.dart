import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mobile/features/rounds/widgets/lottery_reveal_animation.dart';

void main() {
  test('winner index resolves by participant id instead of display name', () {
    const participants = [
      LotteryDrawParticipant(id: 'u1', displayName: 'Alex'),
      LotteryDrawParticipant(id: 'u2', displayName: 'Alex'),
      LotteryDrawParticipant(id: 'u3', displayName: 'Mimi'),
    ];

    expect(resolveLotteryWinnerIndex(participants, 'u1'), 0);
    expect(resolveLotteryWinnerIndex(participants, 'u2'), 1);
    expect(resolveLotteryWinnerIndex(participants, 'missing'), -1);
  });

  test('target angle aligns the winning segment under the pointer', () {
    final extraAngle = resolveLotteryTargetAngle(
      participantCount: 6,
      winnerIndex: 3,
      currentWheelAngle: math.pi / 4,
      extraRotations: 4,
    );

    final finalAngle = normalizeWheelAngle((math.pi / 4) + extraAngle);
    expect(
      resolveLotteryPointerIndex(participantCount: 6, wheelAngle: finalAngle),
      3,
    );
  });

  testWidgets('wheel starts spinning before the async winner resolves', (
    tester,
  ) async {
    final winnerCompleter = Completer<LotteryDrawWinner?>();

    await tester.pumpWidget(
      MaterialApp(
        home: LotteryRevealAnimationScreen(
          participants: const [
            LotteryDrawParticipant(id: 'u1', displayName: 'Abel'),
            LotteryDrawParticipant(id: 'u2', displayName: 'Rahel'),
            LotteryDrawParticipant(id: 'u3', displayName: 'Miki'),
          ],
          onDrawWinner: () => winnerCompleter.future,
        ),
      ),
    );

    await tester.tap(find.text('Start draw'));
    await tester.pump();

    expect(find.text('Spinning the wheel'), findsOneWidget);
    expect(find.text('Drawing...'), findsOneWidget);

    winnerCompleter.complete(
      const LotteryDrawWinner(participantId: 'u2', displayName: 'Rahel'),
    );

    await tester.pump(const Duration(milliseconds: 1200));
    await tester.pumpAndSettle(const Duration(milliseconds: 200));

    expect(find.text('Rahel'), findsWidgets);
    expect(find.text('Done'), findsOneWidget);
  });
}
