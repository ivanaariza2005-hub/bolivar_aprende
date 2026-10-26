import 'package:intl/intl.dart';

class DateFormatter {
  const DateFormatter._();

  static String short(DateTime date) =>
      DateFormat('d MMM y', 'es_CO').format(date);

  static String long(DateTime date) =>
      DateFormat('d \'de\' MMMM \'de\' y', 'es_CO').format(date);
}
