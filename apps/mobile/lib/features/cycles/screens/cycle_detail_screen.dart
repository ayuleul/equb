import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../data/models/cycle_model.dart';
import '../../../data/models/group_model.dart';
import '../../../features/auth/auth_controller.dart';
import '../../../shared/kit/kit.dart';
import '../../../shared/utils/formatters.dart';
import '../../../shared/widgets/error_view.dart';
import '../../../shared/widgets/loading_view.dart';
import '../../groups/group_detail_controller.dart';
import '../cycle_auction_controller.dart';
import '../cycle_bids_provider.dart';
import '../cycle_detail_provider.dart';

class CycleDetailScreen extends ConsumerStatefulWidget {
  const CycleDetailScreen({
    super.key,
    required this.groupId,
    required this.cycleId,
  });

  final String groupId;
  final String cycleId;

  @override
  ConsumerState<CycleDetailScreen> createState() => _CycleDetailScreenState();
}

class _CycleDetailScreenState extends ConsumerState<CycleDetailScreen> {
  late final TextEditingController _bidAmountController;

  @override
  void initState() {
    super.initState();
    _bidAmountController = TextEditingController();
  }

  @override
  void dispose() {
    _bidAmountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cycleAsync = ref.watch(
      cycleDetailProvider((groupId: widget.groupId, cycleId: widget.cycleId)),
    );
    final groupAsync = ref.watch(groupDetailProvider(widget.groupId));
    final currentUser = ref.watch(currentUserProvider);
    final args = (groupId: widget.groupId, cycleId: widget.cycleId);
    final actionState = ref.watch(cycleAuctionActionControllerProvider(args));

    ref.listen(cycleAuctionActionControllerProvider(args), (previous, next) {
      final previousError = previous?.errorMessage;
      final nextError = next.errorMessage;
      if (nextError != null &&
          nextError.isNotEmpty &&
          previousError != nextError) {
        KitToast.error(context, nextError);
      }
    });

    return KitScaffold(
      appBar: const KitAppBar(title: 'Cycle detail'),
      child: cycleAsync.when(
        loading: () => const LoadingView(message: 'Loading cycle...'),
        error: (error, _) => ErrorView(
          message: error.toString(),
          onRetry: () => ref.invalidate(
            cycleDetailProvider((
              groupId: widget.groupId,
              cycleId: widget.cycleId,
            )),
          ),
        ),
        data: (cycle) {
          final isAdmin =
              groupAsync.valueOrNull?.membership?.role == MemberRoleModel.admin;
          final scheduledUserId =
              cycle.scheduledPayoutUserId ?? cycle.payoutUserId;
          final isScheduledRecipient = currentUser?.id == scheduledUserId;
          final canManageAuction = isAdmin || isScheduledRecipient;

          return _CycleDetailBody(
            groupId: widget.groupId,
            cycleId: widget.cycleId,
            cycle: cycle,
            canManageAuction: canManageAuction,
            actionState: actionState,
            bidAmountController: _bidAmountController,
          );
        },
      ),
    );
  }
}

class _CycleDetailBody extends ConsumerWidget {
  const _CycleDetailBody({
    required this.groupId,
    required this.cycleId,
    required this.cycle,
    required this.canManageAuction,
    required this.actionState,
    required this.bidAmountController,
  });

  final String groupId;
  final String cycleId;
  final CycleModel cycle;
  final bool canManageAuction;
  final CycleAuctionActionState actionState;
  final TextEditingController bidAmountController;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statusLabel = switch (cycle.status) {
      CycleStatusModel.open => 'OPEN',
      CycleStatusModel.closed => 'CLOSED',
      CycleStatusModel.unknown => 'UNKNOWN',
    };

    final scheduledRecipient = _recipientLabel(
      cycle.scheduledPayoutUser ?? cycle.payoutUser,
      cycle.scheduledPayoutUserId ?? cycle.payoutUserId,
    );
    final finalRecipient = _recipientLabel(
      cycle.finalPayoutUser ?? cycle.payoutUser,
      cycle.finalPayoutUserId ?? cycle.payoutUserId,
    );
    final auctionStatus = cycle.auctionStatus ?? AuctionStatusModel.none;

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
                      'Cycle #${cycle.cycleNo}',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                  ),
                  StatusPill.fromLabel(statusLabel),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Text('Due date: ${formatDate(cycle.dueDate)}'),
              const SizedBox(height: AppSpacing.xs),
              Text('Scheduled recipient: $scheduledRecipient'),
              if (finalRecipient != scheduledRecipient) ...[
                const SizedBox(height: AppSpacing.xs),
                Text('Final recipient: $finalRecipient'),
              ],
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        _AuctionCard(
          cycle: cycle,
          auctionStatus: auctionStatus,
          canManageAuction: canManageAuction,
          actionState: actionState,
          bidAmountController: bidAmountController,
          onOpenAuction: () async {
            final success = await ref
                .read(
                  cycleAuctionActionControllerProvider((
                    groupId: groupId,
                    cycleId: cycleId,
                  )).notifier,
                )
                .openAuction();
            if (!context.mounted) {
              return;
            }
            if (success) {
              KitToast.success(context, 'Auction opened.');
            }
          },
          onSubmitBid: (amount) async {
            final success = await ref
                .read(
                  cycleAuctionActionControllerProvider((
                    groupId: groupId,
                    cycleId: cycleId,
                  )).notifier,
                )
                .submitBid(amount);
            if (!context.mounted) {
              return;
            }
            if (success) {
              KitToast.success(context, 'Bid submitted.');
            }
          },
          onCloseAuction: () async {
            final success = await ref
                .read(
                  cycleAuctionActionControllerProvider((
                    groupId: groupId,
                    cycleId: cycleId,
                  )).notifier,
                )
                .closeAuction();
            if (!context.mounted) {
              return;
            }
            if (success) {
              KitToast.success(context, 'Auction closed.');
            }
          },
        ),
        const SizedBox(height: AppSpacing.md),
        const KitSectionHeader(title: 'Quick actions'),
        KitCard(
          child: Column(
            children: [
              ListTile(
                title: const Text('Contributions'),
                subtitle: const Text('View submissions and statuses'),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () => context.push(
                  AppRoutePaths.groupCycleContributions(groupId, cycleId),
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              ListTile(
                title: const Text('Payout'),
                subtitle: const Text(
                  'Track payout confirmation and cycle closure',
                ),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () => context.push(
                  AppRoutePaths.groupCyclePayout(groupId, cycleId),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _AuctionCard extends ConsumerWidget {
  const _AuctionCard({
    required this.cycle,
    required this.auctionStatus,
    required this.canManageAuction,
    required this.actionState,
    required this.bidAmountController,
    required this.onOpenAuction,
    required this.onSubmitBid,
    required this.onCloseAuction,
  });

  final CycleModel cycle;
  final AuctionStatusModel auctionStatus;
  final bool canManageAuction;
  final CycleAuctionActionState actionState;
  final TextEditingController bidAmountController;
  final Future<void> Function() onOpenAuction;
  final Future<void> Function(int amount) onSubmitBid;
  final Future<void> Function() onCloseAuction;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bidsAsync = ref.watch(cycleBidsProvider(cycle.id));
    final isLoading = actionState.isLoading;

    return KitCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Auction on turn',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: AppSpacing.sm),
          if (auctionStatus == AuctionStatusModel.none) ...[
            Text(
              canManageAuction
                  ? 'Auction is not open yet for this cycle.'
                  : 'Scheduled recipient has not opened auction.',
            ),
            if (canManageAuction) ...[
              const SizedBox(height: AppSpacing.md),
              KitPrimaryButton(
                onPressed: isLoading ? null : onOpenAuction,
                isLoading:
                    isLoading &&
                    actionState.actionType == CycleAuctionActionType.opening,
                label: 'Auction my turn',
              ),
            ],
          ],
          if (auctionStatus == AuctionStatusModel.open &&
              !canManageAuction) ...[
            Text('Auction is open. Submit your bid to win this cycle payout.'),
            const SizedBox(height: AppSpacing.md),
            KitNumberField(
              controller: bidAmountController,
              label: 'Bid amount',
            ),
            const SizedBox(height: AppSpacing.md),
            KitPrimaryButton(
              onPressed: isLoading
                  ? null
                  : () async {
                      final amount = int.tryParse(
                        bidAmountController.text.trim(),
                      );
                      if (amount == null || amount <= 0) {
                        KitToast.error(
                          context,
                          'Enter a bid amount greater than 0.',
                        );
                        return;
                      }
                      await onSubmitBid(amount);
                    },
              isLoading:
                  isLoading &&
                  actionState.actionType == CycleAuctionActionType.bidding,
              label: 'Submit bid',
            ),
          ],
          if (auctionStatus == AuctionStatusModel.open && canManageAuction) ...[
            Text('Auction is open. Review bids and close to pick the winner.'),
            const SizedBox(height: AppSpacing.sm),
            bidsAsync.when(
              loading: () => const KitSkeletonList(itemCount: 2),
              error: (error, _) => Text(error.toString()),
              data: (bids) {
                if (bids.isEmpty) {
                  return const Text('No bids yet.');
                }

                return Column(
                  children: bids
                      .map(
                        (bid) => ListTile(
                          dense: true,
                          contentPadding: EdgeInsets.zero,
                          title: Text(
                            _bidderLabel(
                              bid.user.fullName,
                              bid.user.phone,
                              bid.userId,
                            ),
                          ),
                          subtitle: Text('Bid: ${bid.amount}'),
                        ),
                      )
                      .toList(growable: false),
                );
              },
            ),
            const SizedBox(height: AppSpacing.md),
            KitPrimaryButton(
              onPressed: isLoading ? null : onCloseAuction,
              isLoading:
                  isLoading &&
                  actionState.actionType == CycleAuctionActionType.closing,
              label: 'Close auction',
            ),
          ],
          if (auctionStatus == AuctionStatusModel.closed) ...[
            if (cycle.winningBidUserId == null)
              const Text(
                'Auction closed with no bids. Scheduled recipient keeps the turn.',
              )
            else ...[
              Text(
                'Winner: ${_recipientLabel(cycle.winningBidUser, cycle.winningBidUserId)}',
              ),
              const SizedBox(height: AppSpacing.xs),
              Text('Winning bid: ${cycle.winningBidAmount ?? 0}'),
            ],
          ],
        ],
      ),
    );
  }
}

String _recipientLabel(CyclePayoutUserModel? user, String? fallbackId) {
  final fullName = user?.fullName?.trim();
  if (fullName != null && fullName.isNotEmpty) {
    return fullName;
  }
  final phone = user?.phone?.trim();
  if (phone != null && phone.isNotEmpty) {
    return phone;
  }
  return fallbackId ?? 'Member';
}

String _bidderLabel(String? fullName, String? phone, String fallbackId) {
  final trimmedName = fullName?.trim();
  if (trimmedName != null && trimmedName.isNotEmpty) {
    return trimmedName;
  }
  final trimmedPhone = phone?.trim();
  if (trimmedPhone != null && trimmedPhone.isNotEmpty) {
    return trimmedPhone;
  }
  return fallbackId;
}
