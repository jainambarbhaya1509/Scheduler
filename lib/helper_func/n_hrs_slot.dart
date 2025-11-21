import 'package:schedule/models/class_avalability_model.dart';
import 'package:schedule/models/class_timing_model.dart';

List<ClassAvailabilityModel> findConsecutiveSlots(
  List<ClassAvailabilityModel> classAvailabilityList,
  double requiredHours,
) {
  final requiredMinutes = (requiredHours * 60).round();
  final finalList = <ClassAvailabilityModel>[];

  for (var room in classAvailabilityList) {
    // Convert "HH:MM-HH:MM" to minutes map list
    final minutesList = room.timingsList.map((slot) {
      final parts = slot.timing.split('-'); // FIXED
      return {
        "start": toMinutes(parts[0]),
        "end": toMinutes(parts[1]),
        "applied": slot.appliedUsers,
      };
    }).toList();

    final blocks = _findConsecutiveBlocks(minutesList, requiredMinutes);

    finalList.add(
      ClassAvailabilityModel(
        id: room.id,
        className: room.className,
        isClassroom: room.isClassroom,
        timingsList: blocks,
      ),
    );
  }

  return finalList; // FIXED
}

/// Convert HH:MM to minutes
int toMinutes(String t) {
  final parts = t.split(':');
  return int.parse(parts[0]) * 60 + int.parse(parts[1]);
}

/// Core algorithm: find consecutive time blocks >= requiredMinutes
List<ClassTiming> _findConsecutiveBlocks(
  List<Map<String, dynamic>> minutesList,
  int requiredMinutes,
) {
  List<ClassTiming> result = [];
  if (minutesList.isEmpty) return result;

  int start = minutesList.first["start"];
  int end = minutesList.first["end"];
  List<UsersAppliedModel> applied = minutesList.first["applied"];

  for (int i = 1; i < minutesList.length; i++) {
    final curr = minutesList[i];
    final prev = minutesList[i - 1];

    if (curr["start"] == prev["end"]) {
      end = curr["end"];
    } else {
      result.addAll(splitBlock(start, end, requiredMinutes, applied));
      start = curr["start"];
      end = curr["end"];
      applied = curr["applied"];
    }
  }

  result.addAll(splitBlock(start, end, requiredMinutes, applied));

  return result;
}

List<ClassTiming> splitBlock(
  int start,
  int end,
  int requiredMinutes,
  List<UsersAppliedModel> appliedUsers,
) {
  List<ClassTiming> slots = [];

  while ((end - start) >= requiredMinutes) {
    final sTime = toTime(start);
    final eTime = toTime(start + requiredMinutes);

    slots.add(ClassTiming(timing: "$sTime-$eTime", appliedUsers: appliedUsers));

    start += 30; // sliding window
  }

  return slots;
}

/// Convert minutes back to HH:MM
String toTime(int m) {
  int h = (m ~/ 60) % 24;
  int min = m % 60;
  return "${h.toString().padLeft(2, '0')}:${min.toString().padLeft(2, '0')}";
}
