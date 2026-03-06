import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/bootstrap.dart';
import '../../data/models/contribution_dispute_model.dart';
import '../../data/models/contribution_model.dart';
import '../contributions/cycle_contributions_provider.dart';

typedef TurnDisputesArgs = ({String groupId, String cycleId});

class TurnContributionDisputeGroup {
  const TurnContributionDisputeGroup({
    required this.contribution,
    required this.disputes,
  });

  final ContributionModel contribution;
  final List<ContributionDisputeModel> disputes;
}

final turnDisputesProvider =
    FutureProvider.family<List<TurnContributionDisputeGroup>, TurnDisputesArgs>((
      ref,
      args,
    ) async {
      final repository = ref.watch(contributionsRepositoryProvider);
      final contributions = await ref.watch(
        cycleContributionsProvider((groupId: args.groupId, cycleId: args.cycleId)).future,
      );

      final items = contributions.items;
      if (items.isEmpty) {
        return const <TurnContributionDisputeGroup>[];
      }

      final disputesByContribution = await Future.wait(
        items.map((contribution) async {
          final disputes = await repository.listContributionDisputes(contribution.id);
          return TurnContributionDisputeGroup(
            contribution: contribution,
            disputes: disputes,
          );
        }),
      );

      return disputesByContribution
          .where((entry) => entry.disputes.isNotEmpty)
          .toList(growable: false);
    });
