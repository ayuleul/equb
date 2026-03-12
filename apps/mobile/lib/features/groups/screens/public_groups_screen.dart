import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../data/models/public_group_model.dart';
import '../../../shared/kit/kit.dart';
import '../../../shared/utils/api_error_mapper.dart';
import '../../../shared/utils/formatters.dart';
import '../public_groups_controller.dart';

class PublicGroupsScreen extends ConsumerWidget {
  const PublicGroupsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final groupsAsync = ref.watch(publicGroupsProvider);

    return KitScaffold(
      appBar: const KitAppBar(
        title: 'Discover groups',
        subtitle: 'Browse public Equbs that accept join requests',
      ),
      child: RefreshIndicator(
        onRefresh: () =>
            ref.read(publicGroupsControllerProvider).refreshPublicGroups(),
        child: groupsAsync.when(
          loading: () => const KitSkeletonList(itemCount: 4),
          error: (error, _) => KitEmptyState(
            icon: Icons.travel_explore_outlined,
            title: 'Unable to load public groups',
            message: mapApiErrorToMessage(error),
            ctaLabel: 'Retry',
            onCtaPressed: () => ref.invalidate(publicGroupsProvider),
          ),
          data: (groups) {
            if (groups.isEmpty) {
              return const KitEmptyState(
                icon: Icons.groups_2_outlined,
                title: 'No public groups yet',
                message: 'Public Equbs will appear here when admins make them discoverable.',
              );
            }

            return ListView.separated(
              itemCount: groups.length,
              separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
              itemBuilder: (context, index) {
                final group = groups[index];
                return KitCard(
                  onTap: () => context.push(AppRoutePaths.publicGroupDetail(group.id)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              group.name,
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                          ),
                          if (group.alreadyStarted)
                            const StatusPill(label: 'In progress'),
                        ],
                      ),
                      if ((group.description ?? '').trim().isNotEmpty) ...[
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          group.description!,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                      const SizedBox(height: AppSpacing.sm),
                      _PublicGroupInfoRow(
                        label: 'Contribution',
                        value: formatCurrency(
                          group.contributionAmount,
                          group.currency,
                        ),
                      ),
                      _PublicGroupInfoRow(
                        label: 'Frequency',
                        value: _frequencyLabel(group.frequency, group.rules),
                      ),
                      _PublicGroupInfoRow(
                        label: 'Payout mode',
                        value: _payoutModeLabel(group.payoutMode),
                      ),
                      _PublicGroupInfoRow(
                        label: 'Members',
                        value: '${group.memberCount}',
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _PublicGroupInfoRow extends StatelessWidget {
  const _PublicGroupInfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.xs),
      child: Row(
        children: [
          Expanded(child: Text(label)),
          const SizedBox(width: AppSpacing.sm),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

String _frequencyLabel(
  PublicGroupFrequencyModel frequency,
  PublicGroupRulesModel? rules,
) {
  return switch (frequency) {
    PublicGroupFrequencyModel.weekly => 'Weekly',
    PublicGroupFrequencyModel.monthly => 'Monthly',
    PublicGroupFrequencyModel.customInterval =>
      '${rules?.customIntervalDays ?? 0} day interval',
    PublicGroupFrequencyModel.unknown => 'Unknown',
  };
}

String _payoutModeLabel(PublicGroupPayoutModeModel? payoutMode) {
  return switch (payoutMode ?? PublicGroupPayoutModeModel.unknown) {
    PublicGroupPayoutModeModel.lottery => 'Lottery',
    PublicGroupPayoutModeModel.auction => 'Auction',
    PublicGroupPayoutModeModel.rotation => 'Rotation',
    PublicGroupPayoutModeModel.decision => 'Decision',
    PublicGroupPayoutModeModel.unknown => 'Not set',
  };
}
