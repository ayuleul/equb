import 'package:flutter/material.dart';

import '../kit/kit.dart';

class AppTextField extends StatelessWidget {
  const AppTextField({
    super.key,
    this.controller,
    this.focusNode,
    this.label,
    this.labelTooltip,
    this.hint,
    this.keyboardType,
    this.onChanged,
    this.obscureText = false,
  });

  final TextEditingController? controller;
  final FocusNode? focusNode;
  final String? label;
  final String? labelTooltip;
  final String? hint;
  final TextInputType? keyboardType;
  final ValueChanged<String>? onChanged;
  final bool obscureText;

  @override
  Widget build(BuildContext context) {
    return KitTextField(
      controller: controller,
      focusNode: focusNode,
      label: label,
      labelTooltip: labelTooltip,
      placeholder: hint,
      keyboardType: keyboardType,
      onChanged: onChanged,
      obscureText: obscureText,
    );
  }
}
