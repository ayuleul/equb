import 'package:flutter/material.dart';

import '../../app/theme/app_spacing.dart';
import '../../app/theme/app_theme_extensions.dart';

const _kKitSectionHeaderSearchHeight = 48.0;
const _kKitSectionHeaderDefaultAnimationDuration = Duration(milliseconds: 220);

class KitSectionHeaderSearchConfig {
  const KitSectionHeaderSearchConfig({
    required this.controller,
    required this.focusNode,
    required this.isSearching,
    required this.onOpen,
    required this.onClose,
    required this.onChanged,
    this.hintText = 'Search',
    this.searchTooltip = 'Search',
    this.closeTooltip = 'Close search',
    this.animationDuration = _kKitSectionHeaderDefaultAnimationDuration,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final bool isSearching;
  final VoidCallback onOpen;
  final VoidCallback onClose;
  final ValueChanged<String> onChanged;
  final String hintText;
  final String searchTooltip;
  final String closeTooltip;
  final Duration animationDuration;
}

class KitSectionHeader extends StatelessWidget {
  const KitSectionHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.kicker,
    this.actionLabel,
    this.onActionPressed,
    this.action,
    this.searchConfig,
  });

  final String title;
  final String? subtitle;
  final String? kicker;
  final String? actionLabel;
  final VoidCallback? onActionPressed;
  final Widget? action;
  final KitSectionHeaderSearchConfig? searchConfig;

  @override
  Widget build(BuildContext context) {
    final resolvedAction =
        action ??
        ((actionLabel != null && onActionPressed != null)
            ? TextButton(
                onPressed: onActionPressed,
                style: TextButton.styleFrom(
                  minimumSize: const Size(0, 36),
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.xs,
                    vertical: AppSpacing.xxs,
                  ),
                ),
                child: Text(actionLabel!),
              )
            : null);
    final config = searchConfig;
    final hasSearch = config != null;
    final animationDuration =
        config?.animationDuration ?? _kKitSectionHeaderDefaultAnimationDuration;
    final isSearching = config?.isSearching ?? false;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Stack(
        alignment: Alignment.topLeft,
        children: [
          AnimatedOpacity(
            duration: animationDuration,
            curve: Curves.easeOutCubic,
            opacity: isSearching ? 0 : 1,
            child: IgnorePointer(
              ignoring: isSearching,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _KitSectionHeaderCopy(
                      title: title,
                      subtitle: subtitle,
                      kicker: kicker,
                    ),
                  ),
                  if (hasSearch)
                    _KitSectionHeaderCollapsedSearchActions(
                      config: config,
                      action: resolvedAction,
                    )
                  else
                    ?resolvedAction,
                ],
              ),
            ),
          ),
          if (hasSearch)
            Positioned.fill(
              child: IgnorePointer(
                ignoring: !isSearching,
                child: AnimatedOpacity(
                  duration: animationDuration,
                  curve: Curves.easeOutCubic,
                  opacity: isSearching ? 1 : 0,
                  child: _KitSectionHeaderExpandedSearch(config: config),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _KitSectionHeaderCopy extends StatelessWidget {
  const _KitSectionHeaderCopy({
    required this.title,
    required this.subtitle,
    required this.kicker,
  });

  final String title;
  final String? subtitle;
  final String? kicker;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.titleLarge?.copyWith(
            color: colorScheme.onSurface,
          ),
        ),
        if (kicker != null && kicker!.trim().isNotEmpty) ...[
          const SizedBox(height: AppSpacing.xxs),
          Row(
            children: [
              Container(
                width: 7,
                height: 7,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: context.brand.cardAccentStart,
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
              Text(
                kicker!.toUpperCase(),
                style: theme.textTheme.labelSmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  letterSpacing: 1.0,
                ),
              ),
            ],
          ),
        ],
        if (subtitle != null && subtitle!.trim().isNotEmpty) ...[
          const SizedBox(height: AppSpacing.xxs),
          Text(
            subtitle!,
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ],
    );
  }
}

class _KitSectionHeaderCollapsedSearchActions extends StatelessWidget {
  const _KitSectionHeaderCollapsedSearchActions({
    required this.config,
    required this.action,
  });

  final KitSectionHeaderSearchConfig config;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topRight,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            tooltip: config.searchTooltip,
            onPressed: config.onOpen,
            icon: const Icon(Icons.search_rounded),
          ),
          ?action,
        ],
      ),
    );
  }
}

class _KitSectionHeaderExpandedSearch extends StatelessWidget {
  const _KitSectionHeaderExpandedSearch({required this.config});

  final KitSectionHeaderSearchConfig config;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: config.isSearching ? 0 : 1, end: 1),
      duration: config.animationDuration,
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return ClipRect(
          child: Align(
            alignment: Alignment.centerRight,
            widthFactor: value.clamp(0, 1),
            child: child,
          ),
        );
      },
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: SizedBox(
              height: _kKitSectionHeaderSearchHeight,
              child: TextField(
                controller: config.controller,
                focusNode: config.focusNode,
                onChanged: config.onChanged,
                onTapOutside: (_) => config.focusNode.unfocus(),
                autofocus: true,
                textInputAction: TextInputAction.search,
                style: theme.textTheme.bodyLarge,
                decoration: InputDecoration(
                  hintText: config.hintText,
                  hintStyle: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                  prefixIcon: Icon(
                    Icons.search_rounded,
                    color: colorScheme.onSurfaceVariant,
                    size: 20,
                  ),
                  filled: true,
                  fillColor: colorScheme.surfaceContainerLow,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: 14,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: AppRadius.pillRounded,
                    borderSide: BorderSide(color: colorScheme.outlineVariant),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: AppRadius.pillRounded,
                    borderSide: BorderSide(
                      color: colorScheme.primary,
                      width: 1.4,
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.xs),
          SizedBox(
            height: _kKitSectionHeaderSearchHeight,
            child: IconButton(
              tooltip: config.closeTooltip,
              onPressed: config.onClose,
              icon: const Icon(Icons.close_rounded),
            ),
          ),
        ],
      ),
    );
  }
}
