import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:schedule/controller/schedule_controller.dart';
import 'package:schedule/models/class_avalability_model.dart';
import 'package:schedule/models/availability_model.dart';

class TimingsController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  RxBool isLoading = false.obs;
  RxList<ClassAvailabilityModel> classroomList = <ClassAvailabilityModel>[].obs;
  RxList<ClassAvailabilityModel> labList = <ClassAvailabilityModel>[].obs;

final ScheduleController _scheduleController = Get.put(ScheduleController(), permanent: true);

  Future<void> fetchTimings(DepartmentAvailabilityModel deptModel) async {
    isLoading.value = true;
    classroomList.clear();
    labList.clear();

    try {
      final classRef = _firestore
          .collection('slots')
          .doc(_scheduleController.selectedDay.value) // e.g. "monday"
          .collection('departments')
          .doc(deptModel.deprtmantName)
          .collection('Classrooms');

      final labRef = _firestore
          .collection('slot_test')
          .doc(_scheduleController.selectedDay.value)
          .collection('departments')
          .doc(deptModel.deprtmantName)
          .collection('Labs');

      // Fetch classrooms
      final classSnapshot = await classRef.get();
      for (var doc in classSnapshot.docs) {
        final slotsSnapshot = await classRef.doc(doc.id).collection('slots').get();
        for (var slot in slotsSnapshot.docs) {
          classroomList.add(ClassAvailabilityModel(
            id: doc.id,
            className: doc.id,
            isClassroom: true,
            timings: "${slot['start_time']}-${slot['end_time']}",
            appliedUsers: (slot['applications'] as List<dynamic>? ?? [])
                .map((e) => UsersAppliedModel.fromMap(e))
                .toList(),
          ));
        }
      }

      // Fetch labs
      final labSnapshot = await labRef.get();
      for (var doc in labSnapshot.docs) {
        final slotsSnapshot = await labRef.doc(doc.id).collection('slots').get();
        for (var slot in slotsSnapshot.docs) {
          labList.add(ClassAvailabilityModel(
            id: doc.id,
            className: doc.id,
            isClassroom: false,
            timings: "${slot['start_time']}-${slot['end_time']}",
            appliedUsers: (slot['applications'] as List<dynamic>? ?? [])
                .map((e) => UsersAppliedModel.fromMap(e))
                .toList(),
          ));
        }
      }
    } catch (e) {
      print("Error fetching timings: $e");
    } finally {
      isLoading.value = false;
    }
  }
}
