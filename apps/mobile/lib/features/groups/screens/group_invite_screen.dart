import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_spacing.dart';
import '../../../data/models/group_model.dart';
import '../../../shared/widgets/primary_button.dart';
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
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(nextError)));
      }
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Create Invite')),
      body: SafeArea(
        child: groupAsync.when(
          loading: () => const LoadingView(message: 'Loading group...'),
          error: (error, _) => Center(child: Text(error.toString())),
          data: (group) {
            final isAdmin = group.membership?.role == MemberRoleModel.admin;
            if (!isAdmin) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Text(
                    'Only admins can generate invite codes for this group.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              );
            }

            final invite = inviteState.invite;

            return ListView(
              padding: const EdgeInsets.all(AppSpacing.md),
              children: [
                Text(
                  'Send this code to members.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: AppSpacing.md),
                PrimaryButton(
                  label: invite == null
                      ? 'Generate Invite Code'
                      : 'Generate New Code',
                  isLoading: inviteState.isLoading,
                  onPressed: inviteState.isLoading
                      ? null
                      : () => ref
                            .read(inviteProvider(groupId).notifier)
                            .createInvite(),
                ),
                if (invite != null) ...[
                  const SizedBox(height: AppSpacing.lg),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Invite code',
                            style: Theme.of(context).textTheme.labelLarge,
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          SelectableText(
                            invite.code,
                            style: Theme.of(context).textTheme.headlineMedium,
                          ),
                          const SizedBox(height: AppSpacing.md),
                          OutlinedButton.icon(
                            onPressed: () async {
                              await Clipboard.setData(
                                ClipboardData(text: invite.code),
                              );
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Invite code copied.'),
                                  ),
                                );
                              }
                            },
                            icon: const Icon(Icons.copy),
                            label: const Text('Copy Code'),
                          ),
                          if (invite.joinUrl != null &&
                              invite.joinUrl!.isNotEmpty) ...[
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
