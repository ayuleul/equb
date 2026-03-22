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
    final sectionsAsync = ref.watch(discoverSectionsProvider);

    return KitScaffold(
      appBar: const KitAppBar(title: 'Discover groups'),
      child: RefreshIndicator(
        onRefresh: () =>
            ref.read(publicGroupsControllerProvider).refreshPublicGroups(),
        child: sectionsAsync.when(
          loading: () => const KitSkeletonList(itemCount: 4),
          error: (error, _) => KitEmptyState(
            icon: Icons.travel_explore_outlined,
            title: 'Unable to load public groups',
            message: mapApiErrorToMessage(error),
            ctaLabel: 'Retry',
            onCtaPressed: () => ref.invalidate(discoverSectionsProvider),
          ),
          data: (sections) {
            if (sections.isEmpty) {
              return const KitEmptyState(
                icon: Icons.groups_2_outlined,
                title: 'No public groups yet',
                message: 'Nothing to join right now.',
              );
            }

            return ListView(
              children: [
                for (final section in sections) ...[
                  KitSectionHeader(title: section.title),
                  for (var i = 0; i < section.items.length; i++) ...[
                    PublicEqubCard(group: section.items[i]),
                    if (i != section.items.length - 1)
                      const SizedBox(height: AppSpacing.sm),
                  ],
                  const SizedBox(height: AppSpacing.lg),
                ],
              ],
            );
          },
        ),
      ),
    );
  }
}
