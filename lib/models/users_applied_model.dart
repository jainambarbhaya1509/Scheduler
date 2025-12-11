class UsersAppliedModel {
  final String name;
  final String status;
  final String description;

  UsersAppliedModel({
    required this.name,
    required this.status,
    required this.description,
  });

  factory UsersAppliedModel.fromMap(Map<String, dynamic> map) {
    return UsersAppliedModel(
      name: map['username'] ?? '',
      status: map['status'] ?? 'Pending',
      description: map['reason'] ?? '',
    );
  }

  Map<String, dynamic> toMap() => {
    'username': name,
    'status': status,
    'reason': description,
  };
}
