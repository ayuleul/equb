# Equb Mobile UI Kit

## Purpose
`lib/shared/kit/` is the single reusable component layer for UI styling and layout consistency.

## Style tokens
- Background: neutral light gray (`ThemeData.scaffoldBackgroundColor`)
- Surface cards: white
- Radius tokens:
  - `AppRadius.card = 16`
  - `AppRadius.input = 12`
  - `AppRadius.pill = 999`
- Primary accent: `#0077CC`
- Borders and shadows: subtle `outlineVariant` + soft shadow only

## Components
- Layout:
  - `KitScaffold`
  - `KitSectionHeader`
  - `KitCard`
  - `KitDivider`
- Navigation:
  - `KitAppBar`
  - `KitSearchBar`
- Buttons:
  - `KitPrimaryButton`
  - `KitSecondaryButton`
  - `KitTertiaryButton`
- Inputs:
  - `KitTextField`
  - `KitTextArea`
  - `KitDropdownField`
  - `KitNumberField`
- Informative:
  - `KitBadge`
  - `KitBanner`
  - `KitToast`
  - `KitDialog`
  - `KitTooltip`
- Status:
  - `StatusPill`
- Action Sheet:
  - `KitActionSheet`
- Avatar:
  - `KitAvatar`
- Loading/empty/error:
  - `KitEmptyState`
  - `KitSkeletonList`
  - `mapFriendlyError`

## Usage examples
```dart
return KitScaffold(
  title: 'Groups',
  child: ListView(
    children: [
      const KitSectionHeader(title: 'My Equbs'),
      KitCard(
        onTap: () => context.push('/groups/123'),
        child: Row(
          children: const [
            Expanded(child: Text('Weekly Equb')),
            StatusPill.fromLabel('ADMIN'),
          ],
        ),
      ),
      const SizedBox(height: 16),
      KitPrimaryButton(
        label: 'Create',
        icon: Icons.add,
        onPressed: () {},
      ),
    ],
  ),
);
```

```dart
KitToast.success(context, 'Contribution submitted');
```

```dart
await KitActionSheet.show(
  context: context,
  title: 'Admin actions',
  actions: [
    KitActionSheetItem(
      label: 'Confirm',
      icon: Icons.check,
      onPressed: () async {},
    ),
    KitActionSheetItem(
      label: 'Reject',
      icon: Icons.close,
      isDestructive: true,
      onPressed: () async {},
    ),
  ],
);
```

## Strict rules
- Do not add one-off styling directly in feature screens for cards/buttons/inputs/badges.
- Do not use raw `Colors.*` in feature screens.
- Use semantic tint colors (`context.colors`) for badges/pills/status.
- Use `KitScaffold` + standard `16` content padding by default.
- Use `context.go` only for root tab switches and `context.push` for drill-down routes.
