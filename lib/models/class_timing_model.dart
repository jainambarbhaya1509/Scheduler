import 'class_avalability_model.dart';

class ClassTiming {
  final String timing;
  final List<UsersAppliedModel> appliedUsers;

  ClassTiming({
    required this.timing,
    required this.appliedUsers,
  });

  factory ClassTiming.fromMap(Map<String, dynamic> map) {
    final apps = map['applications'];

    List<UsersAppliedModel> parsedApplicants = [];

    // Firestore returns { userId: {username, reason, status} }
    if (apps != null && apps is Map) {
      parsedApplicants = apps.values
          .map((e) => UsersAppliedModel.fromMap(e as Map<String, dynamic>))
          .toList();
    }

    return ClassTiming(
      timing: map['timing'] ?? '',
      appliedUsers: parsedApplicants,
    );
  }
}
