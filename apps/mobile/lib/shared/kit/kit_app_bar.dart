import 'package:flutter/material.dart';

import '../../app/theme/app_spacing.dart';

class KitAppBar extends StatelessWidget implements PreferredSizeWidget {
  const KitAppBar({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    this.actions,
    this.centerTitle = false,
    this.showBackButton,
    this.showAvatar = true,
    this.avatar,
    this.onTitleTap,
    this.showTitleChevron = false,
    this.backgroundColor,
  });

  final String title;
  final String? subtitle;
  final Widget? leading;
  final List<Widget>? actions;
  final bool centerTitle;
  final bool? showBackButton;
  final bool showAvatar;
  final Widget? avatar;
  final VoidCallback? onTitleTap;
  final bool showTitleChevron;
  final Color? backgroundColor;

  static const double _baseHeight = 76;
  static const double _subtitleHeight = 82;

  bool get _hasSubtitle => subtitle != null && subtitle!.trim().isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final shouldShowBack = showBackButton ?? Navigator.of(context).canPop();
    final useDefaultBackButton = leading == null && shouldShowBack;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final subtitleStyle = theme.textTheme.titleMedium?.copyWith(
      color: colorScheme.primary,
      fontWeight: FontWeight.w600,
    );
    final titleStyle = theme.textTheme.titleLarge?.copyWith(
      fontWeight: FontWeight.w700,
    );
    final resolvedAvatar = showAvatar
        ? (avatar ?? _KitAppBarAvatar.fromTitle(title: title))
        : null;
    final content = Row(
      children: [
        if (resolvedAvatar != null) ...[
          resolvedAvatar,
          const SizedBox(width: AppSpacing.sm),
        ],
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: centerTitle
                ? CrossAxisAlignment.center
                : CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: titleStyle,
                    ),
                  ),
                  if (showTitleChevron) ...[
                    const SizedBox(width: AppSpacing.xxs),
                    Icon(
                      Icons.keyboard_arrow_down_rounded,
                      size: 18,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ],
                ],
              ),
              if (_hasSubtitle)
                Text(
                  subtitle!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: subtitleStyle,
                  textAlign: centerTitle ? TextAlign.center : TextAlign.start,
                ),
            ],
          ),
        ),
      ],
    );

    return AppBar(
      automaticallyImplyLeading: false,
      centerTitle: centerTitle,
      toolbarHeight: _hasSubtitle ? _subtitleHeight : _baseHeight,
      titleSpacing: 4,
      leadingWidth: useDefaultBackButton ? 72 : null,
      backgroundColor:
          backgroundColor ??
          Color.alphaBlend(
            colorScheme.primary.withValues(alpha: 0.10),
            colorScheme.surface,
          ),
      shape: Border(bottom: BorderSide(color: colorScheme.outlineVariant)),
      leading: leading ?? (shouldShowBack ? const KitBackButton() : null),
      title: onTitleTap == null
          ? content
          : InkWell(
              onTap: onTitleTap,
              borderRadius: AppRadius.inputRounded,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.xs,
                  vertical: AppSpacing.xxs,
                ),
                child: content,
              ),
            ),
      actionsPadding: const EdgeInsets.only(right: AppSpacing.xs),
      actions: actions,
    );
  }

  @override
  Size get preferredSize =>
      Size.fromHeight(_hasSubtitle ? _subtitleHeight : _baseHeight);
}

class _KitAppBarAvatar extends StatelessWidget {
  const _KitAppBarAvatar({required this.label});

  final String label;

  factory _KitAppBarAvatar.fromTitle({required String title}) {
    final normalized = title.trim();
    final initial = normalized.isEmpty
        ? 'A'
        : normalized.substring(0, 1).toUpperCase();
    return _KitAppBarAvatar(label: initial);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colorScheme.primary.withValues(alpha: 0.92),
            colorScheme.secondary.withValues(alpha: 0.85),
          ],
        ),
      ),
      child: Center(
        child: Text(
          label,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: colorScheme.onPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class KitBackButton extends StatelessWidget {
  const KitBackButton({super.key, this.onPressed});

  final VoidCallback? onPressed;

  static const double _cornerRadius = 16;
  static const double _buttonSize = 32;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final navigator = Navigator.of(context);
    final callback =
        onPressed ?? (navigator.canPop() ? () => navigator.maybePop() : null);

    return Padding(
      padding: const EdgeInsetsDirectional.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.md,
      ),
      child: SizedBox(
        width: _buttonSize,
        height: _buttonSize,
        child: IconButton(
          onPressed: callback,
          tooltip: MaterialLocalizations.of(context).backButtonTooltip,
          padding: EdgeInsets.zero,
          iconSize: 30,
          style: IconButton.styleFrom(
            backgroundColor: colorScheme.surfaceContainerLow,
            foregroundColor: colorScheme.onSurface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(_cornerRadius),
              side: BorderSide(color: colorScheme.outlineVariant),
            ),
          ),
          icon: const Icon(Icons.chevron_left_rounded),
        ),
      ),
    );
  }
}
