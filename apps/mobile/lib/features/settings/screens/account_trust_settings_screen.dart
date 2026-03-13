import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/kit/kit.dart';
import '../../../shared/utils/api_error_mapper.dart';
import '../../profile/profile_reputation_provider.dart';
import '../widgets/account_sections.dart';

class AccountTrustSettingsScreen extends ConsumerWidget {
  const AccountTrustSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reputationAsync = ref.watch(currentUserReputationProvider);

    return KitScaffold(
      appBar: const KitAppBar(title: 'Trust identity', showAvatar: false),
      child: ListView(
        children: [
          reputationAsync.when(
            loading: () => const KitCard(
              child: SizedBox(
                height: 180,
                child: KitSkeletonList(itemCount: 5),
              ),
            ),
            error: (error, _) => KitCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [Text(mapApiErrorToMessage(error))],
              ),
            ),
            data: (profile) => profile == null
                ? const SizedBox.shrink()
                : TrustIdentityCard(profile: profile),
          ),
        ],
      ),
    );
  }
}
