import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';

import '../../../app/theme/app_spacing.dart';

typedef DrawWinnerCallback = Future<LotteryDrawWinner?> Function();

@immutable
class LotteryWheelMotionProfile {
  const LotteryWheelMotionProfile({
    required this.minimumSpin,
    required this.accelerationDuration,
    required this.initialRevolutionsPerSecond,
    required this.cruiseRevolutionsPerSecond,
    required this.targetSettleSeconds,
  });

  final Duration minimumSpin;
  final Duration accelerationDuration;
  final double initialRevolutionsPerSecond;
  final double cruiseRevolutionsPerSecond;
  final double targetSettleSeconds;
}

class LotteryWheelMotionProfiles {
  const LotteryWheelMotionProfiles._();

  static const quick = LotteryWheelMotionProfile(
    minimumSpin: Duration(milliseconds: 950),
    accelerationDuration: Duration(milliseconds: 180),
    initialRevolutionsPerSecond: 0.9,
    cruiseRevolutionsPerSecond: 4.6,
    targetSettleSeconds: 1.95,
  );

  static const standard = LotteryWheelMotionProfile(
    minimumSpin: Duration(milliseconds: 1200),
    accelerationDuration: Duration(milliseconds: 240),
    initialRevolutionsPerSecond: 0.7,
    cruiseRevolutionsPerSecond: 4.0,
    targetSettleSeconds: 2.2,
  );

  static const ceremony = LotteryWheelMotionProfile(
    minimumSpin: Duration(milliseconds: 1550),
    accelerationDuration: Duration(milliseconds: 320),
    initialRevolutionsPerSecond: 0.55,
    cruiseRevolutionsPerSecond: 3.5,
    targetSettleSeconds: 2.5,
  );
}

@immutable
class LotteryDrawParticipant {
  const LotteryDrawParticipant({required this.id, required this.displayName});

  final String id;
  final String displayName;

  String get safeDisplayName {
    final trimmed = displayName.trim();
    if (trimmed.isNotEmpty) {
      return trimmed;
    }
    return 'Member';
  }
}

@immutable
class LotteryDrawWinner {
  const LotteryDrawWinner({
    required this.participantId,
    required this.displayName,
  });

  final String participantId;
  final String displayName;

  String get safeDisplayName {
    final trimmed = displayName.trim();
    if (trimmed.isNotEmpty) {
      return trimmed;
    }
    return 'Selected member';
  }
}

Future<bool> showLotteryRevealAnimation({
  required BuildContext context,
  required List<LotteryDrawParticipant> participants,
  required DrawWinnerCallback onDrawWinner,
  LotteryWheelMotionProfile motionProfile = LotteryWheelMotionProfiles.standard,
}) async {
  final normalizedParticipants = _normalizeParticipants(participants);
  if (normalizedParticipants.isEmpty) {
    return false;
  }

  final result = await Navigator.of(context).push<bool>(
    MaterialPageRoute<bool>(
      fullscreenDialog: true,
      builder: (_) => LotteryRevealAnimationScreen(
        participants: normalizedParticipants,
        onDrawWinner: onDrawWinner,
        motionProfile: motionProfile,
      ),
    ),
  );

  return result == true;
}

List<LotteryDrawParticipant> _normalizeParticipants(
  List<LotteryDrawParticipant> participants,
) {
  final normalized = <LotteryDrawParticipant>[];
  final seenIds = <String>{};
  for (final participant in participants) {
    final id = participant.id.trim();
    if (id.isEmpty || !seenIds.add(id)) {
      continue;
    }
    normalized.add(
      LotteryDrawParticipant(id: id, displayName: participant.safeDisplayName),
    );
  }
  return normalized;
}

enum _LotteryPhase { ready, spinning, settling, revealed, failed }

class LotteryRevealAnimationScreen extends StatefulWidget {
  const LotteryRevealAnimationScreen({
    super.key,
    required this.participants,
    required this.onDrawWinner,
    this.motionProfile = LotteryWheelMotionProfiles.standard,
  });

  final List<LotteryDrawParticipant> participants;
  final DrawWinnerCallback onDrawWinner;
  final LotteryWheelMotionProfile motionProfile;

  @override
  State<LotteryRevealAnimationScreen> createState() =>
      _LotteryRevealAnimationScreenState();
}

class _LotteryRevealAnimationScreenState
    extends State<LotteryRevealAnimationScreen>
    with TickerProviderStateMixin {
  static const _celebrationDuration = Duration(milliseconds: 1100);
  static const _tau = math.pi * 2;

  late final AnimationController _celebrationController;
  late final Ticker _spinTicker;
  late final math.Random _random;

  _LotteryPhase _phase = _LotteryPhase.ready;
  LotteryDrawWinner? _winner;
  String? _errorMessage;
  double _wheelAngle = 0;
  double _currentVelocity = 0;
  Duration? _lastTickElapsed;
  double _phaseElapsedSeconds = 0;
  _WheelSettlePlan? _settlePlan;

  @override
  void initState() {
    super.initState();
    _random = math.Random();
    _spinTicker = createTicker(_handleSpinTick);
    _celebrationController = AnimationController(
      vsync: this,
      duration: _celebrationDuration,
    );
  }

  @override
  void dispose() {
    _spinTicker.dispose();
    _celebrationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final size = MediaQuery.of(context).size;
    final wheelSize = math.min(size.width - (AppSpacing.lg * 2), 360.0);
    final winnerIndex = _winner == null
        ? null
        : resolveLotteryWinnerIndex(
            widget.participants,
            _winner!.participantId,
          );
    final revealedWinnerIndex = _phase == _LotteryPhase.revealed
        ? winnerIndex
        : null;
    final revealProgress = _phase == _LotteryPhase.revealed
        ? Curves.easeOutBack.transform(_celebrationController.value)
        : 0.0;
    final headline = switch (_phase) {
      _LotteryPhase.ready => 'Ready to draw',
      _LotteryPhase.spinning => 'Spinning the wheel',
      _LotteryPhase.settling => 'Spinning the wheel',
      _LotteryPhase.revealed => _winner?.safeDisplayName ?? 'Winner selected',
      _LotteryPhase.failed => 'Draw failed',
    };

    final subtitle = switch (_phase) {
      _LotteryPhase.ready =>
        'Start the draw and the wheel will spin immediately while the result is confirmed.',
      _LotteryPhase.spinning =>
        'The wheel is live. It will settle precisely as soon as the winner is confirmed.',
      _LotteryPhase.settling =>
        'The wheel is still spinning. It is easing into the final winner alignment.',
      _LotteryPhase.revealed =>
        '${_winner?.safeDisplayName ?? 'Selected member'} won this turn.',
      _LotteryPhase.failed =>
        _errorMessage ?? 'Unable to complete the draw right now. Try again.',
    };

    final actionLabel = switch (_phase) {
      _LotteryPhase.ready => 'Start draw',
      _LotteryPhase.spinning => 'Drawing...',
      _LotteryPhase.settling => 'Drawing...',
      _LotteryPhase.revealed => 'Done',
      _LotteryPhase.failed => 'Try again',
    };

    final actionEnabled =
        _phase == _LotteryPhase.ready ||
        _phase == _LotteryPhase.revealed ||
        _phase == _LotteryPhase.failed;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              colorScheme.primary.withValues(alpha: 0.08),
              colorScheme.surface,
              colorScheme.surfaceContainerLowest,
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.md,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        _RoundIconButton(
                          icon: Icons.chevron_left_rounded,
                          onPressed:
                              _phase == _LotteryPhase.ready ||
                                  _phase == _LotteryPhase.failed
                              ? () => Navigator.of(context).pop(false)
                              : null,
                        ),
                        const Spacer(),
                        Text(
                          'Lottery Draw',
                          style: theme.textTheme.labelLarge?.copyWith(
                            color: colorScheme.primary,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    Text(
                      headline,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        height: 0.98,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      subtitle,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    Expanded(
                      child: Center(
                        child: RepaintBoundary(
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              _WheelAura(
                                size: wheelSize + 40,
                                revealProgress: revealProgress,
                              ),
                              SizedBox(
                                width: wheelSize,
                                height: wheelSize,
                                child: CustomPaint(
                                  painter: _LotteryWheelPainter(
                                    colorScheme: colorScheme,
                                    textStyle:
                                        theme.textTheme.labelMedium ??
                                        const TextStyle(),
                                    participants: widget.participants,
                                    wheelAngle: _wheelAngle,
                                    winnerIndex: revealedWinnerIndex,
                                    revealProgress: revealProgress,
                                  ),
                                ),
                              ),
                              Positioned(
                                top: -8,
                                child: IgnorePointer(
                                  child: _WheelPointer(
                                    colorScheme: colorScheme,
                                    revealProgress: revealProgress,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 220),
                      child: _StatusPill(
                        key: ValueKey<String>(_phase.name),
                        colorScheme: colorScheme,
                        label: switch (_phase) {
                          _LotteryPhase.ready => 'Waiting to start',
                          _LotteryPhase.spinning =>
                            'Wheel at ${(_currentVelocity / _tau).toStringAsFixed(1)} rps',
                          _LotteryPhase.settling => 'Wheel easing to target',
                          _LotteryPhase.revealed => 'Winner locked',
                          _LotteryPhase.failed => 'Ready to retry',
                        },
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    FilledButton(
                      onPressed: actionEnabled ? _handlePrimaryAction : null,
                      style: FilledButton.styleFrom(
                        minimumSize: const Size.fromHeight(56),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                      child: Text(actionLabel),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handlePrimaryAction() async {
    if (_phase == _LotteryPhase.revealed) {
      Navigator.of(context).pop(true);
      return;
    }
    if (_phase != _LotteryPhase.ready && _phase != _LotteryPhase.failed) {
      return;
    }

    HapticFeedback.lightImpact();
    final stopwatch = Stopwatch()..start();
    _celebrationController.reset();
    _lastTickElapsed = null;
    _phaseElapsedSeconds = 0;
    _settlePlan = null;
    _winner = null;
    _errorMessage = null;

    setState(() {
      _phase = _LotteryPhase.spinning;
      _wheelAngle = _random.nextDouble() * _tau;
      _currentVelocity =
          widget.motionProfile.initialRevolutionsPerSecond * _tau;
    });

    if (!_spinTicker.isActive) {
      _spinTicker.start();
    }

    LotteryDrawWinner? winner;
    Object? error;
    try {
      winner = await widget.onDrawWinner();
    } catch (exception) {
      error = exception;
    }

    final remainingSpin = widget.motionProfile.minimumSpin - stopwatch.elapsed;
    if (remainingSpin > Duration.zero) {
      await Future<void>.delayed(remainingSpin);
    }
    if (!mounted) {
      return;
    }

    if (winner == null) {
      _enterFailure(
        error == null
            ? 'Unable to confirm the winner.'
            : 'Unable to complete the draw right now.',
      );
      return;
    }

    final winnerIndex = resolveLotteryWinnerIndex(
      widget.participants,
      winner.participantId,
    );
    if (winnerIndex < 0) {
      _enterFailure('The selected winner is not in the participant list.');
      return;
    }

    _winner = LotteryDrawWinner(
      participantId: winner.participantId.trim(),
      displayName: winner.safeDisplayName,
    );
    await _beginSettle(winnerIndex);
  }

  void _handleSpinTick(Duration elapsed) {
    if (!mounted ||
        (_phase != _LotteryPhase.spinning &&
            _phase != _LotteryPhase.settling)) {
      return;
    }

    final dtSeconds = _lastTickElapsed == null
        ? 0.0
        : (elapsed - _lastTickElapsed!).inMicroseconds /
              Duration.microsecondsPerSecond;
    _lastTickElapsed = elapsed;
    _phaseElapsedSeconds += dtSeconds;

    if (_phase == _LotteryPhase.spinning) {
      final accelerationProgress =
          (_phaseElapsedSeconds /
                  (widget.motionProfile.accelerationDuration.inMilliseconds /
                      1000))
              .clamp(0.0, 1.0);
      final curveProgress = Curves.easeInOutCubic.transform(
        accelerationProgress,
      );
      final initialVelocity =
          widget.motionProfile.initialRevolutionsPerSecond * _tau;
      final cruiseVelocity =
          widget.motionProfile.cruiseRevolutionsPerSecond * _tau;
      final targetVelocity =
          initialVelocity +
          ((cruiseVelocity - initialVelocity) * curveProgress);
      setState(() {
        _currentVelocity = targetVelocity;
        _wheelAngle += targetVelocity * dtSeconds;
      });
      return;
    }

    final settlePlan = _settlePlan;
    if (settlePlan == null) {
      return;
    }
    final previousDistance = settlePlan.distanceAt(
      _phaseElapsedSeconds - dtSeconds,
    );
    final nextDistance = settlePlan.distanceAt(_phaseElapsedSeconds);
    final deltaDistance = nextDistance - previousDistance;
    final nextVelocity = settlePlan.velocityAt(_phaseElapsedSeconds);
    final isDone = settlePlan.isDone(_phaseElapsedSeconds);

    setState(() {
      _wheelAngle += deltaDistance;
      _currentVelocity = nextVelocity;
    });

    if (isDone) {
      _spinTicker.stop();
      HapticFeedback.mediumImpact();
      setState(() {
        _phase = _LotteryPhase.revealed;
        _currentVelocity = 0;
        _settlePlan = null;
      });
      _celebrationController.forward(from: 0);
    }
  }

  Future<void> _beginSettle(int winnerIndex) async {
    final startAngle = _wheelAngle;
    final startAngleNormalized = normalizeWheelAngle(startAngle);
    final targetDistance = resolveLotterySettleDistance(
      participantCount: widget.participants.length,
      winnerIndex: winnerIndex,
      currentWheelAngle: startAngleNormalized,
      currentVelocity: _currentVelocity,
      targetDurationSeconds:
          widget.motionProfile.targetSettleSeconds +
          (_random.nextDouble() * 0.12),
    );
    setState(() {
      _phase = _LotteryPhase.settling;
      _phaseElapsedSeconds = 0;
      _settlePlan = _WheelSettlePlan(
        distance: targetDistance,
        initialVelocity: _currentVelocity,
      );
    });
  }

  void _enterFailure(String message) {
    _spinTicker.stop();
    setState(() {
      _phase = _LotteryPhase.failed;
      _errorMessage = message;
      _currentVelocity = 0;
      _settlePlan = null;
    });
  }
}

class _WheelSettlePlan {
  const _WheelSettlePlan({
    required this.distance,
    required this.initialVelocity,
  }) : deceleration = distance <= 0
           ? 1
           : (initialVelocity * initialVelocity) / (2 * distance),
       durationSeconds = distance <= 0 || initialVelocity <= 0
           ? 0
           : (2 * distance) / initialVelocity;

  final double distance;
  final double initialVelocity;
  final double deceleration;
  final double durationSeconds;

  double distanceAt(double timeSeconds) {
    if (durationSeconds <= 0) {
      return distance;
    }
    final t = timeSeconds.clamp(0, durationSeconds);
    return math.min(
      distance,
      (initialVelocity * t) - (0.5 * deceleration * t * t),
    );
  }

  double velocityAt(double timeSeconds) {
    if (durationSeconds <= 0) {
      return 0;
    }
    final t = timeSeconds.clamp(0, durationSeconds);
    return math.max(0, initialVelocity - (deceleration * t));
  }

  bool isDone(double timeSeconds) => timeSeconds >= durationSeconds;
}

@visibleForTesting
double normalizeWheelAngle(double angle) {
  final normalized = angle % _LotteryRevealAnimationScreenState._tau;
  if (normalized < 0) {
    return normalized + _LotteryRevealAnimationScreenState._tau;
  }
  return normalized;
}

@visibleForTesting
int resolveLotteryWinnerIndex(
  List<LotteryDrawParticipant> participants,
  String participantId,
) {
  final normalizedId = participantId.trim();
  return participants.indexWhere(
    (participant) => participant.id == normalizedId,
  );
}

@visibleForTesting
double resolveLotteryTargetAngle({
  required int participantCount,
  required int winnerIndex,
  required double currentWheelAngle,
  int extraRotations = 4,
}) {
  if (participantCount <= 0 ||
      winnerIndex < 0 ||
      winnerIndex >= participantCount) {
    return 0;
  }
  final sweep = _LotteryRevealAnimationScreenState._tau / participantCount;
  final winnerTarget = normalizeWheelAngle(
    (_LotteryRevealAnimationScreenState._tau - (sweep * winnerIndex)) %
        _LotteryRevealAnimationScreenState._tau,
  );
  final current = normalizeWheelAngle(currentWheelAngle);
  final delta = normalizeWheelAngle(winnerTarget - current);
  return delta + (extraRotations * _LotteryRevealAnimationScreenState._tau);
}

@visibleForTesting
double resolveLotterySettleDistance({
  required int participantCount,
  required int winnerIndex,
  required double currentWheelAngle,
  required double currentVelocity,
  required double targetDurationSeconds,
}) {
  if (participantCount <= 0 || currentVelocity <= 0) {
    return 0;
  }
  final alignmentDelta = resolveLotteryTargetAngle(
    participantCount: participantCount,
    winnerIndex: winnerIndex,
    currentWheelAngle: currentWheelAngle,
    extraRotations: 0,
  );
  final desiredDistance =
      currentVelocity * (targetDurationSeconds.clamp(1.6, 2.4) / 2);
  final fullRotation = _LotteryRevealAnimationScreenState._tau;
  final extraRotations = math.max(
    0,
    ((desiredDistance - alignmentDelta) / fullRotation).ceil(),
  );
  return alignmentDelta + (extraRotations * fullRotation);
}

@visibleForTesting
int resolveLotteryPointerIndex({
  required int participantCount,
  required double wheelAngle,
}) {
  if (participantCount <= 0) {
    return 0;
  }
  final sweep = _LotteryRevealAnimationScreenState._tau / participantCount;
  final normalized = normalizeWheelAngle(wheelAngle);
  final pointerAngle = normalizeWheelAngle(
    _LotteryRevealAnimationScreenState._tau - normalized,
  );
  return (pointerAngle / sweep).floor() % participantCount;
}

class _LotteryWheelPainter extends CustomPainter {
  _LotteryWheelPainter({
    required this.colorScheme,
    required this.textStyle,
    required this.participants,
    required this.wheelAngle,
    required this.winnerIndex,
    required this.revealProgress,
  });

  final ColorScheme colorScheme;
  final TextStyle textStyle;
  final List<LotteryDrawParticipant> participants;
  final double wheelAngle;
  final int? winnerIndex;
  final double revealProgress;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);
    final sweep = _LotteryRevealAnimationScreenState._tau / participants.length;
    const baseStartAngle = -math.pi / 2;

    final shadowPaint = Paint()
      ..color = colorScheme.shadow.withValues(alpha: 0.08)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 18);
    canvas.drawCircle(center.translate(0, 8), radius * 0.98, shadowPaint);

    final ringPaint = Paint()
      ..style = PaintingStyle.fill
      ..shader = RadialGradient(
        colors: [colorScheme.surface, colorScheme.surfaceContainerHigh],
      ).createShader(rect);
    canvas.drawCircle(center, radius, ringPaint);

    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(wheelAngle);

    for (var index = 0; index < participants.length; index++) {
      final start = baseStartAngle - (sweep / 2) + (index * sweep);
      final isWinner = winnerIndex == index;
      final segmentPath = Path()
        ..moveTo(0, 0)
        ..arcTo(
          Rect.fromCircle(center: Offset.zero, radius: radius * 0.94),
          start,
          sweep,
          false,
        )
        ..close();

      final fillPaint = Paint()
        ..style = PaintingStyle.fill
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: _segmentColors(
            colorScheme: colorScheme,
            index: index,
            isWinner: isWinner,
            revealProgress: revealProgress,
          ),
        ).createShader(Rect.fromCircle(center: Offset.zero, radius: radius));
      final strokePaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = isWinner ? 2.4 : 1.3
        ..color = isWinner
            ? colorScheme.onPrimary
            : colorScheme.outline.withValues(alpha: 0.32);

      canvas.drawPath(segmentPath, fillPaint);
      canvas.drawPath(segmentPath, strokePaint);

      final segmentCenterAngle = start + (sweep / 2);
      final badgeCenter = Offset(
        math.cos(segmentCenterAngle) * radius * 0.58,
        math.sin(segmentCenterAngle) * radius * 0.58,
      );
      final badgeRadius = radius * (isWinner ? 0.13 : 0.115);
      final badgePaint = Paint()
        ..color = colorScheme.surface.withValues(alpha: isWinner ? 0.98 : 0.92);
      canvas.drawCircle(badgeCenter, badgeRadius, badgePaint);

      final initials = _initialsForName(participants[index].safeDisplayName);
      final initialsPainter = TextPainter(
        text: TextSpan(
          text: initials,
          style: textStyle.copyWith(
            fontWeight: FontWeight.w800,
            color: colorScheme.onSurface,
            fontSize: badgeRadius * 0.58,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      initialsPainter.paint(
        canvas,
        badgeCenter -
            Offset(initialsPainter.width / 2, initialsPainter.height / 2),
      );
    }

    canvas.restore();

    final rimPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = radius * 0.06
      ..shader = SweepGradient(
        colors: [
          colorScheme.primary.withValues(alpha: 0.24),
          colorScheme.secondary.withValues(alpha: 0.22),
          colorScheme.tertiary.withValues(alpha: 0.22),
          colorScheme.primary.withValues(alpha: 0.24),
        ],
      ).createShader(rect);
    canvas.drawCircle(center, radius * 0.97, rimPaint);
    canvas.drawCircle(
      center,
      radius * 0.77,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2
        ..color = colorScheme.outline.withValues(alpha: 0.16),
    );
  }

  @override
  bool shouldRepaint(covariant _LotteryWheelPainter oldDelegate) {
    return oldDelegate.wheelAngle != wheelAngle ||
        oldDelegate.winnerIndex != winnerIndex ||
        oldDelegate.revealProgress != revealProgress ||
        !listEquals(oldDelegate.participants, participants) ||
        oldDelegate.colorScheme != colorScheme ||
        oldDelegate.textStyle != textStyle;
  }

  List<Color> _segmentColors({
    required ColorScheme colorScheme,
    required int index,
    required bool isWinner,
    required double revealProgress,
  }) {
    final palettes = <List<Color>>[
      [
        colorScheme.primaryContainer.withValues(alpha: 0.94),
        colorScheme.primary.withValues(alpha: 0.68),
      ],
      [
        colorScheme.secondaryContainer.withValues(alpha: 0.92),
        colorScheme.secondary.withValues(alpha: 0.64),
      ],
      [
        colorScheme.tertiaryContainer.withValues(alpha: 0.9),
        colorScheme.tertiary.withValues(alpha: 0.62),
      ],
      [
        colorScheme.primary.withValues(alpha: 0.78),
        colorScheme.secondary.withValues(alpha: 0.58),
      ],
      [
        colorScheme.secondary.withValues(alpha: 0.72),
        colorScheme.tertiaryContainer.withValues(alpha: 0.78),
      ],
      [
        colorScheme.tertiary.withValues(alpha: 0.66),
        colorScheme.primaryContainer.withValues(alpha: 0.86),
      ],
    ];
    if (isWinner) {
      return [
        Color.lerp(
              colorScheme.tertiary.withValues(alpha: 0.85),
              colorScheme.primary,
              revealProgress,
            ) ??
            colorScheme.primary,
        colorScheme.primary.withValues(alpha: 0.88),
      ];
    }
    return palettes[index % palettes.length];
  }
}

class _WheelPointer extends StatelessWidget {
  const _WheelPointer({
    required this.colorScheme,
    required this.revealProgress,
  });

  final ColorScheme colorScheme;
  final double revealProgress;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerLowest,
            shape: BoxShape.circle,
            border: Border.all(color: colorScheme.onSurface, width: 3.5),
            boxShadow: [
              BoxShadow(
                color: colorScheme.shadow.withValues(alpha: 0.18),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Icon(
            Icons.adjust_rounded,
            color: colorScheme.onSurface,
            size: 24,
          ),
        ),
        CustomPaint(
          size: const Size(30, 24),
          painter: _PointerTipPainter(colorScheme),
        ),
      ],
    );
  }
}

class _PointerTipPainter extends CustomPainter {
  const _PointerTipPainter(this.colorScheme);

  final ColorScheme colorScheme;

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(size.width / 2, size.height)
      ..lineTo(0, 0)
      ..lineTo(size.width, 0)
      ..close();
    canvas.drawPath(
      path,
      Paint()
        ..color = colorScheme.onSurface
        ..style = PaintingStyle.fill,
    );
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5
        ..color = colorScheme.surfaceContainerLowest,
    );
  }

  @override
  bool shouldRepaint(covariant _PointerTipPainter oldDelegate) => false;
}

class _WheelAura extends StatelessWidget {
  const _WheelAura({required this.size, required this.revealProgress});

  final double size;
  final double revealProgress;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              colorScheme.primary.withValues(
                alpha: 0.06 + (revealProgress * 0.1),
              ),
              colorScheme.primary.withValues(alpha: 0.0),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({
    super.key,
    required this.colorScheme,
    required this.label,
  });

  final ColorScheme colorScheme;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: Theme.of(
          context,
        ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700),
      ),
    );
  }
}

class _RoundIconButton extends StatelessWidget {
  const _RoundIconButton({required this.icon, required this.onPressed});

  final IconData icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLowest,
        shape: BoxShape.circle,
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: IconButton(onPressed: onPressed, icon: Icon(icon, size: 20)),
    );
  }
}

String _initialsForName(String name) {
  final parts = name
      .trim()
      .split(RegExp(r'\s+'))
      .where((part) => part.isNotEmpty)
      .take(2)
      .toList(growable: false);
  if (parts.isEmpty) {
    return 'M';
  }
  if (parts.length == 1) {
    return parts.first.substring(0, 1).toUpperCase();
  }
  return '${parts.first.substring(0, 1)}${parts.last.substring(0, 1)}'
      .toUpperCase();
}
