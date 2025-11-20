import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:schedule/models/availability_model.dart';

class ScheduleController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final departmentAvailabilityList = <DepartmentAvailabilityModel>[].obs;
  final selectedDay = "".obs;
  final selectedDept = "".obs;
  final selectedDate = "".obs;
  final isLoading = false.obs;

  StreamSubscription? _availabilitySubscription;

  final List<String> _sections = ["Classrooms", "Labs"];

  /// Fetch availability for a given day
  Future<void> fetchAvailabilityForDay(String day) async {
    selectedDay.value = day;
    print(selectedDate.value);
    isLoading.value = true;
    try {
      departmentAvailabilityList.clear();

      final deptSnapshot = await _firestore
          .collection("slots")
          .doc(day)
          .collection("departments")
          .get();

      if (deptSnapshot.docs.isEmpty) return;

      final futures = deptSnapshot.docs.map(
        (deptDoc) => _fetchDeptAvailability(day, deptDoc.id),
      );
      final results = await Future.wait(futures);

      departmentAvailabilityList.addAll(
        results.whereType<DepartmentAvailabilityModel>(),
      );
    } catch (e) {
      print("Error fetching availability: $e");
    } finally {
      isLoading.value = false;
    }
  }

  /// Fetch availability counts for a single department
  Future<DepartmentAvailabilityModel?> _fetchDeptAvailability(
    String day,
    String departmentId,
  ) async {
    try {
      final results = await Future.wait(
        _sections.map(
          (section) => _firestore
              .collection("slots")
              .doc(day)
              .collection("departments")
              .doc(departmentId)
              .collection(section)
              .get(),
        ),
      );

      final classroomCount = results[0].docs
          .where((d) => d.id != "_meta")
          .length;
      final labCount = results[1].docs.where((d) => d.id != "_meta").length;

      return DepartmentAvailabilityModel(
        id: departmentId,
        departmentName: departmentId,
        totalAvailableClass: classroomCount.toString(),
        totalLabs: labCount.toString(),
        totalClass: classroomCount.toString(),
      );
    } catch (e) {
      print("Error fetching department $departmentId: $e");
      return null;
    }
  }

  /// Fetch available rooms for a specific department
  Future<Map<String, List<Map<String, dynamic>>>> fetchAvailableRooms(
    String department,
  ) async {
    selectedDept.value = department;

    return await _fetchRooms(selectedDay.value, [department]);
  }

  /// Fetch all available slots across all departments
  Future<Map<String, List<Map<String, dynamic>>>> fetchAllAvailableSlots(
    String day,
  ) async {
    final deptsSnapshot = await _firestore
        .collection("slots")
        .doc(day)
        .collection("departments")
        .get();

    final departments = deptsSnapshot.docs.map((d) => d.id).toList();

    return await _fetchRooms(day, departments);
  }

  /// Generic function to fetch rooms and slots for given departments
  Future<Map<String, List<Map<String, dynamic>>>> _fetchRooms(
    String day,
    List<String> departments,
  ) async {
    final availableData = {
      "Classrooms": <Map<String, dynamic>>[],
      "Labs": <Map<String, dynamic>>[],
    };

    final date = selectedDate.value;

    for (final dept in departments) {
      for (final section in _sections) {
        final roomsSnapshot = await _firestore
            .collection("slots")
            .doc(day)
            .collection("departments")
            .doc(dept)
            .collection(section)
            .get();

        final roomDocs = roomsSnapshot.docs.where((d) => d.id != "_meta");

        for (final roomDoc in roomDocs) {
          final slotSnapshot = await roomDoc.reference
              .collection("slots")
              .get();

          for (final slotDoc in slotSnapshot.docs) {
            final data = slotDoc.data();

            // Skip if there is at least 1 application for the selected date
            if (data["applications"] != null &&
                data["applications"][date] != null &&
                (data["applications"][date] as List).isNotEmpty) {
              continue;
            }

            availableData[section]!.add({
              "day": day,
              "department": dept,
              "section": section,
              "className": roomDoc.id,
              "slotTime": slotDoc.id,
              ...data,
              "applications": {}, // empty because no applications
            });
          }
        }
      }
    }
    print("=================");
    print(availableData);
    return availableData;
  }

  @override
  void onClose() {
    _availabilitySubscription?.cancel();
    super.onClose();
  }
}
