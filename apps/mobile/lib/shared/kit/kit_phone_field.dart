import 'package:flutter/material.dart';

import '../../app/theme/app_spacing.dart';
import '../utils/phone_numbers.dart';
import 'kit_search_bar.dart';
import 'kit_text_field.dart';

class KitPhoneNumberField extends StatefulWidget {
  const KitPhoneNumberField({
    super.key,
    required this.value,
    required this.onChanged,
    this.label = 'Phone number',
    this.errorText,
    this.enabled = true,
    this.onClearedError,
  });

  final PhoneNumberValue value;
  final ValueChanged<PhoneNumberValue> onChanged;
  final String label;
  final String? errorText;
  final bool enabled;
  final VoidCallback? onClearedError;

  @override
  State<KitPhoneNumberField> createState() => _KitPhoneNumberFieldState();
}

class _KitPhoneNumberFieldState extends State<KitPhoneNumberField> {
  late final TextEditingController _controller;
  late CountryCallingCode _selectedCountry;

  @override
  void initState() {
    super.initState();
    _selectedCountry = widget.value.country;
    _controller = TextEditingController(text: widget.value.rawInput);
  }

  @override
  void didUpdateWidget(covariant KitPhoneNumberField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value.country != widget.value.country) {
      _selectedCountry = widget.value.country;
    }
    if (oldWidget.value.rawInput != widget.value.rawInput &&
        _controller.text != widget.value.rawInput) {
      _controller.text = widget.value.rawInput;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _selectCountry() async {
    if (!widget.enabled) {
      return;
    }

    final selected = await showModalBottomSheet<CountryCallingCode>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => CountryPickerSheet(selected: _selectedCountry),
    );
    if (!mounted || selected == null || selected == _selectedCountry) {
      return;
    }

    setState(() => _selectedCountry = selected);
    widget.onClearedError?.call();
    widget.onChanged(
      PhoneNumberValue(country: selected, rawInput: _controller.text),
    );
  }

  @override
  Widget build(BuildContext context) {
    return KitTextField(
      controller: _controller,
      label: widget.label,
      placeholder: _selectedCountry.nationalExample,
      supportText: _selectedCountry.supportText,
      keyboardType: TextInputType.phone,
      errorText: widget.errorText,
      enabled: widget.enabled,
      readOnly: !widget.enabled,
      prefixIcon: _CountryCodeButton(
        country: _selectedCountry,
        onTap: _selectCountry,
        enabled: widget.enabled,
      ),
      prefixIconConstraints: const BoxConstraints(minWidth: 132, maxWidth: 132),
      onChanged: (value) {
        widget.onClearedError?.call();
        widget.onChanged(
          PhoneNumberValue(country: _selectedCountry, rawInput: value),
        );
      },
    );
  }
}

class CountryPickerSheet extends StatefulWidget {
  const CountryPickerSheet({super.key, required this.selected});

  final CountryCallingCode selected;

  @override
  State<CountryPickerSheet> createState() => _CountryPickerSheetState();
}

class _CountryPickerSheetState extends State<CountryPickerSheet> {
  late final TextEditingController _searchController;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final filtered = kCountryCallingCodes
        .where((country) => country.matchesQuery(_query))
        .toList(growable: false);

    return Padding(
      padding: EdgeInsets.only(
        left: AppSpacing.md,
        right: AppSpacing.md,
        top: AppSpacing.sm,
        bottom: MediaQuery.viewInsetsOf(context).bottom + AppSpacing.md,
      ),
      child: SizedBox(
        height: 520,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Select country code', style: theme.textTheme.titleLarge),
            const SizedBox(height: AppSpacing.md),
            KitSearchBar(
              controller: _searchController,
              hintText: 'Search',
              onChanged: (value) => setState(() => _query = value),
            ),
            const SizedBox(height: AppSpacing.md),
            Expanded(
              child: ClipRRect(
                borderRadius: AppRadius.cardRounded,
                child: Material(
                  color: theme.colorScheme.surface,
                  child: filtered.isEmpty
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(AppSpacing.lg),
                            child: Text(
                              'No matches.',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        )
                      : ListView.separated(
                          itemCount: filtered.length,
                          separatorBuilder: (context, index) => Divider(
                            height: 10,
                            color: theme.colorScheme.surface,
                          ),
                          itemBuilder: (context, index) {
                            final country = filtered[index];
                            final isSelected = country == widget.selected;
                            return ListTile(
                              enabled: country.isoCode == "ET",
                              dense: true,
                              visualDensity: const VisualDensity(vertical: -4),
                              onTap: () => Navigator.of(context).pop(country),
                              tileColor: isSelected
                                  ? theme.colorScheme.primary.withValues(
                                      alpha: 0.10,
                                    )
                                  : null,
                              leading: Text(
                                country.flagEmoji,
                                style: theme.textTheme.headlineSmall,
                              ),
                              title: Text(country.name),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    country.dialCode,
                                    style: theme.textTheme.titleMedium
                                        ?.copyWith(
                                          color: theme
                                              .colorScheme
                                              .onSurfaceVariant,
                                        ),
                                  ),
                                  if (isSelected) ...[
                                    const SizedBox(width: AppSpacing.sm),
                                    Icon(
                                      Icons.check_rounded,
                                      color: theme.colorScheme.primary,
                                    ),
                                  ],
                                ],
                              ),
                            );
                          },
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CountryCodeButton extends StatelessWidget {
  const _CountryCodeButton({
    required this.country,
    required this.onTap,
    required this.enabled,
  });

  final CountryCallingCode country;
  final VoidCallback onTap;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(AppRadius.input),
              bottomLeft: Radius.circular(AppRadius.input),
            ),
            onTap: enabled ? onTap : null,
            child: Padding(
              padding: const EdgeInsets.only(
                left: AppSpacing.sm,
                right: AppSpacing.xs,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(country.flagEmoji, style: theme.textTheme.titleMedium),
                  const SizedBox(width: AppSpacing.xs),
                  Flexible(
                    child: Text(
                      country.dialCode,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: enabled
                            ? theme.colorScheme.onSurface
                            : theme.colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.xxs),
                  Icon(
                    Icons.keyboard_arrow_down_rounded,
                    size: 20,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ],
              ),
            ),
          ),
        ),
        Container(
          width: 1,
          height: 26,
          color: theme.colorScheme.outlineVariant,
        ),
      ],
    );
  }
}
