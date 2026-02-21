import 'package:flutter/material.dart';

class KitAppBar extends StatelessWidget implements PreferredSizeWidget {
  const KitAppBar({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    this.actions,
    this.centerTitle = true,
    this.showBackButton,
  });

  final String title;
  final String? subtitle;
  final Widget? leading;
  final List<Widget>? actions;
  final bool centerTitle;
  final bool? showBackButton;

  static const double _baseHeight = 64;
  static const double _subtitleHeight = 78;

  bool get _hasSubtitle => subtitle != null && subtitle!.trim().isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final shouldShowBack = showBackButton ?? Navigator.of(context).canPop();
    final useDefaultBackButton = leading == null && shouldShowBack;
    final subtitleStyle = Theme.of(context).textTheme.bodySmall?.copyWith(
      color: Theme.of(context).colorScheme.onSurfaceVariant,
    );

    return AppBar(
      automaticallyImplyLeading: false,
      centerTitle: centerTitle,
      toolbarHeight: _hasSubtitle ? _subtitleHeight : _baseHeight,
      titleSpacing: 16,
      leadingWidth: useDefaultBackButton ? 72 : null,
      leading: leading ?? (shouldShowBack ? const KitBackButton() : null),
      title: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: centerTitle
            ? CrossAxisAlignment.center
            : CrossAxisAlignment.start,
        children: [
          Text(title),
          if (_hasSubtitle)
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(
                subtitle!,
                style: subtitleStyle,
                textAlign: centerTitle ? TextAlign.center : TextAlign.start,
              ),
            ),
        ],
      ),
      actions: actions,
    );
  }

  @override
  Size get preferredSize =>
      Size.fromHeight(_hasSubtitle ? _subtitleHeight : _baseHeight);
}

class KitBackButton extends StatelessWidget {
  const KitBackButton({super.key, this.onPressed});

  final VoidCallback? onPressed;

  static const double _cornerRadius = 14;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final navigator = Navigator.of(context);
    final callback =
        onPressed ?? (navigator.canPop() ? () => navigator.maybePop() : null);

    return Padding(
      padding: const EdgeInsetsDirectional.all(10),
      child: IconButton(
        onPressed: callback,
        tooltip: MaterialLocalizations.of(context).backButtonTooltip,
        style: IconButton.styleFrom(
          padding: EdgeInsets.zero,
          iconSize: 34,
          foregroundColor: colorScheme.onSurface,
          backgroundColor: colorScheme.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(_cornerRadius),
            side: BorderSide(color: colorScheme.outlineVariant, width: 1.5),
          ),
        ),
        icon: const Icon(Icons.chevron_left_rounded),
      ),
    );
  }
}
