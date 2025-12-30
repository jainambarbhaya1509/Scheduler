bool isToday(String selectedDate) {
  final now = DateTime.now();

  DateTime parsed;

  try {
    // CASE 1: yyyy-MM-dd
    if (selectedDate.contains('-') &&
        selectedDate.split('-')[0].length == 4) {
      parsed = DateTime.parse(selectedDate);
    }
    // CASE 2: dd-MM-yyyy or dd/MM/yyyy
    else {
      final clean = selectedDate.replaceAll('/', '-');
      final parts = clean.split('-');
      parsed = DateTime(
        int.parse(parts[2]),
        int.parse(parts[1]),
        int.parse(parts[0]),
      );
    }
  } catch (_) {
    return false;
  }

  return parsed.year == now.year &&
      parsed.month == now.month &&
      parsed.day == now.day;
}
