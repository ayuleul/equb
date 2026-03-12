import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../shared/kit/kit.dart';
import '../../../shared/utils/api_error_mapper.dart';
import '../public_groups_controller.dart';
import '../widgets/public_equb_card.dart';

class PublicGroupsScreen extends ConsumerWidget {
  const PublicGroupsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final groupsAsync = ref.watch(publicGroupsProvider);

    return KitScaffold(
      appBar: const KitAppBar(
        title: 'Discover groups',
        subtitle: 'Browse public Equbs that accept join requests',
      ),
      child: RefreshIndicator(
        onRefresh: () =>
            ref.read(publicGroupsControllerProvider).refreshPublicGroups(),
        child: groupsAsync.when(
          loading: () => const KitSkeletonList(itemCount: 4),
          error: (error, _) => KitEmptyState(
            icon: Icons.travel_explore_outlined,
            title: 'Unable to load public groups',
            message: mapApiErrorToMessage(error),
            ctaLabel: 'Retry',
            onCtaPressed: () => ref.invalidate(publicGroupsProvider),
          ),
          data: (groups) {
            if (groups.isEmpty) {
              return const KitEmptyState(
                icon: Icons.groups_2_outlined,
                title: 'No public groups yet',
                message:
                    'Public Equbs will appear here when admins make them discoverable.',
              );
            }

            return ListView.separated(
              itemCount: groups.length,
              separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
              itemBuilder: (context, index) =>
                  PublicEqubCard(group: groups[index]),
            );
          },
        ),
      ),
    );
  }
}
