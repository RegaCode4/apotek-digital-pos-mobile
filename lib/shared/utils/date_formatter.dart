import 'package:intl/intl.dart';

class DateFormatter {
  static String formatDateTime(DateTime? dateTime) {
    if (dateTime == null) return '-';
    return DateFormat('dd MMM yyyy, HH:mm', 'id_ID').format(dateTime);
  }

  static String formatDate(DateTime? dateTime) {
    if (dateTime == null) return '-';
    return DateFormat('dd MMM yyyy', 'id_ID').format(dateTime);
  }

  static String parseAndFormat(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return '-';
    try {
      final dt = DateTime.parse(dateStr);
      return formatDateTime(dt);
    } catch (_) {
      return dateStr;
    }
  }
}
