import 'package:flutter/material.dart';

import '../../app/theme/app_spacing.dart';
import '../../app/theme/app_theme_extensions.dart';
import '../../shared/kit/kit.dart';

class ThemePreviewScreen extends StatelessWidget {
  const ThemePreviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final semantic = context.semanticColors;

    return KitScaffold(
      appBar: const KitAppBar(title: 'Theme Preview'),
      padding: EdgeInsets.zero,
      child: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          Text('Colors', style: theme.textTheme.titleLarge),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              _ColorSwatch(
                label: 'Primary',
                color: colorScheme.primary,
                onColor: colorScheme.onPrimary,
              ),
              _ColorSwatch(
                label: 'Surface',
                color: colorScheme.surface,
                onColor: colorScheme.onSurface,
              ),
              _ColorSwatch(
                label: 'Background',
                color: theme.scaffoldBackgroundColor,
                onColor: colorScheme.onSurface,
              ),
              _ColorSwatch(
                label: 'Error',
                color: colorScheme.error,
                onColor: colorScheme.onError,
              ),
              _ColorSwatch(
                label: 'Success',
                color: semantic.success,
                onColor: semantic.onSuccess,
              ),
              _ColorSwatch(
                label: 'Warning',
                color: semantic.warning,
                onColor: semantic.onWarning,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          Text('Typography', style: theme.textTheme.titleLarge),
          const SizedBox(height: AppSpacing.md),
          const _TypographyPreview(),
          const SizedBox(height: AppSpacing.xl),
          Text('Buttons', style: theme.textTheme.titleLarge),
          const SizedBox(height: AppSpacing.md),
          ElevatedButton(onPressed: () {}, child: const Text('ElevatedButton')),
          const SizedBox(height: AppSpacing.sm),
          FilledButton(onPressed: () {}, child: const Text('FilledButton')),
          const SizedBox(height: AppSpacing.sm),
          OutlinedButton(onPressed: () {}, child: const Text('OutlinedButton')),
          const SizedBox(height: AppSpacing.sm),
          TextButton(onPressed: () {}, child: const Text('TextButton')),
          const SizedBox(height: AppSpacing.sm),
          FilledButton(
            onPressed: () {},
            style: FilledButton.styleFrom(
              backgroundColor: colorScheme.error,
              foregroundColor: colorScheme.onError,
            ),
            child: const Text('Destructive Button'),
          ),
          const SizedBox(height: AppSpacing.xl),
          Text('Inputs', style: theme.textTheme.titleLarge),
          const SizedBox(height: AppSpacing.md),
          const TextField(
            decoration: InputDecoration(
              labelText: 'Contribution Amount',
              hintText: 'e.g. 1,000 ETB',
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          const TextField(
            enabled: false,
            decoration: InputDecoration(
              labelText: 'Disabled Field',
              hintText: 'Read-only preview',
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          Text('Cards & Chips', style: theme.textTheme.titleLarge),
          const SizedBox(height: AppSpacing.md),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Cycle #4', style: theme.textTheme.titleMedium),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'Monthly contribution is due in 3 days.',
                    style: theme.textTheme.bodyMedium,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Wrap(
                    spacing: AppSpacing.xs,
                    runSpacing: AppSpacing.xs,
                    children: const [
                      Chip(label: Text('Pending')),
                      Chip(label: Text('Confirmed')),
                      Chip(label: Text('Reminder sent')),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          FilledButton.tonal(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Contribution submitted for review.'),
                  action: SnackBarAction(label: 'Undo', onPressed: _noop),
                ),
              );
            },
            child: const Text('Show SnackBar'),
          ),
          const SizedBox(height: AppSpacing.xl),
          Text('Progress', style: theme.textTheme.titleLarge),
          const SizedBox(height: AppSpacing.md),
          const LinearProgressIndicator(value: 0.62),
          const SizedBox(height: AppSpacing.sm),
          const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }
}

void _noop() {}

class _ColorSwatch extends StatelessWidget {
  const _ColorSwatch({
    required this.label,
    required this.color,
    required this.onColor,
  });

  final String label;
  final Color color;
  final Color onColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 116,
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: color,
        borderRadius: AppRadius.mdRounded,
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: Text(
        label,
        style: Theme.of(
          context,
        ).textTheme.labelMedium?.copyWith(color: onColor),
      ),
    );
  }
}

class _TypographyPreview extends StatelessWidget {
  const _TypographyPreview();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    final entries = <(String, TextStyle?)>[
      ('displaySmall', textTheme.displaySmall),
      ('headlineMedium', textTheme.headlineMedium),
      ('titleLarge', textTheme.titleLarge),
      ('titleMedium', textTheme.titleMedium),
      ('bodyLarge', textTheme.bodyLarge),
      ('bodyMedium', textTheme.bodyMedium),
      ('labelLarge', textTheme.labelLarge),
      ('labelMedium', textTheme.labelMedium),
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (final entry in entries) ...[
              Text(entry.$1, style: textTheme.labelSmall),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'The quick brown fox jumps over the lazy dog',
                style: entry.$2,
              ),
              const SizedBox(height: AppSpacing.md),
            ],
          ],
        ),
      ),
    );
  }
}
