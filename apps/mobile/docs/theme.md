# Equb Mobile Theme System

This document defines design tokens and usage patterns for `apps/mobile`.

## Design tokens

### Color tokens
- Brand:
  - `AppColors.primary`: `#0077CC`
- Neutral surfaces:
  - Light: `lightBackground`, `lightSurface`, `lightSurfaceAlt`
  - Dark: `darkBackground`, `darkSurface`, `darkSurfaceAlt`
- Semantic extension (`AppSemanticColors`):
  - `success` / `onSuccess` / `successContainer` / `onSuccessContainer`
  - `warning` / `onWarning` / `warningContainer` / `onWarningContainer`
  - `info` / `onInfo` / `infoContainer` / `onInfoContainer`

Use `Theme.of(context).colorScheme` for Material roles (`primary`, `error`, `surface`, etc.), and `context.semanticColors` for non-Material semantic states.

### Typography scale
- Base body sizes are locked to:
  - `bodyMedium = 14`
  - `bodyLarge = 16`
- Families of styles are provided in `AppTypography.textTheme(...)`:
  - `display*`
  - `headline*`
  - `title*`
  - `body*`
  - `label*`
- Font weights are centralized in `AppFontWeight`.

### Spacing and radius
- Spacing tokens (`AppSpacing`): `4, 8, 12, 16, 20, 24, 32, 40`
- Radius tokens (`AppRadius`):
  - `sm = 10`
  - `md = 14` (default app corner radius)
  - `lg = 18`
  - `pill = 999`

## Semantic color usage
- Success states: `context.semanticColors.success*`
- Warning states: `context.semanticColors.warning*`
- Informational states: `context.semanticColors.info*`
- Error/destructive states: `Theme.of(context).colorScheme.error*`

## Usage guidelines

### Primary button
```dart
FilledButton(
  onPressed: onPressed,
  child: const Text('Continue'),
)
```

### Secondary button
```dart
OutlinedButton(
  onPressed: onPressed,
  child: const Text('Skip'),
)
```

### Destructive button
```dart
FilledButton(
  onPressed: onDelete,
  style: FilledButton.styleFrom(
    backgroundColor: Theme.of(context).colorScheme.error,
    foregroundColor: Theme.of(context).colorScheme.onError,
  ),
  child: const Text('Delete'),
)
```

### Text field
```dart
const TextField(
  decoration: InputDecoration(
    labelText: 'Phone Number',
    hintText: '+251 ...',
  ),
)
```

## Source files
- `lib/app/theme/app_theme.dart`
- `lib/app/theme/app_colors.dart`
- `lib/app/theme/app_typography.dart`
- `lib/app/theme/app_spacing.dart`
- `lib/app/theme/app_components.dart`
- `lib/app/theme/app_theme_extensions.dart`
