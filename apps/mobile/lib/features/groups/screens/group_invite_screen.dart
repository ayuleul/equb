import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_spacing.dart';
import '../../../data/models/group_model.dart';
import '../../../shared/kit/kit.dart';
import '../../../shared/ui/ui.dart';
import '../../../shared/widgets/error_view.dart';
import '../../../shared/widgets/loading_view.dart';
import '../group_detail_controller.dart';
import '../invite_controller.dart';

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

          final invite = inviteState.invite;

          return ListView(
            children: [
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
