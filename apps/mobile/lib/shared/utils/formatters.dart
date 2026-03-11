import 'package:intl/intl.dart';

final DateFormat _dateFormat = DateFormat('d MMM yyyy');
final DateFormat _dateTimeFormat = DateFormat('d MMM yyyy, h:mm a');
final DateFormat _calendarDateFormat = DateFormat('MMM d, yyyy');
final DateFormat _shortMonthDayFormat = DateFormat('MMM d');
final DateFormat _timeFormat = DateFormat('h:mm a');

enum DueCountdownTone { neutral, warning, danger }

class DueCountdownData {
  const DueCountdownData({
    required this.label,
    required this.tone,
    required this.dayDelta,
    required this.isOverdue,
  });

  final String label;
  final DueCountdownTone tone;
  final int dayDelta;
  final bool isOverdue;
}

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

String formatCalendarDate(DateTime date) {
  return _calendarDateFormat.format(date.toLocal());
}

String formatShortDate(DateTime date) {
  return _shortMonthDayFormat.format(date.toLocal());
}

String formatShortDateTime(DateTime date) {
  final localDate = date.toLocal();
  return '${_shortMonthDayFormat.format(localDate)} • ${_timeFormat.format(localDate)}';
}

DueCountdownData getDueCountdown(DateTime dueDate, {DateTime? now}) {
  final localNow = (now ?? DateTime.now()).toLocal();
  final localDue = dueDate.toLocal();
  final today = DateTime(localNow.year, localNow.month, localNow.day);
  final dueDay = DateTime(localDue.year, localDue.month, localDue.day);
  final dayDelta = dueDay.difference(today).inDays;

  if (dayDelta < 0) {
    final overdueDays = dayDelta.abs();
    return DueCountdownData(
      label: 'Overdue by $overdueDays ${overdueDays == 1 ? 'day' : 'days'}',
      tone: DueCountdownTone.danger,
      dayDelta: dayDelta,
      isOverdue: true,
    );
  }

  if (dayDelta == 0) {
    return const DueCountdownData(
      label: 'Due today',
      tone: DueCountdownTone.warning,
      dayDelta: 0,
      isOverdue: false,
    );
  }

  if (dayDelta == 1) {
    return const DueCountdownData(
      label: 'Due tomorrow',
      tone: DueCountdownTone.warning,
      dayDelta: 1,
      isOverdue: false,
    );
  }

  return DueCountdownData(
    label: 'Due in $dayDelta days',
    tone: DueCountdownTone.neutral,
    dayDelta: dayDelta,
    isOverdue: false,
  );
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
