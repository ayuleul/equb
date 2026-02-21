import 'package:flutter/material.dart';

class KitTextField extends StatelessWidget {
  const KitTextField({
    super.key,
    this.controller,
    this.label,
    this.placeholder,
    this.supportText,
    this.errorText,
    this.keyboardType,
    this.onChanged,
    this.obscureText = false,
    this.maxLines = 1,
  });

  final TextEditingController? controller;
  final String? label;
  final String? placeholder;
  final String? supportText;
  final String? errorText;
  final TextInputType? keyboardType;
  final ValueChanged<String>? onChanged;
  final bool obscureText;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      keyboardType: keyboardType,
      obscureText: obscureText,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        hintText: placeholder,
        helperText: supportText,
        errorText: errorText,
      ),
    );
  }
}

class KitTextArea extends StatelessWidget {
  const KitTextArea({
    super.key,
    this.controller,
    this.label,
    this.placeholder,
    this.supportText,
    this.errorText,
    this.onChanged,
    this.maxLines = 4,
  });

  final TextEditingController? controller;
  final String? label;
  final String? placeholder;
  final String? supportText;
  final String? errorText;
  final ValueChanged<String>? onChanged;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return KitTextField(
      controller: controller,
      label: label,
      placeholder: placeholder,
      supportText: supportText,
      errorText: errorText,
      onChanged: onChanged,
      maxLines: maxLines,
    );
  }
}

class KitDropdownField<T> extends StatelessWidget {
  const KitDropdownField({
    super.key,
    required this.items,
    this.value,
    this.onChanged,
    this.label,
    this.supportText,
    this.errorText,
  });

  final List<DropdownMenuItem<T>> items;
  final T? value;
  final ValueChanged<T?>? onChanged;
  final String? label;
  final String? supportText;
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<T>(
      initialValue: value,
      items: items,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        helperText: supportText,
        errorText: errorText,
      ),
    );
  }
}

class KitNumberField extends StatelessWidget {
  const KitNumberField({
    super.key,
    this.controller,
    this.label,
    this.placeholder,
    this.supportText,
    this.errorText,
    this.onChanged,
  });

  final TextEditingController? controller;
  final String? label;
  final String? placeholder;
  final String? supportText;
  final String? errorText;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    return KitTextField(
      controller: controller,
      label: label,
      placeholder: placeholder,
      supportText: supportText,
      errorText: errorText,
      keyboardType: TextInputType.number,
      onChanged: onChanged,
    );
  }
}
