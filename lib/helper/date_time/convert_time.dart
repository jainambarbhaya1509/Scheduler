Map<String, dynamic> convertScheduleTo24(Map<String, dynamic> data) {
  List<dynamic> slots = data["slots"];

  List<Map<String, dynamic>> updatedSlots = slots.map((slot) {
    List<dynamic> emptySlots = slot["empty_slots"];

    List<String> convertedSlots = emptySlots.map((s) => convertTo24(s)).toList()
      ..sort();

    return {"day": slot["day"], "empty_slots": convertedSlots};
  }).toList();

  return {
    "department": data["department"],
    "class": data["class"],
    "slots": updatedSlots,
  };
}

/// Convert "01:30-02:00" -> "13:30-14:00"
String convertTo24(String time) {
  List<String> parts = time.split('-');

  String start = fixTime(parts[0]);
  String end = fixTime(parts[1]);

  return "$start-$end";
}

String fixTime(String t) {
  int hour = int.parse(t.split(':')[0]);
  String minute = t.split(':')[1];

  if (hour >= 1 && hour <= 7) {
    hour += 12; // Convert PM guessed hours
  }

  return "${hour.toString().padLeft(2, '0')}:$minute";
}
