import 'package:intl/intl.dart';

final DateFormat _dateFormat = DateFormat('d MMM yyyy');
final DateFormat _dateTimeFormat = DateFormat('d MMM yyyy, h:mm a');

String formatCurrency(num amount, String currency) {
  final normalizedCurrency = currency.trim().isEmpty ? 'ETB' : currency.trim();
  final formatter = NumberFormat.decimalPattern();
  return '$normalizedCurrency ${formatter.format(amount)}';
}

String formatDate(DateTime date, {bool includeTime = false}) {
  final localDate = date.toLocal();
  return includeTime
      ? _dateTimeFormat.format(localDate)
      : _dateFormat.format(localDate);
}

String formatRelativeTime(DateTime date) {
  final now = DateTime.now();
  final difference = now.difference(date.toLocal());

  if (difference.inSeconds < 60) {
    return 'just now';
  }
  if (difference.inMinutes < 60) {
    return '${difference.inMinutes}m ago';
  }
  if (difference.inHours < 24) {
    return '${difference.inHours}h ago';
  }
  if (difference.inDays < 7) {
    return '${difference.inDays}d ago';
  }

  return formatDate(date);
}
