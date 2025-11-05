class ClassAvalabilityModel {
  dynamic id;
  bool isClassroom;
  String className;
  String timings;
  List<UsersAppliedModel> appliedUsers;

  ClassAvalabilityModel({
    required this.id,
    required this.isClassroom,
    required this.className,
    required this.timings,
    required this.appliedUsers,

  });
  ClassAvalabilityModel.fromJson(Map<String, dynamic> json)
      :  id = json['id'],
      isClassroom = json['isClassroom'] == 1,
        className = json['class_name'],
        timings = json['timings'],
        appliedUsers = json['applied_users'];
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['is_classroom'] = isClassroom ? 1 : 0;
    data['class_name'] = className;
    data['timings'] = timings;
    data['applied_users'] = appliedUsers;
    return data;
  }
}
class UsersAppliedModel {
  dynamic userId;
  String name;
  String status;
  String description;

  UsersAppliedModel({
    required this.userId,
    required this.name,
    required this.status,
    required this.description,
  });
  UsersAppliedModel.fromJson(Map<String, dynamic> json)
      : userId = json['user_id'],
        name = json['name'],
        status = json['status'],
        description = json['description'];

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['user_id'] = userId;
    data['name'] = name;
    data['status'] = status;
    data['description'] = description;
    return data;
  }
}