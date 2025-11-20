import 'package:intl/intl.dart';

String formatDate(String date) {
  final dt = DateTime.parse(date);
  final formatted = DateFormat("dd-MM-yyyy").format(dt);

  return formatted;
}
