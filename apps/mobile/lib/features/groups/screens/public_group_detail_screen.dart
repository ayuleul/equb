import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_spacing.dart';
import '../../../data/models/join_request_model.dart';
import '../../../data/models/public_group_model.dart';
import '../../../shared/kit/kit.dart';
import '../../../shared/utils/api_error_mapper.dart';
import '../../../shared/utils/formatters.dart';
import '../public_groups_controller.dart';

class PublicGroupDetailScreen extends ConsumerStatefulWidget {
  const PublicGroupDetailScreen({super.key, required this.groupId});

  final String groupId;

  @override
  ConsumerState<PublicGroupDetailScreen> createState() =>
      _PublicGroupDetailScreenState();
}

class _PublicGroupDetailScreenState
    extends ConsumerState<PublicGroupDetailScreen> {
  bool _isSubmitting = false;

  Future<void> _requestToJoin() async {
    setState(() => _isSubmitting = true);
    try {
      await ref
          .read(publicGroupsControllerProvider)
          .requestToJoin(widget.groupId);
      if (!mounted) {
        return;
      }
      KitToast.success(context, 'Join request sent to the group admins.');
    } catch (error) {
      if (!mounted) {
        return;
      }
      KitToast.error(context, mapApiErrorToMessage(error));
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final groupAsync = ref.watch(publicGroupDetailProvider(widget.groupId));
    final requestAsync = ref.watch(myJoinRequestProvider(widget.groupId));

    return KitScaffold(
      appBar: const KitAppBar(title: 'Public group'),
      child: RefreshIndicator(
        onRefresh: () =>
            ref.read(publicGroupsControllerProvider).refreshPublicGroup(widget.groupId),
        child: groupAsync.when(
          loading: () => const KitSkeletonList(itemCount: 3),
          error: (error, _) => KitEmptyState(
            icon: Icons.groups_2_outlined,
            title: 'Unable to load group',
            message: mapApiErrorToMessage(error),
            ctaLabel: 'Retry',
            onCtaPressed: () =>
                ref.invalidate(publicGroupDetailProvider(widget.groupId)),
          ),
          data: (group) {
            final joinRequest = requestAsync.asData?.value;
            final actionState = _resolveActionState(group, joinRequest);

            return ListView(
              children: [
                KitCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              group.name,
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                          ),
                          StatusPill(label: actionState.label),
                        ],
                      ),
                      if ((group.description ?? '').trim().isNotEmpty) ...[
                        const SizedBox(height: AppSpacing.sm),
                        Text(group.description!),
                      ],
                      const SizedBox(height: AppSpacing.md),
                      _DetailRow(
                        label: 'Contribution',
                        value: formatCurrency(
                          group.contributionAmount,
                          group.currency,
                        ),
                      ),
                      _DetailRow(
                        label: 'Frequency',
                        value: _frequencyLabel(group.frequency, group.rules),
                      ),
                      _DetailRow(
                        label: 'Payout mode',
                        value: _payoutModeLabel(group.payoutMode),
                      ),
                      _DetailRow(
                        label: 'Members',
                        value: '${group.memberCount}',
                      ),
                      _DetailRow(
                        label: 'Started',
                        value: group.alreadyStarted ? 'Yes' : 'No',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                KitCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Rules', style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: AppSpacing.sm),
                      if (group.rules == null)
                        const Text('This group has not published rules yet.')
                      else ...[
                        _DetailRow(
                          label: 'Round size',
                          value: '${group.rules!.roundSize}',
                        ),
                        _DetailRow(
                          label: 'Start policy',
                          value: _startPolicyLabel(group.rules!.startPolicy),
                        ),
                        _DetailRow(
                          label: 'Winner timing',
                          value: switch (group.rules!.winnerSelectionTiming) {
                            WinnerSelectionTimingModel.beforeCollection =>
                              'Before collection',
                            WinnerSelectionTimingModel.afterCollection =>
                              'After collection',
                            WinnerSelectionTimingModel.unknown => 'Unknown',
                          },
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                KitPrimaryButton(
                  label: _isSubmitting ? 'Sending...' : actionState.buttonLabel,
                  icon: Icons.group_add_outlined,
                  onPressed: actionState.canSubmit && !_isSubmitting
                      ? _requestToJoin
                      : null,
                ),
                if (actionState.message != null) ...[
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    actionState.message!,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ],
            );
          },
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

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

class _PublicActionState {
  const _PublicActionState({
    required this.label,
    required this.buttonLabel,
    required this.canSubmit,
    this.message,
  });

  final String label;
  final String buttonLabel;
  final bool canSubmit;
  final String? message;
}

_PublicActionState _resolveActionState(
  PublicGroupModel group,
  JoinRequestModel? joinRequest,
) {
  if (group.isCurrentUserMember ?? false) {
    return const _PublicActionState(
      label: 'Approved',
      buttonLabel: 'Approved',
      canSubmit: false,
      message: 'You are already a member of this group.',
    );
  }
  final now = DateTime.now();
  final retryAvailableAt = joinRequest?.retryAvailableAt;
  final isCooldownActive =
      retryAvailableAt != null && now.isBefore(retryAvailableAt);

  return switch (joinRequest?.status ?? JoinRequestStatusModel.unknown) {
    JoinRequestStatusModel.requested => const _PublicActionState(
      label: 'Request sent',
      buttonLabel: 'Request sent',
      canSubmit: false,
      message: 'Admins are reviewing your request.',
    ),
    JoinRequestStatusModel.approved => const _PublicActionState(
      label: 'Approved',
      buttonLabel: 'Approved',
      canSubmit: false,
    ),
    JoinRequestStatusModel.rejected => _PublicActionState(
      label: 'Rejected',
      buttonLabel:
          isCooldownActive ? 'Try again later' : 'Request to join again',
      canSubmit: !isCooldownActive,
      message: isCooldownActive
          ? 'This request was rejected by the group admins. You can try again after ${_formatRetryDate(retryAvailableAt)}.'
          : 'This request was rejected by the group admins. You can submit a new request now.',
    ),
    JoinRequestStatusModel.withdrawn => const _PublicActionState(
      label: 'Withdrawn',
      buttonLabel: 'Request to join',
      canSubmit: true,
    ),
    JoinRequestStatusModel.unknown => const _PublicActionState(
      label: 'Open',
      buttonLabel: 'Request to join',
      canSubmit: true,
      message: 'Joining still requires admin approval.',
    ),
  };
}

String _startPolicyLabel(PublicGroupStartPolicyModel policy) {
  return switch (policy) {
    PublicGroupStartPolicyModel.whenFull => 'When full',
    PublicGroupStartPolicyModel.onDate => 'On date',
    PublicGroupStartPolicyModel.manual => 'Manual',
    PublicGroupStartPolicyModel.unknown => 'Unknown',
  };
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

String _formatRetryDate(DateTime value) {
  final month = switch (value.month) {
    1 => 'Jan',
    2 => 'Feb',
    3 => 'Mar',
    4 => 'Apr',
    5 => 'May',
    6 => 'Jun',
    7 => 'Jul',
    8 => 'Aug',
    9 => 'Sep',
    10 => 'Oct',
    11 => 'Nov',
    12 => 'Dec',
    _ => '',
  };

  return '$month ${value.day}, ${value.year}';
}
