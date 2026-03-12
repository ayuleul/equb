import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/router.dart';
import '../../app/theme/app_spacing.dart';
import '../../data/models/public_group_model.dart';
import '../../shared/kit/kit.dart';
import '../../shared/utils/api_error_mapper.dart';
import '../auth/auth_controller.dart';
import '../groups/groups_list_controller.dart';
import '../groups/public_groups_controller.dart';
import '../groups/widgets/my_equb_card.dart';
import '../groups/widgets/public_equb_card.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final user = ref.watch(currentUserProvider);
    final groupsState = ref.watch(groupsListProvider);
    final publicGroupsAsync = ref.watch(publicGroupsProvider);
    final displayName = user?.firstName ?? user?.phone ?? 'there';

    return KitScaffold(
      child: RefreshIndicator(
        onRefresh: () => Future.wait([
          ref.read(groupsListProvider.notifier).refresh(),
          ref.read(publicGroupsControllerProvider).refreshPublicGroups(),
        ]),
        child: ListView(
          children: [
            KitSectionHeader(
              title: 'Hi, $displayName',
              titleStyle: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.w700,
              ),
              subtitle: 'Your groups first, then public equbs worth joining.',
              action: IconButton(
                tooltip: 'Notifications',
                onPressed: () => context.push(AppRoutePaths.notifications),
                icon: const Icon(Icons.notifications_outlined),
              ),
            ),
            KitSectionHeader(
              title: 'My Equbs',
              subtitle: 'Swipe through your groups and jump back in quickly.',
              actionLabel: 'View all',
              onActionPressed: () => context.go(AppRoutePaths.groups),
            ),
            _MyEqubsRail(state: groupsState),
            const SizedBox(height: AppSpacing.lg),
            Row(
              children: [
                Expanded(
                  child: KitPrimaryButton(
                    label: 'Create Equb',
                    icon: Icons.add_rounded,
                    expand: false,
                    onPressed: () => context.push(AppRoutePaths.groupsCreate),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: KitSecondaryButton(
                    label: 'Join by Code',
                    icon: Icons.group_add_outlined,
                    expand: false,
                    onPressed: () => context.push(AppRoutePaths.groupsJoin),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            KitSectionHeader(
              title: 'Discover Public Equbs',
              subtitle: 'Browse open groups that accept join requests.',
              actionLabel: 'See all',
              onActionPressed: () => context.push(AppRoutePaths.groupsDiscover),
            ),
            _DiscoverPublicGroupsList(publicGroupsAsync: publicGroupsAsync),
          ],
        ),
      ),
    );
  }
}

class _MyEqubsRail extends StatelessWidget {
  const _MyEqubsRail({required this.state});

  final GroupsListState state;

  @override
  Widget build(BuildContext context) {
    if (state.isLoading && !state.hasData) {
      return SizedBox(
        height: 188,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: 3,
          separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.sm),
          itemBuilder: (context, index) => const SizedBox(
            width: 286,
            child: KitCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  KitSkeletonBox(height: 20, width: 150),
                  SizedBox(height: AppSpacing.sm),
                  KitSkeletonBox(height: 14, width: 90),
                  SizedBox(height: AppSpacing.md),
                  KitSkeletonBox(height: 16, width: 190),
                  SizedBox(height: AppSpacing.sm),
                  KitSkeletonBox(height: 14, width: 160),
                ],
              ),
            ),
          ),
        ),
      );
    }

    if (state.errorMessage != null && !state.hasData) {
      return KitCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Unable to load your groups',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(state.errorMessage!),
          ],
        ),
      );
    }

    if (!state.hasData) {
      return KitEmptyState(
        icon: Icons.groups_2_outlined,
        title: 'No equbs yet',
        message:
            'Create a group or join one with an invite code to get started.',
        ctaLabel: 'Create Equb',
        onCtaPressed: () => context.push(AppRoutePaths.groupsCreate),
      );
    }

    return SizedBox(
      height: 188,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: state.items.length,
        separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.sm),
        itemBuilder: (context, index) =>
            MyEqubCard(group: state.items[index], width: 320, compact: true),
      ),
    );
  }
}

class _DiscoverPublicGroupsList extends StatelessWidget {
  const _DiscoverPublicGroupsList({required this.publicGroupsAsync});

  final AsyncValue<List<PublicGroupModel>> publicGroupsAsync;

  @override
  Widget build(BuildContext context) {
    return publicGroupsAsync.when(
      loading: () => const _PublicGroupsLoadingState(),
      error: (error, _) => KitEmptyState(
        icon: Icons.travel_explore_outlined,
        title: 'Unable to load public groups',
        message: mapApiErrorToMessage(error),
        ctaLabel: 'Open discover',
        onCtaPressed: () => context.push(AppRoutePaths.groupsDiscover),
      ),
      data: (groups) {
        if (groups.isEmpty) {
          return const KitEmptyState(
            icon: Icons.travel_explore_outlined,
            title: 'No public equbs yet',
            message:
                'Public Equbs will appear here when admins make them discoverable.',
          );
        }

        final visibleGroups = groups.take(4).toList(growable: false);
        return Column(
          children: [
            for (var i = 0; i < visibleGroups.length; i++) ...[
              PublicEqubCard(group: visibleGroups[i]),
              if (i != visibleGroups.length - 1)
                const SizedBox(height: AppSpacing.sm),
            ],
          ],
        );
      },
    );
  }
}

class _PublicGroupsLoadingState extends StatelessWidget {
  const _PublicGroupsLoadingState();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List<Widget>.generate(3, (index) {
        return Padding(
          padding: EdgeInsets.only(bottom: index == 2 ? 0 : AppSpacing.sm),
          child: const KitCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                KitSkeletonBox(height: 18, width: 190),
                SizedBox(height: AppSpacing.sm),
                KitSkeletonBox(height: 14, width: 240),
                SizedBox(height: AppSpacing.md),
                KitSkeletonBox(height: 32),
                SizedBox(height: AppSpacing.md),
                KitSkeletonBox(height: 14, width: 180),
              ],
            ),
          ),
        );
      }),
    );
  }
}
