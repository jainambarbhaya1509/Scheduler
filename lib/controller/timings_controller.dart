import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:schedule/controller/schedule_controller.dart';
import 'package:schedule/controller/user_controller.dart';
import 'package:schedule/models/class_avalability_model.dart';
import 'package:schedule/models/availability_model.dart';
import 'package:schedule/models/class_timing_model.dart';

class TimingsController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  RxBool isLoading = false.obs;
  RxList<ClassAvailabilityModel> classroomList = <ClassAvailabilityModel>[].obs;
  RxList<ClassAvailabilityModel> labList = <ClassAvailabilityModel>[].obs;

  final ScheduleController _scheduleController = Get.put(
    ScheduleController(),
    permanent: true,
  );

  Future<void> fetchTimings(DepartmentAvailabilityModel deptModel) async {
    isLoading.value = true;
    classroomList.clear();
    labList.clear();

    try {
      final classRef = _firestore
          .collection('slots')
          .doc(_scheduleController.selectedDay.value)
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
        List<ClassTiming> timingList = [];

        final slotsSnapshot = await classRef
            .doc(doc.id)
            .collection('slots')
            .get();
        for (var slot in slotsSnapshot.docs) {
          timingList.add(
            ClassTiming(
              timing: "${slot['start_time']}-${slot['end_time']}",
              appliedUsers: (slot['applications'] as List<dynamic>? ?? [])
                  .map((e) => UsersAppliedModel.fromMap(e))
                  .toList(),
            ),
          );
        }

        classroomList.add(
          ClassAvailabilityModel(
            id: doc.id,
            className: doc.id,
            isClassroom: true,
            timingsList: timingList,
          ),
        );
      }

      // Fetch labs
      final labSnapshot = await labRef.get();
      for (var doc in labSnapshot.docs) {
        List<ClassTiming> timingList = [];

        final slotsSnapshot = await labRef
            .doc(doc.id)
            .collection('slots')
            .get();
        for (var slot in slotsSnapshot.docs) {
          timingList.add(
            ClassTiming(
              timing: "${slot['start_time']}-${slot['end_time']}",
              appliedUsers: (slot['applications'] as List<dynamic>? ?? [])
                  .map((e) => UsersAppliedModel.fromMap(e))
                  .toList(),
            ),
          );
        }

        labList.add(
          ClassAvailabilityModel(
            id: doc.id,
            className: doc.id,
            isClassroom: false,
            timingsList: timingList,
          ),
        );
      }
    } catch (e) {
      print("Error fetching timings: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> apply({
    required ClassAvailabilityModel classModel,
    required String timeslot,
    required String reason,
  }) async {
    final db = FirebaseFirestore.instance;
    final day = _scheduleController.selectedDay.value;

    final String section = classModel.isClassroom ? "Classrooms" : "Labs";
    final UserController userController = Get.find<UserController>();

    print(
      "===================================================================================================",
    );

    final slotRef = db
        .collection("slots")
        .doc(day)
        .collection("departments")
        .doc(_scheduleController.selectedDept.value)
        .collection(section)
        .doc(classModel.className)
        .collection("slots")
        .doc(timeslot);

    try {
      // 1️⃣ Add central request
      final data = {
        "username": userController.username.toString(),
        "email": userController.email.toString(),

        "department": _scheduleController.selectedDept.value,
        "roomId": classModel.className,
        "reason": reason,
        "timeSlot": timeslot,
        "status": "Pending",
        "day": day,
      };

      await db
          .collection("requests")
          .doc(_scheduleController.selectedDept.value)
          .collection("requests_list")
          .add(data);

      // 2️⃣ Add inside slot applications
      final application = {
        "username": userController.username.toString(),
        "email": userController.email.toString(),
        "reason": reason,
        "status": "Pending",
      };

      await slotRef.set({
        "applications": FieldValue.arrayUnion([application]),
      }, SetOptions(merge: true));

      print("Application submitted!");
    } catch (e) {
      print("ERROR: $e");
    }
  }
}
