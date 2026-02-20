import 'package:intl/intl.dart';

final DateFormat _friendlyDateFormat = DateFormat('d MMM yyyy');

String formatFriendlyDate(DateTime date) {
  return _friendlyDateFormat.format(date.toLocal());
}
