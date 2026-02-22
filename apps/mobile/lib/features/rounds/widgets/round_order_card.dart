import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_spacing.dart';
import '../../../data/models/current_round_schedule_model.dart';
import '../../../shared/copy/fair_draw_copy.dart';
import '../../../shared/kit/kit.dart';
import '../../../shared/ui/ui.dart';
import '../current_round_schedule_provider.dart';
import '../round_draw_reveal_state.dart';
import 'fair_draw_shuffle_reveal.dart';

class RoundOrderCard extends ConsumerWidget {
  const RoundOrderCard({super.key, required this.groupId});

  final String groupId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheduleAsync = ref.watch(currentRoundScheduleProvider(groupId));
    final shouldAutoPlay = ref.watch(roundJustStartedProvider(groupId));

    return KitCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  FairDrawCopy.roundOrderTitle,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              IconButton(
                tooltip: FairDrawCopy.howItWorksButton,
                onPressed: () => _showHowItWorksSheet(context, scheduleAsync),
                icon: const Icon(Icons.info_outline_rounded),
              ),
            ],
          ),
          Text(
            FairDrawCopy.roundOrderSubtitle,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: AppSpacing.xs),
          KitTertiaryButton(
            label: FairDrawCopy.howItWorksButton,
            expand: false,
            onPressed: () => _showHowItWorksSheet(context, scheduleAsync),
          ),
          const SizedBox(height: AppSpacing.sm),
          ...FairDrawCopy.compactExplanation.map(
            (line) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.xs),
              child: Text(
                '• $line',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          scheduleAsync.when(
            loading: () => const SizedBox(
              height: 220,
              child: KitSkeletonList(itemCount: 5),
            ),
            error: (error, _) => EmptyState(
              icon: Icons.error_outline_rounded,
              title: FairDrawCopy.loadErrorTitle,
              message: mapFriendlyError(error),
              ctaLabel: FairDrawCopy.retryLabel,
              onCtaPressed: () =>
                  ref.invalidate(currentRoundScheduleProvider(groupId)),
            ),
            data: (schedule) {
              if (schedule == null || schedule.schedule.isEmpty) {
                return const EmptyState(
                  icon: Icons.hourglass_top_rounded,
                  title: FairDrawCopy.emptyOrderTitle,
                  message: FairDrawCopy.emptyOrderMessage,
                );
              }

              return FairDrawShuffleReveal(
                finalOrder: schedule.finalOrder,
                autoPlay: shouldAutoPlay,
                onFinished: shouldAutoPlay
                    ? () =>
                          ref
                                  .read(
                                    roundJustStartedProvider(groupId).notifier,
                                  )
                                  .state =
                              false
                    : null,
              );
            },
          ),
        ],
      ),
    );
  }
}

Future<void> _showHowItWorksSheet(
  BuildContext context,
  AsyncValue<CurrentRoundScheduleModel?> scheduleAsync,
) {
  final drawSeedHash = scheduleAsync.valueOrNull?.drawSeedHash;

  return showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (sheetContext) {
      final hasHash = drawSeedHash != null && drawSeedHash.trim().isNotEmpty;
      final commitmentHash = drawSeedHash ?? '';

      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.md,
            AppSpacing.sm,
            AppSpacing.md,
            AppSpacing.md,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                FairDrawCopy.howItWorksTitle,
                style: Theme.of(
                  sheetContext,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: AppSpacing.sm),
              ...FairDrawCopy.howItWorksBullets.map(
                (line) => Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                  child: Text(
                    '• $line',
                    style: Theme.of(sheetContext).textTheme.bodyMedium,
                  ),
                ),
              ),
              if (hasHash) ...[
                const SizedBox(height: AppSpacing.sm),
                ExpansionTile(
                  tilePadding: EdgeInsets.zero,
                  title: Text(
                    FairDrawCopy.advancedLabel,
                    style: Theme.of(sheetContext).textTheme.titleSmall,
                  ),
                  childrenPadding: const EdgeInsets.only(bottom: AppSpacing.sm),
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                FairDrawCopy.commitmentHashLabel,
                                style: Theme.of(
                                  sheetContext,
                                ).textTheme.labelLarge,
                              ),
                              const SizedBox(height: AppSpacing.xs),
                              SelectableText(
                                commitmentHash,
                                style: Theme.of(
                                  sheetContext,
                                ).textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          tooltip: 'Copy',
                          onPressed: () async {
                            await Clipboard.setData(
                              ClipboardData(text: commitmentHash),
                            );
                            if (!sheetContext.mounted) {
                              return;
                            }
                            AppSnackbars.info(
                              sheetContext,
                              FairDrawCopy.copiedMessage,
                            );
                          },
                          icon: const Icon(Icons.copy_rounded),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      );
    },
  );
}
