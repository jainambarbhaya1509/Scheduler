import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:schedule/helper_func/check_interval.dart';
import 'package:schedule/helper_func/n_hrs_slot.dart';
import 'package:schedule/helper_func/send_mail.dart';
import 'package:schedule/models/class_avalability_model.dart';
import 'package:schedule/models/availability_model.dart';
import 'package:schedule/models/class_timing_model.dart';
import 'package:schedule/controller/schedule_controller.dart';
import 'package:schedule/controller/session_controller.dart';
import 'package:schedule/utils/firestore_helpers.dart';
import 'package:schedule/services/firestore_service.dart';

class TimingsController extends GetxController {
  final _firestore = FirestoreService().instance;

  final isLoading = false.obs;
  final classroomList = <ClassAvailabilityModel>[].obs;
  final labList = <ClassAvailabilityModel>[].obs;
  final hoursRequired = 0.0.obs;
  final initialTiming = "".obs;

  final _scheduleController = Get.put(ScheduleController(), permanent: true);
  final _sessionController = Get.put(SessionController());

  /// Fetch timings for classrooms and labs
  Future<void> fetchTimings(
    DepartmentAvailabilityModel deptModel, {
    double? reqHrs,
    String? initialTime,
  }) async {
    isLoading.value = true;
    classroomList.clear();
    labList.clear();

    try {
      final day = _scheduleController.selectedDay.value;
      final deptName = deptModel.departmentName!;

      final results = await Future.wait([
        _fetchSection(day, deptName, "Classrooms", true),
        _fetchSection(day, deptName, "Labs", false),
      ]);

      classroomList.addAll(results[0]);
      labList.addAll(results[1]);
    } catch (e) {
      log("Error fetching timings: $e");
    } finally {
      isLoading.value = false;
    }
  }

  /// Refactored section fetching with optimized filtering
  Future<List<ClassAvailabilityModel>> _fetchSection(
    String day,
    String deptName,
    String section,
    bool isClassroom,
  ) async {
    final allSlots = <ClassAvailabilityModel>[];
    final date = _scheduleController.selectedDate.value;

    try {
      final snapshot = await _firestore
          .collection('slots')
          .doc(day)
          .collection('departments')
          .doc(deptName)
          .collection(section)
          .get();

      for (var doc in snapshot.docs) {
        if (doc.id == "_meta") continue;

        final slotsSnapshot = await doc.reference.collection('slots').get();

        final timingList = slotsSnapshot.docs.map((slot) {
          final appliedUsers = FirestoreHelpers.filterApplicationsByStatus(
            slot['applications'] as Map<String, dynamic>?,
            date,
            'rejected',
            exclude: true,
          ).map((e) => UsersAppliedModel.fromMap(e)).toList();

          return ClassTiming(
            timing: "${slot['start_time'] ?? ''}-${slot['end_time'] ?? ''}",
            appliedUsers: appliedUsers,
          );
        }).toList();

        allSlots.add(
          ClassAvailabilityModel(
            id: doc.id,
            className: doc.id,
            isClassroom: isClassroom,
            timingsList: timingList,
          ),
        );
      }

      // Apply filters if set
      var finalList = allSlots;
      if (initialTiming.value.isNotEmpty) {
        finalList = filterSlotsAfter(allSlots, initialTiming.value);
      }
      if (hoursRequired.value != 0.0) {
        finalList = findConsecutiveSlots(finalList, hoursRequired.value);
      }

      return finalList;
    } catch (e) {
      log("Error fetching $section: $e");
      return [];
    }
  }

  /// Apply booking request
  Future<void> apply({
    required ClassAvailabilityModel classModel,
    required String timeslot,
    required String reason,
    List<String>? consideredSlots,
  }) async {
    try {
      final day = _scheduleController.selectedDay.value;
      final dept = _scheduleController.selectedDept.value;
      final section = classModel.isClassroom ? "Classrooms" : "Labs";
      final date = _scheduleController.selectedDate.value;

      final batch = _firestore.batch();
      final bookingId = _firestore.collection("requests").doc().id;

      final session = await _sessionController.getSession();
      final userName = session["username"];
      final userEmail = session["email"];

      // Store request
      final requestRef = _firestore
          .collection("requests")
          .doc(dept)
          .collection("requests_list")
          .doc(bookingId);

      final requestData = {
        "bookingId": bookingId,
        "username": userName,
        "email": userEmail,
        "department": dept,
        "roomId": classModel.className,
        "reason": reason,
        "timeSlot": timeslot,
        "consideredSlots": consideredSlots ?? [],
        "status": "Pending",
        "day": day,
        "requestedDate": date,
        "createdAt": Timestamp.now(),
      };
      batch.set(requestRef, requestData);

      // Create application object
      final application = {
        "bookingId": bookingId,
        "username": userName,
        "email": userEmail,
        "reason": reason,
        "requestedDate": date,
        "createdAt": Timestamp.now(),
        "status": "Pending",
      };

      // Update slots with application
      final slotsToUpdate = consideredSlots?.isNotEmpty ?? false
          ? consideredSlots!
          : [timeslot];

      for (final slot in slotsToUpdate) {
        final slotRef = _firestore
            .collection("slots")
            .doc(day)
            .collection("departments")
            .doc(dept)
            .collection(section)
            .doc(classModel.className)
            .collection("slots")
            .doc(slot);

        batch.update(slotRef, {
          "applications.$date": FieldValue.arrayUnion([application]),
        });
      }

      await batch.commit();

      // email notification logic to be implemented here for HOD
      final hodSnapshot = await _firestore
          .collection('faculty')
          .where('department', isEqualTo: dept)
          .where('isHOD', isEqualTo: true)
          .get();

      for (final doc in hodSnapshot.docs) {
        final hodEmail = doc['email'];
        final subject = "New Booking Request from $userName";
        final emailMessage = "Dear HOD,\n\n$userName has submitted a booking request for ${classModel.className} on $date. \nTime Slot: $timeslot \n\nReason: $reason\n\nBest regards,\nScheduling System";

        sendEmailNotification(facultyEmail: hodEmail, userName: userName, userEmail: userEmail, subject: subject, emailMessage: emailMessage);
      }

      Get.snackbar("Success", "Application submitted and faculty notified");
    } catch (e) {
      Get.snackbar("Error", "Failed to submit: $e");
    }
  }
}
