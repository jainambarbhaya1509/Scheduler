import 'package:intl/intl.dart';

String formatDate(String date) {
  if (date.isEmpty) {
    throw FormatException("Date is empty");
  }

  try {
    // Try parsing yyyy-MM-dd or any other format you expect
    final parsedDate = DateTime.parse(date); 
    return DateFormat('dd-MM-yyyy').format(parsedDate);
  } catch (_) {
    // If parsing fails, try another common format (like dd/MM/yyyy)
    try {
      final parts = date.split('/');
      if (parts.length == 3) {
        final parsedDate = DateTime(
          int.parse(parts[2]), 
          int.parse(parts[1]), 
          int.parse(parts[0])
        );
        return DateFormat('dd-MM-yyyy').format(parsedDate);
      }
    } catch (e) {
      throw FormatException("Invalid date format: $date");
    }
  }

  throw FormatException("Invalid date format: $date");
}
