import 'package:flutter/material.dart';

enum KitAvatarSize { sm, md, lg }

class KitAvatar extends StatelessWidget {
  const KitAvatar({
    super.key,
    required this.name,
    this.size = KitAvatarSize.md,
  });

  final String name;
  final KitAvatarSize size;

  @override
  Widget build(BuildContext context) {
    final radius = switch (size) {
      KitAvatarSize.sm => 16.0,
      KitAvatarSize.md => 20.0,
      KitAvatarSize.lg => 28.0,
    };

    final initials = _initials(name);
    final colorScheme = Theme.of(context).colorScheme;

    return CircleAvatar(
      radius: radius,
      backgroundColor: colorScheme.surfaceContainerHigh,
      foregroundColor: colorScheme.onSurfaceVariant,
      child: Text(initials, style: Theme.of(context).textTheme.labelLarge),
    );
  }
}

String _initials(String value) {
  final trimmed = value.trim();
  if (trimmed.isEmpty) {
    return 'E';
  }
  final parts = trimmed
      .split(RegExp(r'\s+'))
      .where((part) => part.isNotEmpty)
      .toList(growable: false);
  if (parts.length == 1) {
    return parts.first[0].toUpperCase();
  }
  return (parts.first[0] + parts.last[0]).toUpperCase();
}
