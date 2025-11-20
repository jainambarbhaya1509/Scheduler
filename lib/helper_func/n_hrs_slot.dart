Map<String, dynamic> findConsecutiveSlots(
  Map<String, dynamic> converted,
  double requiredHours,
) {
  final requiredMinutes = (requiredHours * 60).round();

  Map<String, dynamic> result = {
    "department": converted["department"],
    "class": converted["class"],
    "required_hours": requiredHours,
    "available": [],
  };

  for (var daySlot in converted["slots"]) {
    List<String> empty = daySlot["empty_slots"];

    // Convert "HH:MM-HH:MM" to minutes
    List<Map<String, int>> minutesList = empty.map((slot) {
      final parts = slot.split('-');
      return {"start": toMinutes(parts[0]), "end": toMinutes(parts[1])};
    }).toList();

    // Find consecutive blocks
    List<String> blocks = _findConsecutiveBlocks(minutesList, requiredMinutes);

    result["available"].add({"day": daySlot["day"], "slots": blocks});
  }

  return result;
}

/// Convert HH:MM to minutes
int toMinutes(String t) {
  final parts = t.split(':');
  return int.parse(parts[0]) * 60 + int.parse(parts[1]);
}

/// Core algorithm: find consecutive time blocks >= requiredMinutes
List<String> _findConsecutiveBlocks(
  List<Map<String, int>> minutesList,
  int requiredMinutes,
) {
  List<String> result = [];
  if (minutesList.isEmpty) return result;

  int start = minutesList.first["start"]!;
  int end = minutesList.first["end"]!;

  for (int i = 1; i < minutesList.length; i++) {
    final curr = minutesList[i];
    final prev = minutesList[i - 1];

    if (curr["start"] == prev["end"]) {
      end = curr["end"]!;
    } else {
      // Slide a window of requiredMinutes within this block
      result.addAll(splitBlock(start, end, requiredMinutes));
      start = curr["start"]!;
      end = curr["end"]!;
    }
  }

  result.addAll(splitBlock(start, end, requiredMinutes));

  return result;
}

List<String> splitBlock(int start, int end, int requiredMinutes) {
  List<String> slots = [];
  while ((end - start) >= requiredMinutes) {
    slots.add("${toTime(start)}-${toTime(start + requiredMinutes)}");
    start += 30; // move by 30 minutes for next overlapping block
  }
  return slots;
}


/// Convert minutes back to HH:MM
String toTime(int m) {
  int h = (m ~/ 60) % 24;
  int min = m % 60;
  return "${h.toString().padLeft(2, '0')}:${min.toString().padLeft(2, '0')}";
}
