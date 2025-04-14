class DepartmentAvailabilityModel {
  String? deprtmantName;
  String? totalAvailableClass;
  String? totalClass;
  String? totalLabs;

  DepartmentAvailabilityModel({
    this.deprtmantName,
    this.totalAvailableClass,
    this.totalClass,
    this.totalLabs,
  });
  DepartmentAvailabilityModel.fromJson(Map<String, dynamic> json) {
    deprtmantName = json['deprtmant_name'];
    totalAvailableClass = json['total_available_class'];
    totalClass = json['total_class'];
    totalLabs = json['total_labs'];
  }
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['deprtmant_name'] = deprtmantName;
    data['total_available_class'] = totalAvailableClass;
    data['total_class'] = totalClass;
    data['total_labs'] = totalLabs;
    return data;
  }
}
