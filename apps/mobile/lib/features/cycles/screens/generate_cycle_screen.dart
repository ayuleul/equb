import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../data/models/cycle_model.dart';
import '../../../data/models/group_model.dart';
import '../../../shared/copy/lottery_copy.dart';
import '../../../shared/kit/kit.dart';
import '../../../shared/ui/ui.dart';
import '../../../shared/utils/formatters.dart';
import '../../../shared/widgets/error_view.dart';
import '../../../shared/widgets/loading_view.dart';
import '../../groups/group_detail_controller.dart';
import '../../rounds/start_round_controller.dart';
import '../../rounds/widgets/lottery_reveal_animation.dart';
import '../current_cycle_provider.dart';
import '../generate_cycle_controller.dart';

class GenerateCycleScreen extends ConsumerWidget {
  const GenerateCycleScreen({super.key, required this.groupId});

  final String groupId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final groupAsync = ref.watch(groupDetailProvider(groupId));

    return KitScaffold(
      appBar: const KitAppBar(title: '🎲 Draw winner'),
      child: groupAsync.when(
        loading: () => const LoadingView(message: 'Loading group...'),
        error: (error, _) => ErrorView(
          message: mapFriendlyError(error),
          onRetry: () =>
              ref.read(groupDetailControllerProvider).refreshGroup(groupId),
        ),
        data: (group) {
          final isAdmin = group.membership?.role == MemberRoleModel.admin;
          if (!isAdmin) {
            return const EmptyState(
              icon: Icons.lock_outline,
              title: 'Admin only',
              message: 'Only admins can draw a winner.',
            );
          }

          if (!group.canStartCycle) {
            return EmptyState(
              icon: Icons.rule_folder_outlined,
              title: 'Setup required',
              message:
                  'Complete setup and ensure at least 2 eligible members before drawing the first winner.',
              ctaLabel: 'Open setup',
              onCtaPressed: () =>
                  context.push(AppRoutePaths.groupSetup(groupId)),
            );
          }

          return _DrawWinnerBody(groupId: groupId);
        },
      ),
    );
  }
}

class _DrawWinnerBody extends ConsumerStatefulWidget {
  const _DrawWinnerBody({required this.groupId});

  final String groupId;

  @override
  ConsumerState<_DrawWinnerBody> createState() => _DrawWinnerBodyState();
}

class _DrawWinnerBodyState extends ConsumerState<_DrawWinnerBody> {
  static const _minRevealDuration = Duration(milliseconds: 1200);

  bool _isDrawing = false;
  CycleModel? _revealedCycle;
  var _playReveal = false;

  Future<void> _drawWinner() async {
    if (_isDrawing) {
      return;
    }

    setState(() => _isDrawing = true);
    final startedAt = DateTime.now();

    final drawController = ref.read(
      generateCycleControllerProvider(widget.groupId).notifier,
    );
    CycleModel? created = await drawController.generateNextCycle();

    if (created == null) {
      final drawError =
          ref
              .read(generateCycleControllerProvider(widget.groupId))
              .errorMessage ??
          '';
      final normalized = drawError.toLowerCase();

      if (normalized.contains('active round is required')) {
        final startedRound = await ref
            .read(startRoundControllerProvider(widget.groupId).notifier)
            .startRound();
        if (startedRound) {
          created = await drawController.generateNextCycle();
        }
      }
    }

    final elapsed = DateTime.now().difference(startedAt);
    if (elapsed < _minRevealDuration) {
      await Future<void>.delayed(_minRevealDuration - elapsed);
    }

    if (!mounted) {
      return;
    }

    setState(() => _isDrawing = false);

    if (created == null) {
      final drawMessage = ref
          .read(generateCycleControllerProvider(widget.groupId))
          .errorMessage;
      final startMessage = ref
          .read(startRoundControllerProvider(widget.groupId))
          .errorMessage;
      AppSnackbars.error(
        context,
        drawMessage ?? startMessage ?? 'Could not draw a winner right now.',
      );
      return;
    }

    final winnerName = _winnerLabel(created);
    setState(() {
      _revealedCycle = created;
      _playReveal = true;
    });
    Future<void>.delayed(const Duration(milliseconds: 1200), () {
      if (!mounted || !_playReveal) {
        return;
      }
      setState(() => _playReveal = false);
    });

    AppSnackbars.success(
      context,
      '${LotteryCopy.drawSuccessPrefix} $winnerName ${LotteryCopy.drawSuccessMessageSuffix}',
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(generateCycleControllerProvider(widget.groupId));
    final currentCycleAsync = ref.watch(currentCycleProvider(widget.groupId));

    ref.listen(generateCycleControllerProvider(widget.groupId), (
      previous,
      next,
    ) {
      final previousError = previous?.errorMessage;
      final nextError = next.errorMessage;
      if (nextError != null &&
          nextError.isNotEmpty &&
          previousError != nextError &&
          !_isDrawing) {
        AppSnackbars.error(context, nextError);
      }
    });

    return ListView(
      children: [
        KitCard(
          child: currentCycleAsync.when(
            loading: () =>
                const LoadingView(message: 'Checking current turn...'),
            error: (error, _) => ErrorView(
              message: mapFriendlyError(error),
              onRetry: () =>
                  ref.invalidate(currentCycleProvider(widget.groupId)),
            ),
            data: (currentCycle) {
              if (currentCycle != null) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Current turn is open',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'Turn ${currentCycle.cycleNo} is still open. Finish it before drawing the next winner.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      '🎲 Winner: ${_winnerLabel(currentCycle)}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    KitSecondaryButton(
                      label: 'View current turn',
                      icon: Icons.visibility_outlined,
                      onPressed: () => context.push(
                        AppRoutePaths.groupCycleDetail(
                          widget.groupId,
                          currentCycle.id,
                        ),
                      ),
                    ),
                  ],
                );
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    LotteryCopy.drawWinnerButton,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    LotteryCopy.noOpenTurnMessage,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  KitPrimaryButton(
                    onPressed: _isDrawing ? null : _drawWinner,
                    icon: Icons.casino_outlined,
                    isLoading: _isDrawing,
                    label: _isDrawing
                        ? LotteryCopy.drawingWinnerDialogLabel
                        : LotteryCopy.drawWinnerButton,
                  ),
                ],
              );
            },
          ),
        ),
        if (_isDrawing) ...[
          const SizedBox(height: AppSpacing.md),
          const KitCard(
            child: Row(
              children: [
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                SizedBox(width: AppSpacing.sm),
                Expanded(child: Text(LotteryCopy.drawingWinnerDialogLabel)),
              ],
            ),
          ),
        ],
        if (_revealedCycle != null) ...[
          const SizedBox(height: AppSpacing.md),
          LotteryRevealAnimation(
            play: _playReveal,
            child: _WinnerRevealCard(cycle: _revealedCycle!),
          ),
        ],
        if (state.isRoundCompleted) ...[
          const SizedBox(height: AppSpacing.md),
          KitCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  LotteryCopy.roundCompletedTitle,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  LotteryCopy.roundCompletedMessage,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  String _winnerLabel(CycleModel cycle) {
    final user = cycle.finalPayoutUser ?? cycle.payoutUser;
    final fullName = user?.fullName?.trim();
    if (fullName != null && fullName.isNotEmpty) {
      return fullName;
    }

    final phone = user?.phone?.trim();
    if (phone != null && phone.isNotEmpty) {
      return phone;
    }

    return cycle.finalPayoutUserId ?? cycle.payoutUserId;
  }
}

class _WinnerRevealCard extends StatelessWidget {
  const _WinnerRevealCard({required this.cycle});

  final CycleModel cycle;

  @override
  Widget build(BuildContext context) {
    final user = cycle.finalPayoutUser ?? cycle.payoutUser;
    final winnerName = user?.fullName?.trim().isNotEmpty == true
        ? user!.fullName!.trim()
        : (user?.phone?.trim().isNotEmpty == true
              ? user!.phone!.trim()
              : (cycle.finalPayoutUserId ?? cycle.payoutUserId));

    return KitCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Turn ${cycle.cycleNo}',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text('Due ${formatDate(cycle.dueDate)}'),
          const SizedBox(height: AppSpacing.sm),
          Text(
            '${LotteryCopy.winnerHeadline}: $winnerName',
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}
