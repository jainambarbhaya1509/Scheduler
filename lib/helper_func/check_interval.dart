DateTime _parseTime(String time) {
  final parts = time.split(":");
  if (parts.length != 2) {
    throw FormatException("Invalid time format: $time");
  }
  return DateTime(0, 1, 1, int.parse(parts[0]), int.parse(parts[1]));
}

bool isSlotAfter(String slot, String benchmark) {
  final start = slot.split("-").first.trim();
  final startTime = _parseTime(start);
  final benchmarkTime = _parseTime(benchmark);
  return startTime.isAfter(benchmarkTime);
}

List<String> getSlotsAfter(List<dynamic> slots, String benchmark) {
  List<String> result = [];

  for (var dayEntry in slots) {
    if (dayEntry is Map<String, dynamic>) {
      final empty = dayEntry["empty_slots"];
      if (empty is List) {
        for (var slot in empty) {
          if (slot is String && isSlotAfter(slot, benchmark)) {
            result.add(slot);
          }
        }
      }
    }
  }

  // ---------- DEBUG (SAFE VERSION) ----------
  print("Benchmark = $benchmark");

  for (var dayEntry in slots) {
    if (dayEntry is! Map<String, dynamic>) {
      print("Skipping non-map entry: $dayEntry");
      continue;                   // <-- THIS FIXES YOUR CRASH
    }

    print("Day: ${dayEntry['day']}");

    final empty = dayEntry["empty_slots"];
    print("Slots: $empty");

    if (empty is! List) continue;

    for (var slot in empty) {
      if (slot is! String) continue;

      final start = slot.split("-").first.trim();
      final check = isSlotAfter(slot, benchmark);
      print("   $slot → start:$start → after? $check");
    }
  }

  return result;
}
