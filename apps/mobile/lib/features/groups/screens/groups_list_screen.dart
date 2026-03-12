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
import '../widgets/my_equb_card.dart';

class GroupsListScreen extends ConsumerStatefulWidget {
  const GroupsListScreen({super.key});

  @override
  ConsumerState<GroupsListScreen> createState() => _GroupsListScreenState();
}

class _GroupsListScreenState extends ConsumerState<GroupsListScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  String _query = '';
  bool _isSearching = false;

  Future<void> _showGroupActions() {
    return KitActionSheet.show(
      context: context,
      title: 'Group actions',
      actions: [
        KitActionSheetItem(
          label: 'Create Equb',
          icon: Icons.add,
          onPressed: () => context.push(AppRoutePaths.groupsCreate),
        ),
        KitActionSheetItem(
          label: 'Join Equb',
          icon: Icons.group_add_outlined,
          onPressed: () => context.push(AppRoutePaths.groupsJoin),
        ),
        KitActionSheetItem(
          label: 'Discover Public',
          icon: Icons.travel_explore_outlined,
          onPressed: () => context.push(AppRoutePaths.groupsDiscover),
        ),
      ],
    );
  }

  void _openSearch() {
    setState(() => _isSearching = true);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      _searchFocusNode.requestFocus();
    });
  }

  void _closeSearch() {
    _searchController.clear();
    _searchFocusNode.unfocus();
    setState(() {
      _isSearching = false;
      _query = '';
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showGroupActions,
        icon: const Icon(Icons.add),
        label: const Text('New'),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          KitSectionHeader(
            title: 'My Equbs',
            subtitle: 'Manage active groups and create new ones.',
            searchConfig: KitSectionHeaderSearchConfig(
              controller: _searchController,
              focusNode: _searchFocusNode,
              isSearching: _isSearching,
              onOpen: _openSearch,
              onClose: _closeSearch,
              onChanged: (value) => setState(() => _query = value.trim()),
              hintText: 'Search groups',
            ),
            action: IconButton(
              tooltip: 'Notifications',
              onPressed: () => context.push(AppRoutePaths.notifications),
              icon: const Icon(Icons.notifications_outlined),
            ),
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

class _GroupCard extends ConsumerWidget {
  const _GroupCard({required this.group});

  final GroupModel group;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MyEqubCard(group: group);
  }
}
