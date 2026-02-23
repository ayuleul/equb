import '../../data/models/contribution_model.dart';
import '../../data/models/cycle_model.dart';
import '../../data/models/payout_model.dart';

enum RoundStage { contributions, auction, payout, closed }

class RoundStatusPresentation {
  const RoundStatusPresentation({required this.label, required this.stage});

  final String label;
  final RoundStage stage;
}

RoundStatusPresentation mapRoundStatus({
  required CycleModel? cycle,
  ContributionSummaryModel? contributionSummary,
  PayoutModel? payout,
}) {
  if (cycle == null) {
    return const RoundStatusPresentation(
      label: 'Waiting for payments',
      stage: RoundStage.contributions,
    );
  }

  if (cycle.status == CycleStatusModel.closed ||
      payout?.status == PayoutStatusModel.confirmed) {
    return const RoundStatusPresentation(
      label: 'Completed',
      stage: RoundStage.closed,
    );
  }

  if (cycle.state == CycleStateModel.readyForPayout ||
      cycle.state == CycleStateModel.disbursed) {
    return const RoundStatusPresentation(
      label: 'Ready to payout',
      stage: RoundStage.payout,
    );
  }

  final total = contributionSummary?.total ?? 0;
  final paidCount =
      (contributionSummary?.submitted ?? 0) +
      (contributionSummary?.confirmed ?? 0);
  final confirmed = contributionSummary?.confirmed ?? 0;

  if (payout?.status == PayoutStatusModel.pending ||
      (total > 0 && confirmed >= total) ||
      cycle.auctionStatus == AuctionStatusModel.closed) {
    return const RoundStatusPresentation(
      label: 'Ready to payout',
      stage: RoundStage.payout,
    );
  }

  if (total > 0 && paidCount < total) {
    return const RoundStatusPresentation(
      label: 'Waiting for payments',
      stage: RoundStage.contributions,
    );
  }

  if (cycle.auctionStatus == AuctionStatusModel.open) {
    return const RoundStatusPresentation(
      label: 'In progress',
      stage: RoundStage.auction,
    );
  }

  return const RoundStatusPresentation(
    label: 'In progress',
    stage: RoundStage.contributions,
  );
}
