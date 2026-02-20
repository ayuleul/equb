import 'package:flutter/material.dart';

import '../utils/formatters.dart';

class AmountText extends StatelessWidget {
  const AmountText({
    super.key,
    required this.amount,
    required this.currency,
    this.style,
  });

  final num amount;
  final String currency;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    return Text(
      formatCurrency(amount, currency),
      style: style ?? Theme.of(context).textTheme.titleMedium,
    );
  }
}
