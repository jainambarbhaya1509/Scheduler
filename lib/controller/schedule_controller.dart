import 'package:get/get.dart';
import 'package:schedule/models/availability_model.dart';


class ScheduleController extends GetxController {
  List<DepartmentAvailabilityModel> departmentAvailabilityList = [
    DepartmentAvailabilityModel(
      id: "1",
      deprtmantName: "Computer Science",
      totalAvailableClass: "5",
      totalClass: "10",
      totalLabs: "3",
    ),
    DepartmentAvailabilityModel(
      id: "2",
      deprtmantName: "Information Technology",
      totalAvailableClass: "4",
      totalClass: "8",
      totalLabs: "2",
    ),
    DepartmentAvailabilityModel(
      id: "3",
      deprtmantName: "Electronics",
      totalAvailableClass: "6",
      totalClass: "12",
      totalLabs: "4",
    ),
    DepartmentAvailabilityModel(
      id: "4",
      deprtmantName: "Mechanical",
      totalAvailableClass: "3",
      totalClass: "7",
      totalLabs: "3",
    ),
    DepartmentAvailabilityModel(
      id: "5",
      deprtmantName: "Civil",
      totalAvailableClass: "2",
      totalClass: "6",
      totalLabs: "2",
    ),
  ].obs;
}
