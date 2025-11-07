class ClassAvailabilityModel {
  final String id; // Firestore doc ID or unique identifier
  final bool isClassroom;
  final String className;
  final String timings; // e.g. "01:00-01:30"
  final List<UsersAppliedModel> appliedUsers;

  ClassAvailabilityModel({
    required this.id,
    required this.isClassroom,
    required this.className,
    required this.timings,
    required this.appliedUsers,
  });

  /// Create object from Firestore document data
  factory ClassAvailabilityModel.fromMap(Map<String, dynamic> map, String docId) {
    return ClassAvailabilityModel(
      id: docId,
      isClassroom: map['is_classroom'] == true || map['is_classroom'] == 1,
      className: map['class_name'] ?? '',
      timings: map['timings'] ?? '',
      appliedUsers: (map['applications'] as List<dynamic>? ?? [])
          .map((e) => UsersAppliedModel.fromMap(e as Map<String, dynamic>))
          .toList(),
    );
  }

  /// Convert object to JSON for saving to Firestore
  Map<String, dynamic> toMap() {
    return {
      'is_classroom': isClassroom,
      'class_name': className,
      'timings': timings,
      'applications': appliedUsers.map((user) => user.toMap()).toList(),
    };
  }
}


class UsersAppliedModel {
  final int userId;
  final String name;
  final String status;
  final String description;

  UsersAppliedModel({
    required this.userId,
    required this.name,
    required this.status,
    required this.description,
  });

  factory UsersAppliedModel.fromMap(Map<String, dynamic> map) {
    return UsersAppliedModel(
      userId: map['userId'] ?? 0,
      name: map['user'] ?? '',
      status: map['status'] ?? 'Pending',
      description: map['reason'] ?? '',
    );
  }

  Map<String, dynamic> toMap() => {
        'userId': userId,
        'user': name,
        'status': status,
        'reason': description,
      };
}
