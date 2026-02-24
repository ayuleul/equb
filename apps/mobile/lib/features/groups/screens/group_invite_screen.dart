import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/bootstrap.dart';
import '../../../app/router.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../data/models/group_model.dart';
import '../../../shared/kit/kit.dart';
import '../../../shared/ui/ui.dart';
import '../../../shared/widgets/error_view.dart';
import '../../../shared/widgets/loading_view.dart';
import '../group_detail_controller.dart';
import '../invite_controller.dart';

final groupInviteLockStatusProvider = FutureProvider.family<bool, String>((
  ref,
  groupId,
) async {
  final repository = ref.watch(groupsRepositoryProvider);
  return repository.hasOpenCycle(groupId);
});

class GroupInviteScreen extends ConsumerWidget {
  const GroupInviteScreen({super.key, required this.groupId});

  final String groupId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final groupAsync = ref.watch(groupDetailProvider(groupId));
    final inviteState = ref.watch(inviteProvider(groupId));

    ref.listen(inviteProvider(groupId), (previous, next) {
      final previousError = previous?.errorMessage;
      final nextError = next.errorMessage;

      if (nextError != null &&
          nextError.isNotEmpty &&
          previousError != nextError) {
        AppSnackbars.error(context, nextError);
      }
    });

    return KitScaffold(
      appBar: const KitAppBar(
        title: 'Invite members',
        subtitle: 'Generate a join code for this group',
      ),
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
              message: 'Only admins can generate invite codes.',
            );
          }
          if (!group.canInviteMembers) {
            return EmptyState(
              icon: Icons.rule_folder_outlined,
              title: 'Setup required',
              message: 'Complete group rules before generating invite codes.',
              ctaLabel: 'Open setup',
              onCtaPressed: () =>
                  context.push(AppRoutePaths.groupSetup(groupId)),
            );
          }
          final openCycleAsync = ref.watch(
            groupInviteLockStatusProvider(groupId),
          );

          final invite = inviteState.invite;

          return ListView(
            children: [
              if (openCycleAsync.valueOrNull == true) ...[
                const KitBanner(
                  title: 'Cycle in progress',
                  message:
                      'Invites can be sent, but people can’t join until the current cycle closes.',
                  tone: KitBadgeTone.info,
                  icon: Icons.info_outline_rounded,
                ),
                const SizedBox(height: AppSpacing.md),
              ],
              FilledButton.icon(
                onPressed: inviteState.isLoading
                    ? null
                    : () => ref
                          .read(inviteProvider(groupId).notifier)
                          .createInvite(),
                icon: const Icon(Icons.qr_code_2_outlined),
                label: Text(
                  invite == null ? 'Generate invite code' : 'Generate new code',
                ),
              ),
              if (invite != null) ...[
                const SizedBox(height: AppSpacing.md),
                EqubCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Send this code to members',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      SelectableText(
                        invite.code,
                        style: Theme.of(context).textTheme.displaySmall,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      OutlinedButton.icon(
                        onPressed: () async {
                          await Clipboard.setData(
                            ClipboardData(text: invite.code),
                          );
                          if (!context.mounted) {
                            return;
                          }
                          AppSnackbars.success(context, 'Invite code copied');
                        },
                        icon: const Icon(Icons.copy_rounded),
                        label: const Text('Copy code'),
                      ),
                      if (invite.joinUrl != null &&
                          invite.joinUrl!.trim().isNotEmpty) ...[
                        const SizedBox(height: AppSpacing.md),
                        Text(
                          'Join URL',
                          style: Theme.of(context).textTheme.labelLarge,
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        SelectableText(invite.joinUrl!),
                      ],
                    ],
                  ),
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}
