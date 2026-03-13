import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/kit/kit.dart';
import '../../../shared/utils/api_error_mapper.dart';
import '../../profile/profile_reputation_provider.dart';
import '../widgets/account_sections.dart';

class AccountActivitySettingsScreen extends ConsumerWidget {
  const AccountActivitySettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reputationHistoryAsync = ref.watch(
      currentUserReputationHistoryProvider,
    );

    return KitScaffold(
      appBar: const KitAppBar(title: 'Recent activity', showAvatar: false),
      child: ListView(
        children: [
          reputationHistoryAsync.when(
            loading: () => const KitCard(
              child: SizedBox(
                height: 180,
                child: KitSkeletonList(itemCount: 4),
              ),
            ),
            error: (error, _) => KitCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [Text(mapApiErrorToMessage(error))],
              ),
            ),
            data: (history) =>
                ReputationTimelineCard(history: history, limit: 20),
          ),
        ],
      ),
    );
  }
}
