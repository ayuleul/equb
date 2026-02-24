import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/bootstrap.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../data/models/contribution_dispute_model.dart';
import '../../../data/models/group_model.dart';
import '../../../shared/kit/kit.dart';
import '../../../shared/utils/formatters.dart';
import '../../../shared/widgets/error_view.dart';
import '../../../shared/widgets/loading_view.dart';
import '../../groups/group_detail_controller.dart';
import '../contribution_disputes_provider.dart';

class ContributionDisputesScreen extends ConsumerStatefulWidget {
  const ContributionDisputesScreen({
    super.key,
    required this.groupId,
    required this.cycleId,
    required this.contributionId,
  });

  final String groupId;
  final String cycleId;
  final String contributionId;

  @override
  ConsumerState<ContributionDisputesScreen> createState() =>
      _ContributionDisputesScreenState();
}

class _ContributionDisputesScreenState
    extends ConsumerState<ContributionDisputesScreen> {
  bool _isBusy = false;

  @override
  Widget build(BuildContext context) {
    final disputesAsync = ref.watch(
      contributionDisputesProvider(widget.contributionId),
    );
    final group = ref.watch(groupDetailProvider(widget.groupId)).valueOrNull;
    final isAdmin = group?.membership?.role == MemberRoleModel.admin;

    Future<void> reload() async {
      ref.invalidate(contributionDisputesProvider(widget.contributionId));
      await ref.read(
        contributionDisputesProvider(widget.contributionId).future,
      );
    }

    return KitScaffold(
      appBar: const KitAppBar(title: 'Dispute status'),
      child: disputesAsync.when(
        loading: () => const LoadingView(message: 'Loading disputes...'),
        error: (error, _) => ErrorView(
          message: mapFriendlyError(error),
          onRetry: () => ref.invalidate(
            contributionDisputesProvider(widget.contributionId),
          ),
        ),
        data: (disputes) {
          final hasOpen = disputes.any(
            (item) =>
                item.status == ContributionDisputeStatusModel.open ||
                item.status == ContributionDisputeStatusModel.mediating,
          );

          return RefreshIndicator(
            onRefresh: reload,
            child: ListView(
              children: [
                KitCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Contribution dispute',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        'Use this flow to report mismatch, mediate, and resolve.',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                if (!hasOpen)
                  KitPrimaryButton(
                    onPressed: _isBusy ? null : _openDispute,
                    icon: Icons.report_gmailerrorred_outlined,
                    label: _isBusy ? 'Submitting...' : 'Report mismatch',
                  )
                else
                  const KitBanner(
                    title: 'Dispute in progress',
                    message:
                        'Resolve the current open dispute before opening a new one.',
                    tone: KitBadgeTone.warning,
                    icon: Icons.info_outline,
                  ),
                const SizedBox(height: AppSpacing.md),
                if (disputes.isEmpty)
                  const KitEmptyState(
                    icon: Icons.fact_check_outlined,
                    title: 'No disputes yet',
                    message:
                        'No mismatch has been reported for this contribution.',
                  )
                else
                  ...disputes.map(
                    (dispute) => Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                      child: _DisputeCard(
                        dispute: dispute,
                        isAdmin: isAdmin,
                        isBusy: _isBusy,
                        onMediate: () => _mediateDispute(dispute.id),
                        onResolve: () => _resolveDispute(dispute.id),
                      ),
                    ),
                  ),
                const SizedBox(height: AppSpacing.md),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _openDispute() async {
    final reason = await promptText(
      context: context,
      title: 'Report mismatch',
      label: 'Reason',
      hint: 'Describe the mismatch',
      submitLabel: 'Open dispute',
    );
    if (!mounted || reason == null) {
      return;
    }

    setState(() => _isBusy = true);
    try {
      await ref
          .read(contributionsRepositoryProvider)
          .createContributionDispute(widget.contributionId, reason: reason);
      if (!mounted) {
        return;
      }
      KitToast.success(context, 'Dispute opened');
      ref.invalidate(contributionDisputesProvider(widget.contributionId));
    } catch (error) {
      if (!mounted) {
        return;
      }
      KitToast.error(context, mapFriendlyError(error));
    } finally {
      if (mounted) {
        setState(() => _isBusy = false);
      }
    }
  }

  Future<void> _mediateDispute(String disputeId) async {
    final note = await promptText(
      context: context,
      title: 'Start mediation',
      label: 'Mediation note',
      hint: 'Explain mediation step',
      submitLabel: 'Mark mediating',
    );
    if (!mounted || note == null) {
      return;
    }

    setState(() => _isBusy = true);
    try {
      await ref
          .read(contributionsRepositoryProvider)
          .mediateDispute(disputeId, note: note);
      if (!mounted) {
        return;
      }
      KitToast.success(context, 'Dispute moved to mediating');
      ref.invalidate(contributionDisputesProvider(widget.contributionId));
    } catch (error) {
      if (!mounted) {
        return;
      }
      KitToast.error(context, mapFriendlyError(error));
    } finally {
      if (mounted) {
        setState(() => _isBusy = false);
      }
    }
  }

  Future<void> _resolveDispute(String disputeId) async {
    final outcome = await promptText(
      context: context,
      title: 'Resolve dispute',
      label: 'Outcome',
      hint: 'Resolution outcome',
      submitLabel: 'Resolve',
    );
    if (!mounted || outcome == null) {
      return;
    }

    setState(() => _isBusy = true);
    try {
      await ref
          .read(contributionsRepositoryProvider)
          .resolveDispute(disputeId, outcome: outcome, note: null);
      if (!mounted) {
        return;
      }
      KitToast.success(context, 'Dispute resolved');
      ref.invalidate(contributionDisputesProvider(widget.contributionId));
      await ref.read(groupDetailControllerProvider).refreshAll(widget.groupId);
    } catch (error) {
      if (!mounted) {
        return;
      }
      KitToast.error(context, mapFriendlyError(error));
    } finally {
      if (mounted) {
        setState(() => _isBusy = false);
      }
    }
  }
}

class _DisputeCard extends StatelessWidget {
  const _DisputeCard({
    required this.dispute,
    required this.isAdmin,
    required this.isBusy,
    required this.onMediate,
    required this.onResolve,
  });

  final ContributionDisputeModel dispute;
  final bool isAdmin;
  final bool isBusy;
  final VoidCallback onMediate;
  final VoidCallback onResolve;

  @override
  Widget build(BuildContext context) {
    final statusLabel = switch (dispute.status) {
      ContributionDisputeStatusModel.open => 'OPEN',
      ContributionDisputeStatusModel.mediating => 'MEDIATING',
      ContributionDisputeStatusModel.resolved => 'RESOLVED',
      ContributionDisputeStatusModel.unknown => 'UNKNOWN',
    };

    return KitCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  dispute.reason,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              StatusPill.fromLabel(statusLabel),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text('Opened: ${formatDate(dispute.createdAt, includeTime: true)}'),
          if (dispute.note != null && dispute.note!.trim().isNotEmpty)
            Text('Note: ${dispute.note}'),
          if (dispute.mediationNote != null &&
              dispute.mediationNote!.trim().isNotEmpty)
            Text('Mediation: ${dispute.mediationNote}'),
          if (dispute.resolutionOutcome != null &&
              dispute.resolutionOutcome!.trim().isNotEmpty)
            Text('Outcome: ${dispute.resolutionOutcome}'),
          if (dispute.resolutionNote != null &&
              dispute.resolutionNote!.trim().isNotEmpty)
            Text('Resolution note: ${dispute.resolutionNote}'),
          if (isAdmin &&
              (dispute.status == ContributionDisputeStatusModel.open ||
                  dispute.status ==
                      ContributionDisputeStatusModel.mediating)) ...[
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: [
                if (dispute.status == ContributionDisputeStatusModel.open)
                  KitSecondaryButton(
                    onPressed: isBusy ? null : onMediate,
                    icon: Icons.support_agent_outlined,
                    label: 'Mediate',
                    expand: false,
                  ),
                KitTertiaryButton(
                  onPressed: isBusy ? null : onResolve,
                  icon: Icons.task_alt_outlined,
                  label: 'Resolve',
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
