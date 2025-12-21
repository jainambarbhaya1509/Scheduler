class FacultyModel {
  final String email;
  final String username;
  final String department;
  final bool isHOD;
  final bool isAdmin;

  FacultyModel({
    required this.email,
    required this.username,
    required this.department,
    required this.isHOD,
    required this.isAdmin,
  });

  factory FacultyModel.fromJson(Map<String, dynamic> json) {
    return FacultyModel(
      email: json['email'] as String,
      username: json['username'] as String,
      department: json['department'] as String,
      isHOD: json['isHOD'] as bool,
      isAdmin: json['isAdmin'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'username': username,
      'department': department,
      'isHOD': isHOD,
      'isAdmin': isAdmin,
    };
  }
}
