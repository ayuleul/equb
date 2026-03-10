import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/bootstrap.dart';
import '../../app/theme/app_spacing.dart';
import '../../app/theme/app_theme_extensions.dart';
import '../../data/realtime/realtime_client.dart';

class RealtimeHeaderStatus extends ConsumerStatefulWidget {
  const RealtimeHeaderStatus({super.key});

  @override
  ConsumerState<RealtimeHeaderStatus> createState() =>
      _RealtimeHeaderStatusState();
}

class _RealtimeHeaderStatusState extends ConsumerState<RealtimeHeaderStatus> {
  static const _connectingDelay = Duration(seconds: 1);

  Timer? _connectingTimer;
  RealtimeConnectionStatus? _visibleStatus;

  @override
  void dispose() {
    _connectingTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final status =
        ref.watch(realtimeConnectionStatusProvider).valueOrNull ??
        RealtimeConnectionStatus.idle;
    _syncVisibleStatus(status);

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 180),
      child: switch (_visibleStatus) {
        RealtimeConnectionStatus.connecting => _HeaderStatusChip(
          key: const ValueKey('realtime-header-connecting'),
          icon: Icons.sync_rounded,
          label: 'Connecting...',
          backgroundColor: context.semanticColors.infoContainer,
          foregroundColor: context.semanticColors.onInfoContainer,
          borderColor: context.semanticColors.info.withValues(alpha: 0.22),
          showSpinner: true,
        ),
        RealtimeConnectionStatus.disconnected => _HeaderStatusChip(
          key: const ValueKey('realtime-header-disconnected'),
          icon: Icons.sync_problem_rounded,
          label: 'Disconnected',
          backgroundColor: context.semanticColors.warningContainer,
          foregroundColor: context.semanticColors.onWarningContainer,
          borderColor: context.semanticColors.warning.withValues(alpha: 0.26),
        ),
        _ => const SizedBox.shrink(),
      },
    );
  }

  void _syncVisibleStatus(RealtimeConnectionStatus status) {
    if (status == RealtimeConnectionStatus.connected ||
        status == RealtimeConnectionStatus.idle) {
      _connectingTimer?.cancel();
      _connectingTimer = null;
      if (_visibleStatus != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) {
            return;
          }
          setState(() => _visibleStatus = null);
        });
      }
      return;
    }

    if (status == RealtimeConnectionStatus.disconnected) {
      _connectingTimer?.cancel();
      _connectingTimer = null;
      if (_visibleStatus != status) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) {
            return;
          }
          setState(() => _visibleStatus = status);
        });
      }
      return;
    }

    if (_visibleStatus == RealtimeConnectionStatus.connecting ||
        _connectingTimer != null) {
      return;
    }

    _connectingTimer = Timer(_connectingDelay, () {
      _connectingTimer = null;
      if (!mounted) {
        return;
      }
      final latest =
          ref.read(realtimeConnectionStatusProvider).valueOrNull ??
          RealtimeConnectionStatus.idle;
      if (latest == RealtimeConnectionStatus.connecting) {
        setState(() => _visibleStatus = RealtimeConnectionStatus.connecting);
      }
    });
  }
}

class RealtimeStatusBanner extends ConsumerStatefulWidget {
  const RealtimeStatusBanner({super.key});

  @override
  ConsumerState<RealtimeStatusBanner> createState() =>
      _RealtimeStatusBannerState();
}

class _RealtimeStatusBannerState extends ConsumerState<RealtimeStatusBanner> {
  static const _connectingDelay = Duration(seconds: 1);

  Timer? _connectingTimer;
  RealtimeConnectionStatus? _visibleStatus;

  @override
  void dispose() {
    _connectingTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final status =
        ref.watch(realtimeConnectionStatusProvider).valueOrNull ??
        RealtimeConnectionStatus.idle;
    _syncVisibleStatus(status);

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 180),
      child: switch (_visibleStatus) {
        RealtimeConnectionStatus.connecting => _BannerStrip(
          key: const ValueKey('realtime-connecting'),
          icon: Icons.sync_rounded,
          message: 'Connecting...',
          backgroundColor: context.semanticColors.infoContainer,
          foregroundColor: context.semanticColors.onInfoContainer,
          borderColor: context.semanticColors.info.withValues(alpha: 0.22),
        ),
        RealtimeConnectionStatus.disconnected => _BannerStrip(
          key: const ValueKey('realtime-disconnected'),
          icon: Icons.sync_problem_rounded,
          message: 'Disconnected',
          backgroundColor: context.semanticColors.warningContainer,
          foregroundColor: context.semanticColors.onWarningContainer,
          borderColor: context.semanticColors.warning.withValues(alpha: 0.26),
        ),
        _ => const SizedBox.shrink(),
      },
    );
  }

  void _syncVisibleStatus(RealtimeConnectionStatus status) {
    if (status == RealtimeConnectionStatus.connected ||
        status == RealtimeConnectionStatus.idle) {
      _connectingTimer?.cancel();
      _connectingTimer = null;
      if (_visibleStatus != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) {
            return;
          }
          setState(() => _visibleStatus = null);
        });
      }
      return;
    }

    if (status == RealtimeConnectionStatus.disconnected) {
      _connectingTimer?.cancel();
      _connectingTimer = null;
      if (_visibleStatus != status) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) {
            return;
          }
          setState(() => _visibleStatus = status);
        });
      }
      return;
    }

    if (_visibleStatus == RealtimeConnectionStatus.connecting ||
        _connectingTimer != null) {
      return;
    }

    _connectingTimer = Timer(_connectingDelay, () {
      _connectingTimer = null;
      if (!mounted) {
        return;
      }
      final latest =
          ref.read(realtimeConnectionStatusProvider).valueOrNull ??
          RealtimeConnectionStatus.idle;
      if (latest == RealtimeConnectionStatus.connecting) {
        setState(() => _visibleStatus = RealtimeConnectionStatus.connecting);
      }
    });
  }
}

class _HeaderStatusChip extends StatelessWidget {
  const _HeaderStatusChip({
    super.key,
    required this.icon,
    required this.label,
    required this.backgroundColor,
    required this.foregroundColor,
    required this.borderColor,
    this.showSpinner = false,
  });

  final IconData icon;
  final String label;
  final Color backgroundColor;
  final Color foregroundColor;
  final Color borderColor;
  final bool showSpinner;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: ShapeDecoration(
        color: backgroundColor,
        shape: StadiumBorder(side: BorderSide(color: borderColor)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xs,
          vertical: 4,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: foregroundColor, size: 13),
            const SizedBox(width: 4),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: foregroundColor,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.1,
              ),
            ),
            if (showSpinner) ...[
              const SizedBox(width: 4),
              SizedBox(
                width: 10,
                height: 10,
                child: CircularProgressIndicator(
                  strokeWidth: 1.6,
                  valueColor: AlwaysStoppedAnimation<Color>(foregroundColor),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _BannerStrip extends StatelessWidget {
  const _BannerStrip({
    super.key,
    required this.icon,
    required this.message,
    required this.backgroundColor,
    required this.foregroundColor,
    required this.borderColor,
  });

  final IconData icon;
  final String message;
  final Color backgroundColor;
  final Color foregroundColor;
  final Color borderColor;

  @override
  Widget build(BuildContext context) {
    final brand = context.brand;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: backgroundColor,
        border: Border(bottom: BorderSide(color: borderColor)),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            backgroundColor,
            brand.cardAccentStart.withValues(alpha: 0.035),
          ],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.xs,
        ),
        child: Row(
          children: [
            Icon(icon, color: foregroundColor, size: 16),
            const SizedBox(width: AppSpacing.xs),
            Expanded(
              child: Text(
                message,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: foregroundColor,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.1,
                ),
              ),
            ),
            if (icon == Icons.sync_rounded)
              Padding(
                padding: const EdgeInsets.only(left: AppSpacing.xs),
                child: SizedBox(
                  width: 12,
                  height: 12,
                  child: CircularProgressIndicator(
                    strokeWidth: 1.8,
                    valueColor: AlwaysStoppedAnimation<Color>(foregroundColor),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
