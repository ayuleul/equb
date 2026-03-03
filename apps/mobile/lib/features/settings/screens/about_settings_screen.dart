import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../../app/theme/app_spacing.dart';
import '../../../shared/kit/kit.dart';

final packageInfoProvider = FutureProvider<PackageInfo>((ref) {
  return PackageInfo.fromPlatform();
});

class AboutSettingsScreen extends ConsumerWidget {
  const AboutSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final packageInfo = ref.watch(packageInfoProvider);

    return KitScaffold(
      appBar: const KitAppBar(title: 'About', showAvatar: false),
      child: ListView(
        children: [
          KitCard(
            child: packageInfo.when(
              data: (info) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _ReadOnlyRow(label: 'App version', value: info.version),
                  const SizedBox(height: AppSpacing.sm),
                  _ReadOnlyRow(label: 'Build number', value: info.buildNumber),
                ],
              ),
              loading: () => const Padding(
                padding: EdgeInsets.symmetric(vertical: AppSpacing.sm),
                child: LinearProgressIndicator(minHeight: 2),
              ),
              error: (_, _) => const _ReadOnlyRow(
                label: 'App version',
                value: 'Unavailable',
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ReadOnlyRow extends StatelessWidget {
  const _ReadOnlyRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Expanded(child: Text(label, style: theme.textTheme.bodyMedium)),
        Text(value, style: theme.textTheme.titleSmall),
      ],
    );
  }
}
