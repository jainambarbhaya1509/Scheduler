import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:schedule/models/availability_model.dart';

class ScheduleController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final departmentAvailabilityList = <DepartmentAvailabilityModel>[].obs;
  final selectedDay = "".obs;
  final selectedDept = "".obs;
  final isLoading = false.obs;

  StreamSubscription? _availabilitySubscription;

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

      if (deptSnapshot.docs.isEmpty) {
        isLoading.value = false;
        return;
      }

      final futures = deptSnapshot.docs.map((deptDoc) async {
        final departmentId = deptDoc.id;

        try {
          final results = await Future.wait([
            _firestore
                .collection("slots")
                .doc(day)
                .collection("departments")
                .doc(departmentId)
                .collection("Classrooms")
                .get(),
            _firestore
                .collection("slots")
                .doc(day)
                .collection("departments")
                .doc(departmentId)
                .collection("Labs")
                .get(),
          ]);

          final classroomCount =
              results[0].docs.where((d) => d.id != "_meta").length;
          final labCount =
              results[1].docs.where((d) => d.id != "_meta").length;

          return DepartmentAvailabilityModel(
            id: departmentId,
            deprtmantName: departmentId,
            totalAvailableClass: classroomCount.toString(),
            totalLabs: labCount.toString(),
            totalClass: (classroomCount).toString(),
          );
        } catch (e) {
          print("Error fetching department $departmentId: $e");
          return null;
        }
      }).toList();

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

  /// Fetch available rooms
  Future<Map<String, List<Map<String, dynamic>>>> fetchAvailableRooms(
      String department) async {
    try {
      selectedDept.value = department;

      final availableData = {
        "Classrooms": <Map<String, dynamic>>[],
        "Labs": <Map<String, dynamic>>[],
      };

      final sections = ["Classrooms", "Labs"];

      for (final section in sections) {
        final roomsSnapshot = await _firestore
            .collection("slots")
            .doc(selectedDay.value)
            .collection("departments")
            .doc(department)
            .collection(section)
            .get();

        final roomDocs =
            roomsSnapshot.docs.where((d) => d.id != "_meta").toList();

        for (final roomDoc in roomDocs) {
          final slotSnapshot =
              await roomDoc.reference.collection("slots").get();

          for (final slotDoc in slotSnapshot.docs) {
            final data = slotDoc.data();
            if (data['status'] == 'available' && data['isEmpty'] == true) {
              availableData[section]!.add({
                "day": selectedDay.value,
                "department": department,
                "section": section,
                "className": roomDoc.id,
                "slotTime": slotDoc.id,
                ...data,
              });
            }
          }
        }
      }

      return availableData;
    } catch (e) {
      print("Error fetching available rooms: $e");
      return {};
    }
  }

  @override
  void onClose() {
    _availabilitySubscription?.cancel();
    super.onClose();
  }
}
