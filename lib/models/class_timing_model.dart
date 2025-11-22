import 'class_avalability_model.dart';

class ClassTiming {
  final String timing;
  final List<UsersAppliedModel> appliedUsers;
  List<String>? consideredSlots;

  ClassTiming({
    required this.timing,
    required this.appliedUsers,
    this.consideredSlots,
  });

  /// Slot is booked if at least 1 person applied
  bool get isBooked => appliedUsers.isNotEmpty;

  /// Return first applicant (only 1 allowed)
  UsersAppliedModel? get bookedBy =>
      appliedUsers.isNotEmpty ? appliedUsers.first : null;

  /// Not used in your fetching logic anymore,
  /// but kept if needed for mapping future data
  factory ClassTiming.fromMap(Map<String, dynamic> map) {
    List<UsersAppliedModel> parsed = [];

    // map["applications"] = { "17-11-2025": [ {application}, ... ] }
    if (map["applications"] is Map<String, dynamic>) {
      final appsMap = map["applications"] as Map<String, dynamic>;

      for (var list in appsMap.values) {
        if (list is List) {
          parsed.addAll(
            list.map(
              (e) => UsersAppliedModel.fromMap(e as Map<String, dynamic>),
            ),
          );
        }
      }
    }

    return ClassTiming(timing: map['timing'] ?? '', appliedUsers: parsed);
  }
}
