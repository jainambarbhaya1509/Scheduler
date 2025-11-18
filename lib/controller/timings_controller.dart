import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart' show DateFormat;
import 'package:schedule/controller/schedule_controller.dart';
import 'package:schedule/controller/user_controller.dart';
import 'package:schedule/models/class_avalability_model.dart';
import 'package:schedule/models/availability_model.dart';
import 'package:schedule/models/class_timing_model.dart';

class TimingsController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final isLoading = false.obs;
  final classroomList = <ClassAvailabilityModel>[].obs;
  final labList = <ClassAvailabilityModel>[].obs;
  final date = "".obs;

  final ScheduleController _scheduleController = Get.put(
    ScheduleController(),
    permanent: true,
  );
  late final UserController _userController = Get.find<UserController>();

  /// Optimized to fetch both classrooms and labs in parallel
  Future<void> fetchTimings(DepartmentAvailabilityModel deptModel) async {
    isLoading.value = true;
    classroomList.clear();
    labList.clear();

    try {
      final day = _scheduleController.selectedDay.value;
      final deptName = deptModel.deprtmantName!;

      final results = await Future.wait([
        _fetchSection(day, deptName, "Classrooms", true),
        _fetchSection(day, deptName, "Labs", false),
      ]);

      classroomList.addAll(results[0]);
      labList.addAll(results[1]);
    } catch (e) {
      print("Error fetching timings: $e");
    } finally {
      isLoading.value = false;
    }
  }

  /// Helper method to reduce code duplication
  Future<List<ClassAvailabilityModel>> _fetchSection(
    String day,
    String deptName,
    String section,
    bool isClassroom,
  ) async {
    final list = <ClassAvailabilityModel>[];
    final dt = DateTime.parse(date.value);
    final formatted = DateFormat("dd-MM-yyyy").format(dt);
    try {
      final snapshot = await _firestore
          .collection('slots')
          .doc(day)
          .collection('departments')
          .doc(deptName)
          .collection(section)
          .get();

      for (var doc in snapshot.docs) {
        if (doc.id == "_meta") continue; // Skip metadata

        final slotsSnapshot = await doc.reference.collection('slots').get();

        final timingList = slotsSnapshot.docs.map((slot) {
          final rawApplications = slot['applications'];

          List<UsersAppliedModel> appliedUsers = [];

          // Filter only selected date
          if (rawApplications is Map<String, dynamic>) {
            if (rawApplications.containsKey(formatted)) {
              final appList = rawApplications[formatted];

              if (appList is List) {
                appliedUsers = appList
                    .map(
                      (e) =>
                          UsersAppliedModel.fromMap(e as Map<String, dynamic>),
                    )
                    .toList();
              }
            }
          }

          return ClassTiming(
            timing: "${slot['start_time'] ?? ''}-${slot['end_time'] ?? ''}",
            appliedUsers: appliedUsers,
          );
        }).toList();

        list.add(
          ClassAvailabilityModel(
            id: doc.id,
            className: doc.id,
            isClassroom: isClassroom,
            timingsList: timingList,
          ),
        );
      }
    } catch (e) {
      print("Error fetching $section: $e");
    }

    return list;
  }

  /// Optimized apply with better error handling
  Future<void> apply({
    required ClassAvailabilityModel classModel,
    required String timeslot,
    required String reason,
  }) async {
    try {
      final day = _scheduleController.selectedDay.value;
      final dept = _scheduleController.selectedDept.value;
      final section = classModel.isClassroom ? "Classrooms" : "Labs";

      final batch = _firestore.batch();

      // Add to requests
      // Generate bookingId
      final bookingId = _firestore.collection("requests").doc().id;

      final dt = DateTime.parse(date.value);
      final formatted = DateFormat("dd-MM-yyyy").format(dt);

      // Add to requests
      final requestRef = _firestore
          .collection("requests")
          .doc(dept)
          .collection("requests_list")
          .doc(bookingId);

      final requestData = {
        "bookingId": bookingId,
        "username": _userController.username.value,
        "email": _userController.email.value,
        "department": dept,
        "roomId": classModel.className,
        "reason": reason,
        "timeSlot": timeslot,
        "status": "Pending",
        "day": day,
        "requestedDate": formatted,
        "createdAt": Timestamp.now(),
      };

      batch.set(requestRef, requestData);

      final application = {
        "bookingId": bookingId,
        "username": _userController.username.value,
        "email": _userController.email.value,
        "reason": reason,
        "requestedDate": formatted,
        "createdAt": Timestamp.now(),
        "status": "Pending",
      };

      final slotRef = _firestore
          .collection("slots")
          .doc(day)
          .collection("departments")
          .doc(dept)
          .collection(section)
          .doc(classModel.className)
          .collection("slots")
          .doc(timeslot);

      batch.update(slotRef, {
        "applications.$formatted": FieldValue.arrayUnion([application]),
      });

      await batch.commit();

      Get.snackbar("Success", "Application submitted");
    } catch (e) {
      Get.snackbar("Error", "Failed to submit: $e");
      print("ERROR: $e");
    }
  }
}
