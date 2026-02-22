import 'dart:async';

import 'package:flutter/material.dart';

import '../../../app/theme/app_spacing.dart';
import '../../../shared/copy/fair_draw_copy.dart';
import '../../../shared/kit/kit.dart';
import '../models/member_summary.dart';

class FairDrawShuffleReveal extends StatefulWidget {
  const FairDrawShuffleReveal({
    super.key,
    required this.finalOrder,
    this.autoPlay = true,
    this.onFinished,
  });

  final List<MemberSummary> finalOrder;
  final bool autoPlay;
  final VoidCallback? onFinished;

  @override
  State<FairDrawShuffleReveal> createState() => _FairDrawShuffleRevealState();
}

class _FairDrawShuffleRevealState extends State<FairDrawShuffleReveal> {
  static const _shuffleDuration = Duration(milliseconds: 1500);
  static const _shuffleStep = Duration(milliseconds: 140);

  Timer? _shuffleTimer;
  Timer? _finishTimer;

  var _shuffleTick = 0;
  var _showFinalOrder = false;

  @override
  void initState() {
    super.initState();

    if (widget.autoPlay) {
      _playShuffle();
      return;
    }

    _showFinalOrder = true;
  }

  @override
  void didUpdateWidget(covariant FairDrawShuffleReveal oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.autoPlay && !oldWidget.autoPlay) {
      _playShuffle();
      return;
    }

    if (_listChanged(oldWidget.finalOrder, widget.finalOrder) &&
        !widget.autoPlay) {
      _stopTimers();
      setState(() {
        _showFinalOrder = true;
        _shuffleTick = 0;
      });
    }
  }

  @override
  void dispose() {
    _stopTimers();
    super.dispose();
  }

  bool _listChanged(List<MemberSummary> before, List<MemberSummary> after) {
    if (before.length != after.length) {
      return true;
    }

    for (var i = 0; i < before.length; i += 1) {
      if (before[i].userId != after[i].userId ||
          before[i].displayName != after[i].displayName) {
        return true;
      }
    }

    return false;
  }

  void _playShuffle() {
    if (widget.finalOrder.length < 3) {
      _stopTimers();
      setState(() {
        _showFinalOrder = true;
      });
      widget.onFinished?.call();
      return;
    }

    _stopTimers();
    setState(() {
      _shuffleTick = 0;
      _showFinalOrder = false;
    });

    _shuffleTimer = Timer.periodic(_shuffleStep, (_) {
      if (!mounted) {
        return;
      }
      setState(() => _shuffleTick += 1);
    });

    _finishTimer = Timer(_shuffleDuration, () {
      if (!mounted) {
        return;
      }

      _stopTimers();
      setState(() {
        _showFinalOrder = true;
      });
      widget.onFinished?.call();
    });
  }

  void _stopTimers() {
    _shuffleTimer?.cancel();
    _finishTimer?.cancel();
    _shuffleTimer = null;
    _finishTimer = null;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                _showFinalOrder
                    ? FairDrawCopy.finalOrderLabel
                    : FairDrawCopy.shufflingLabel,
                style: Theme.of(
                  context,
                ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
              ),
            ),
            if (_showFinalOrder && widget.finalOrder.length >= 3)
              KitTertiaryButton(
                label: FairDrawCopy.replayLabel,
                expand: false,
                onPressed: _playShuffle,
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 220),
          switchInCurve: Curves.easeOutCubic,
          switchOutCurve: Curves.easeInCubic,
          child: _showFinalOrder
              ? _FinalOrderList(
                  key: const ValueKey('fair-draw-final-order'),
                  finalOrder: widget.finalOrder,
                )
              : _ShufflingTiles(
                  key: ValueKey('fair-draw-shuffle-$_shuffleTick'),
                  names: _visibleShuffleNames(),
                ),
        ),
      ],
    );
  }

  List<String> _visibleShuffleNames() {
    final total = widget.finalOrder.length;
    if (total == 0) {
      return const <String>[];
    }

    final tileCount = total < 5 ? 5 : (total > 8 ? 8 : total);
    final names = <String>[];

    for (var i = 0; i < tileCount; i += 1) {
      final sourceIndex = (i + (_shuffleTick * (i + 1))) % total;
      names.add(widget.finalOrder[sourceIndex].displayName);
    }

    return names;
  }
}

class _ShufflingTiles extends StatelessWidget {
  const _ShufflingTiles({super.key, required this.names});

  final List<String> names;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var i = 0; i < names.length; i += 1) ...[
          _NameTile(name: names[i]),
          if (i != names.length - 1) const SizedBox(height: AppSpacing.xs),
        ],
      ],
    );
  }
}

class _FinalOrderList extends StatelessWidget {
  const _FinalOrderList({super.key, required this.finalOrder});

  final List<MemberSummary> finalOrder;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var i = 0; i < finalOrder.length; i += 1)
          TweenAnimationBuilder<double>(
            duration: Duration(milliseconds: 220 + (i * 60)),
            curve: Curves.easeOutCubic,
            tween: Tween<double>(begin: 0, end: 1),
            builder: (context, value, child) {
              return Opacity(
                opacity: value,
                child: Transform.translate(
                  offset: Offset(0, (1 - value) * 10),
                  child: child,
                ),
              );
            },
            child: Padding(
              padding: EdgeInsets.only(
                bottom: i == finalOrder.length - 1 ? 0 : AppSpacing.xs,
              ),
              child: _FinalOrderTile(position: i + 1, member: finalOrder[i]),
            ),
          ),
      ],
    );
  }
}

class _FinalOrderTile extends StatelessWidget {
  const _FinalOrderTile({required this.position, required this.member});

  final int position;
  final MemberSummary member;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: AppRadius.mdRounded,
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xs,
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 12,
              backgroundColor: colorScheme.primary.withValues(alpha: 0.14),
              foregroundColor: colorScheme.primary,
              child: Text(
                '$position',
                style: Theme.of(
                  context,
                ).textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w700),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Row(
                children: [
                  KitAvatar(name: member.displayName, size: KitAvatarSize.sm),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      member.displayName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NameTile extends StatelessWidget {
  const _NameTile({required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: AppRadius.mdRounded,
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xs,
        ),
        child: Row(
          children: [
            const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 150),
                child: Text(
                  name,
                  key: ValueKey<String>(name),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
