import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/bootstrap.dart';
import '../../../app/router.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_theme_extensions.dart';
import '../../../data/models/contribution_dispute_model.dart';
import '../../../data/models/contribution_model.dart';
import '../../../data/models/cycle_bid_model.dart';
import '../../../data/models/cycle_model.dart';
import '../../../data/models/group_model.dart';
import '../../../data/models/group_rules_model.dart';
import '../../../data/models/member_status_utils.dart';
import '../../../data/models/payout_model.dart';
import '../../../shared/kit/kit.dart';
import '../../../shared/utils/formatters.dart';
import '../../../shared/utils/turn_status_mapper.dart';
import '../../../shared/widgets/error_view.dart';
import '../../../shared/widgets/loading_view.dart';
import '../../../shared/widgets/realtime_status_banner.dart';
import '../../auth/auth_controller.dart';
import '../../contributions/admin_contribution_actions_controller.dart';
import '../../contributions/cycle_contributions_provider.dart';
import '../../cycles/cycle_auction_controller.dart';
import '../../cycles/cycle_bids_provider.dart';
import '../../cycles/cycle_detail_provider.dart';
import '../../cycles/cycles_list_provider.dart';
import '../../groups/group_detail_controller.dart';
import '../../groups/group_rules_provider.dart';
import '../../payouts/cycle_payout_provider.dart';
import '../../payouts/payout_action_controller.dart';
import '../../rounds/widgets/lottery_reveal_animation.dart';
import '../turn_detail_controller.dart';
import '../turn_disputes_provider.dart';

part 'turn_details_sections.dart';
part 'turn_details_actions.dart';

class TurnDetailsScreen extends ConsumerStatefulWidget {
  const TurnDetailsScreen({
    super.key,
    required this.groupId,
    required this.turnId,
  });

  final String groupId;
  final String turnId;

  @override
  ConsumerState<TurnDetailsScreen> createState() => _TurnDetailsScreenState();
}

class _TurnDetailsScreenState extends ConsumerState<TurnDetailsScreen> {
  static const double _turnActionTrayInset = 116;
  late final TextEditingController _bidAmountController;
  late final dynamic _realtimeClient;

  @override
  void initState() {
    super.initState();
    _bidAmountController = TextEditingController();
    _realtimeClient = ref.read(realtimeClientProvider);
    _realtimeClient.joinTurn(widget.turnId, groupId: widget.groupId);
  }

  @override
  void dispose() {
    _realtimeClient.leaveTurn(widget.turnId);
    _bidAmountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final args = (groupId: widget.groupId, cycleId: widget.turnId);
    final groupAsync = ref.watch(groupDetailProvider(widget.groupId));
    final cycleAsync = ref.watch(cycleDetailProvider(args));
    final group = groupAsync.valueOrNull;
    final cycle = cycleAsync.valueOrNull;
    final contributionsAsync = ref.watch(cycleContributionsProvider(args));
    final payoutAsync = ref.watch(cyclePayoutProvider(widget.turnId));
    final disputesAsync = ref.watch(
      turnDisputesProvider((groupId: widget.groupId, cycleId: widget.turnId)),
    );
    final auctionState = ref.watch(cycleAuctionActionControllerProvider(args));
    final adminState = ref.watch(
      adminContributionActionsControllerProvider(args),
    );

    ref.listen(cycleAuctionActionControllerProvider(args), (previous, next) {
      final previousError = previous?.errorMessage;
      final nextError = next.errorMessage;
      if (nextError != null &&
          nextError.isNotEmpty &&
          previousError != nextError) {
        KitToast.error(context, nextError);
      }
    });
    ref.listen(adminContributionActionsControllerProvider(args), (
      previous,
      next,
    ) {
      final previousError = previous?.errorMessage;
      final nextError = next.errorMessage;
      if (nextError != null &&
          nextError.isNotEmpty &&
          previousError != nextError) {
        KitToast.error(context, nextError);
      }
    });
    ref.listen(payoutActionControllerProvider(args), (previous, next) {
      final previousError = previous?.errorMessage;
      final nextError = next.errorMessage;
      if (nextError != null &&
          nextError.isNotEmpty &&
          previousError != nextError) {
        KitToast.error(context, nextError);
      }
    });

    return KitScaffold(
      appBar: KitAppBar(
        title: group?.name ?? 'Turn',
        subtitle: cycle == null ? null : 'Turn ${cycle.cycleNo}',
        status: const RealtimeHeaderStatus(),
      ),
      child: Column(
        children: [
          Expanded(
            child: groupAsync.when(
              loading: () => const LoadingView(message: 'Loading turn...'),
              error: (error, _) => ErrorView(
                message: mapFriendlyError(error),
                onRetry: () => ref
                    .read(groupDetailControllerProvider)
                    .refreshAll(widget.groupId),
              ),
              data: (group) => cycleAsync.when(
                loading: () => const LoadingView(message: 'Loading turn...'),
                error: (error, _) => ErrorView(
                  message: mapFriendlyError(error),
                  onRetry: () => ref.invalidate(cycleDetailProvider(args)),
                ),
                data: (cycle) {
                  final isAdmin =
                      group.membership?.role == MemberRoleModel.admin;
                  final currentUserId = ref.watch(currentUserProvider)?.id;
                  final contributionList = contributionsAsync.valueOrNull;
                  final payout = payoutAsync.valueOrNull;
                  final action = _resolveTurnAction(
                    context: context,
                    group: group,
                    cycle: cycle,
                    payout: payout,
                    contribution: _findContribution(
                      contributionList,
                      currentUserId,
                    ),
                    isAdmin: isAdmin,
                    currentUserId: currentUserId,
                  );
                  final footer = _resolveTurnFooter(
                    action: action,
                    cycle: cycle,
                    payout: payout,
                    isAdmin: isAdmin,
                    contribution: _findContribution(
                      contributionList,
                      currentUserId,
                    ),
                    currentUserId: currentUserId,
                  );
                  final status = mapTurnStatus(
                    cycle: cycle,
                    contributionSummary: contributionList?.summary,
                    payout: payout,
                  );

                  return Stack(
                    children: [
                      RefreshIndicator(
                        onRefresh: _refreshTurn,
                        child: ListView(
                          padding: EdgeInsets.only(
                            bottom: footer != null ? _turnActionTrayInset : 0,
                          ),
                          children: [
                            const SizedBox(height: AppSpacing.xs),
                            _TurnSummaryCard(
                              group: group,
                              cycle: cycle,
                              payout: payout,
                              status: status,
                              contributionsAsync: contributionsAsync,
                              currentUserId: currentUserId,
                            ),
                            const SizedBox(height: AppSpacing.md),
                            const KitSectionHeader(
                              title: 'Members',
                              subtitle:
                                  'Payment progress and per-member status',
                            ),
                            _CollectionSection(
                              group: group,
                              cycle: cycle,
                              contributionsAsync: contributionsAsync,
                              currentUserId: currentUserId,
                              isAdmin: isAdmin,
                              adminState: adminState,
                              action: action,
                            ),
                            if ((cycle.auctionStatus ??
                                    AuctionStatusModel.none) !=
                                AuctionStatusModel.none) ...[
                              const SizedBox(height: AppSpacing.md),
                              const KitSectionHeader(
                                title: 'Auction',
                                subtitle:
                                    'Bidding status and next auction action',
                              ),
                              _AuctionSection(
                                groupId: widget.groupId,
                                cycle: cycle,
                                isAdmin: isAdmin,
                                actionState: auctionState,
                                bidAmountController: _bidAmountController,
                              ),
                            ],
                            if ((disputesAsync.valueOrNull ?? const [])
                                .isNotEmpty) ...[
                              const SizedBox(height: AppSpacing.md),
                              const KitSectionHeader(
                                title: 'Contribution Issues',
                                subtitle:
                                    'Open and resolved disputes tied to this turn',
                              ),
                              _DisputesSection(
                                groupId: widget.groupId,
                                cycleId: widget.turnId,
                                disputesAsync: disputesAsync,
                              ),
                            ],
                            const SizedBox(height: AppSpacing.lg),
                          ],
                        ),
                      ),
                      if (footer != null)
                        Positioned(
                          left: 0,
                          right: 0,
                          bottom: 0,
                          child: _buildTurnActionTray(
                            context: context,
                            footer: footer,
                            onPressed: footer.isAction
                                ? () {
                                    final action = footer.action!;
                                    if (_isTurnLevelAction(action)) {
                                      _handleTurnLevelAction(
                                        context: context,
                                        ref: ref,
                                        action: action,
                                        groupId: widget.groupId,
                                        cycle: cycle,
                                      );
                                      return;
                                    }
                                    action.onPressed?.call();
                                  }
                                : null,
                          ),
                        ),
                    ],
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _refreshTurn() async {
    await ref
        .read(turnDetailControllerProvider)
        .refreshTurn(widget.groupId, widget.turnId);
  }
}
