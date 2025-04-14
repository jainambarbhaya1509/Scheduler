class ClassAvalabilityModel {
  bool isClassroom;
  String className;
  String startTime;
  String endTime;

  ClassAvalabilityModel({
    required this.isClassroom,
    required this.className,
    required this.startTime,
    required this.endTime,
  });
  ClassAvalabilityModel.fromJson(Map<String, dynamic> json)
      : isClassroom = json['is_classroom'] == 1,
        className = json['class_name'],
        startTime = json['start_time'],
        endTime = json['end_time'];
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['is_classroom'] = isClassroom ? 1 : 0;
    data['class_name'] = className;
    data['start_time'] = startTime;
    data['end_time'] = endTime;

    return data;
  }
}
