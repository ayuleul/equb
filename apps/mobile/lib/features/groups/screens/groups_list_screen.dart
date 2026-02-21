import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../data/models/group_model.dart';
import '../../../shared/kit/kit.dart';
import '../../../shared/ui/ui.dart';
import '../../../shared/widgets/error_view.dart';
import '../groups_list_controller.dart';

class GroupsListScreen extends ConsumerStatefulWidget {
  const GroupsListScreen({super.key});

  @override
  ConsumerState<GroupsListScreen> createState() => _GroupsListScreenState();
}

class _GroupsListScreenState extends ConsumerState<GroupsListScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(groupsListProvider);

    ref.listen(groupsListProvider, (previous, next) {
      final previousError = previous?.errorMessage;
      final nextError = next.errorMessage;
      if (nextError != null &&
          nextError.isNotEmpty &&
          previousError != nextError) {
        AppSnackbars.error(context, nextError);
      }
    });

    Future<void> onRefresh() {
      return ref.read(groupsListProvider.notifier).refresh();
    }

    return KitScaffold(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                tooltip: 'Notifications',
                onPressed: () => context.push(AppRoutePaths.notifications),
                icon: const Icon(Icons.notifications_outlined),
              ),
            ],
          ),
          KitSearchBar(
            controller: _searchController,
            hintText: 'Search Equbs',
            onChanged: (value) => setState(() => _query = value.trim()),
          ),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              KitPrimaryButton(
                onPressed: () => context.push(AppRoutePaths.groupsCreate),
                expand: false,
                icon: Icons.add,
                label: 'Create',
              ),
              KitSecondaryButton(
                onPressed: () => context.push(AppRoutePaths.groupsJoin),
                expand: false,
                icon: Icons.group_add_outlined,
                label: 'Join',
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Expanded(
            child: _GroupsBody(
              state: state,
              query: _query,
              onRetry: () => ref.read(groupsListProvider.notifier).load(),
              onRefresh: onRefresh,
            ),
          ),
        ],
      ),
    );
  }
}

class _GroupsBody extends StatelessWidget {
  const _GroupsBody({
    required this.state,
    required this.query,
    required this.onRetry,
    required this.onRefresh,
  });

  final GroupsListState state;
  final String query;
  final VoidCallback onRetry;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    if (state.isLoading && !state.hasData) {
      return const KitSkeletonList(itemCount: 4);
    }

    if (state.errorMessage != null && !state.hasData) {
      return ErrorView(message: state.errorMessage!, onRetry: onRetry);
    }

    if (!state.hasData) {
      return KitEmptyState(
        icon: Icons.groups_2_outlined,
        title: 'No groups yet',
        message: 'Create a group or join one with an invite code.',
        ctaLabel: 'Create group',
        onCtaPressed: () => context.push(AppRoutePaths.groupsCreate),
      );
    }

    final normalizedQuery = query.toLowerCase();
    final filtered = normalizedQuery.isEmpty
        ? state.items
        : state.items
              .where(
                (group) => group.name.toLowerCase().contains(normalizedQuery),
              )
              .toList(growable: false);

    if (filtered.isEmpty) {
      return const KitEmptyState(
        icon: Icons.search_off_outlined,
        title: 'No matching groups',
        message: 'Try a different name or clear the search.',
      );
    }

    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView.separated(
        itemCount: filtered.length,
        separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
        itemBuilder: (context, index) => _GroupCard(group: filtered[index]),
      ),
    );
  }
}

class _GroupCard extends StatelessWidget {
  const _GroupCard({required this.group});

  final GroupModel group;

  @override
  Widget build(BuildContext context) {
    final frequency = switch (group.frequency) {
      GroupFrequencyModel.weekly => 'WEEKLY',
      GroupFrequencyModel.monthly => 'MONTHLY',
      GroupFrequencyModel.unknown => 'UNKNOWN',
    };
    final role = switch (group.membership?.role) {
      MemberRoleModel.admin => 'ADMIN',
      MemberRoleModel.member => 'MEMBER',
      _ => 'MEMBER',
    };

    return KitCard(
      onTap: () => context.push(AppRoutePaths.groupDetail(group.id)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  group.name,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              StatusPill.fromLabel(role),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          AmountText(
            amount: group.contributionAmount,
            currency: group.currency,
          ),
          const SizedBox(height: AppSpacing.xs),
          Row(
            children: [
              StatusPill.fromLabel(frequency),
              const SizedBox(width: AppSpacing.xs),
              StatusPill.fromLabel(group.status.name.toUpperCase()),
            ],
          ),
        ],
      ),
    );
  }
}
