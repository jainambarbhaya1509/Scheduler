class DepartmentAvailabilityModel {
  String? id;
  String? departmentName;
  String? totalAvailableClass;
  String? totalClass;
  String? totalLabs;

  DepartmentAvailabilityModel({
    required this.id,
    this.departmentName,
    this.totalAvailableClass,
    this.totalClass,
    this.totalLabs,
  });

  DepartmentAvailabilityModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    departmentName = json['departmant_name'];
    totalAvailableClass = json['total_available_class'];
    totalClass = json['total_class'];
    totalLabs = json['total_labs'];
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['id'] = id;
    data['departmant_name'] = departmentName;
    data['total_available_class'] = totalAvailableClass;
    data['total_class'] = totalClass;
    data['total_labs'] = totalLabs;
    return data;
  }
}
