import 'dart:async';
import 'package:get/get.dart';
import 'package:schedule/models/availability_model.dart';
import 'package:schedule/services/firestore_service.dart';
import 'package:schedule/utils/slot_helpers.dart';

class ScheduleController extends GetxController {
  final _firestore = FirestoreService().instance;

  final departmentAvailabilityList = <DepartmentAvailabilityModel>[].obs;
  final selectedDay = "".obs;
  final selectedDept = "".obs;
  final selectedDate = "".obs;
  final isLoading = false.obs;

  StreamSubscription? _availabilitySubscription;

  static const List<String> _sections = ["Classrooms", "Labs"];

  /// Fetch availability for a given day
  Future<void> fetchAvailabilityForDay(String day) async {
    selectedDay.value = day;
    isLoading.value = true;
    try {
      departmentAvailabilityList.clear();

      final deptSnapshot = await _firestore
          .collection("slots")
          .doc(day)
          .collection("departments")
          .get();

      if (deptSnapshot.docs.isEmpty) return;

      final results = await Future.wait(
        deptSnapshot.docs.map((doc) => _fetchDeptAvailability(day, doc.id)),
      );

      departmentAvailabilityList.addAll(
        results.whereType<DepartmentAvailabilityModel>(),
      );
    } catch (e) {
      print("Error fetching availability: $e");
    } finally {
      isLoading.value = false;
    }
  }

  /// Fetch availability for single department
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

      final classroomCount =
          results[0].docs.where((d) => d.id != "_meta").length;
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

  /// Fetch available rooms for specific department
  Future<Map<String, List<Map<String, dynamic>>>> fetchAvailableRooms(
    String department,
  ) async {
    selectedDept.value = department;
    return _fetchRooms(selectedDay.value, [department]);
  }

  /// Optimized room/slot fetching with batch processing
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

        for (final roomDoc
            in roomsSnapshot.docs.where((d) => d.id != "_meta")) {
          final slotSnapshot = await roomDoc.reference.collection("slots").get();

          for (final slotDoc in slotSnapshot.docs) {
            final data = slotDoc.data();

            if (SlotHelpers.isSlotAvailable(data, date)) {
              availableData[section]!.add({
                "day": day,
                "department": dept,
                "section": section,
                "className": roomDoc.id,
                "slotTime": slotDoc.id,
                ...data,
                "applications": {},
              });
            }
          }
        }
      }
    }

    return availableData;
  }

  @override
  void onClose() {
    _availabilitySubscription?.cancel();
    super.onClose();
  }
}
