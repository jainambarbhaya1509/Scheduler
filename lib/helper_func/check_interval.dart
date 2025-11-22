import 'package:schedule/models/class_avalability_model.dart';

/// Filters timings in each room after [initialTime] and returns a new list
List<ClassAvailabilityModel> filterSlotsAfter(
    List<ClassAvailabilityModel> rooms, String initialTime) {
  final initialParts = initialTime.split(":").map(int.parse).toList();
  final initialMinutes = initialParts[0] * 60 + initialParts[1];

  // Filter timings in each room
  return rooms.map((room) {
    final filteredTimings = room.timingsList.where((slot) {
      final startParts = slot.timing.split("-")[0].split(":").map(int.parse).toList();
      final startMinutes = startParts[0] * 60 + startParts[1];
      return startMinutes > initialMinutes;
    }).toList();

    return ClassAvailabilityModel(
      id: room.id,
      className: room.className,
      isClassroom: room.isClassroom,
      timingsList: filteredTimings,
    );
  }).toList();
}
