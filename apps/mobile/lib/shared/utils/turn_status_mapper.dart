import '../../data/models/contribution_model.dart';
import '../../data/models/cycle_model.dart';
import '../../data/models/payout_model.dart';

enum TurnStage {
  waiting,
  collecting,
  readyForWinnerSelection,
  auction,
  readyForPayout,
  payoutSent,
  completed,
}

class TurnStatusPresentation {
  const TurnStatusPresentation({required this.label, required this.stage});

  final String label;
  final TurnStage stage;
}

TurnStatusPresentation mapTurnStatus({
  required CycleModel? cycle,
  ContributionSummaryModel? contributionSummary,
  PayoutModel? payout,
}) {
  if (cycle == null) {
    return const TurnStatusPresentation(
      label: 'Waiting for payments',
      stage: TurnStage.waiting,
    );
  }

  if (cycle.status == CycleStatusModel.closed ||
      cycle.state == CycleStateModel.completed ||
      payout?.status == PayoutStatusModel.confirmed) {
    return const TurnStatusPresentation(
      label: 'Completed',
      stage: TurnStage.completed,
    );
  }

  if (cycle.state == CycleStateModel.payoutSent) {
    return const TurnStatusPresentation(
      label: 'Payout sent',
      stage: TurnStage.payoutSent,
    );
  }

  if (cycle.state == CycleStateModel.readyForWinnerSelection) {
    return const TurnStatusPresentation(
      label: 'Ready for winner selection',
      stage: TurnStage.readyForWinnerSelection,
    );
  }

  if (cycle.auctionStatus == AuctionStatusModel.open) {
    return const TurnStatusPresentation(
      label: 'Auction live',
      stage: TurnStage.auction,
    );
  }

  if (cycle.state == CycleStateModel.readyForPayout ||
      payout?.status == PayoutStatusModel.pending) {
    return const TurnStatusPresentation(
      label: 'Ready for payout',
      stage: TurnStage.readyForPayout,
    );
  }

  final summary = contributionSummary;
  final paidCount =
      (summary?.submitted ?? 0) +
      (summary?.paidSubmitted ?? 0) +
      (summary?.verified ?? 0) +
      (summary?.confirmed ?? 0);
  final total = summary?.total ?? 0;

  if (cycle.state == CycleStateModel.collecting ||
      (total > 0 && paidCount > 0)) {
    return const TurnStatusPresentation(
      label: 'Collecting contributions',
      stage: TurnStage.collecting,
    );
  }

  return const TurnStatusPresentation(
    label: 'Waiting for payments',
    stage: TurnStage.waiting,
  );
}
