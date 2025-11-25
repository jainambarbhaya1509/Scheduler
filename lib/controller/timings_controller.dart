import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:schedule/controller/schedule_controller.dart';
import 'package:schedule/controller/session_controller.dart';
import 'package:schedule/helper_func/check_interval.dart';
import 'package:schedule/helper_func/n_hrs_slot.dart';
import 'package:schedule/models/class_avalability_model.dart';
import 'package:schedule/models/availability_model.dart';
import 'package:schedule/models/class_timing_model.dart';

class TimingsController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final isLoading = false.obs;
  final classroomList = <ClassAvailabilityModel>[].obs;
  final labList = <ClassAvailabilityModel>[].obs;
  final hoursRequired = 0.0.obs;
  final initialTiming = "".obs;

  final ScheduleController _scheduleController = Get.put(
    ScheduleController(),
    permanent: true,
  );

  final SessionController _sessionController = Get.put(SessionController());

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
      print("Error fetching timings: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<List<ClassAvailabilityModel>> _fetchSection(
    String day,
    String deptName,
    String section,
    bool isClassroom,
  ) async {
    final allSlots = <ClassAvailabilityModel>[];
    List<ClassAvailabilityModel> finalList = [];

    final date = _scheduleController.selectedDate.value;

    try {
      final snapshot = await _firestore
          .collection('slots')
          .doc(day)
          .collection('departments')
          .doc(deptName)
          .collection(section)
          .get();

      // -----------------------------
      //  STEP 1: COLLECT ALL ROOMS
      // -----------------------------
      for (var doc in snapshot.docs) {
        if (doc.id == "_meta") continue;

        final slotsSnapshot = await doc.reference.collection('slots').get();

        final timingList = slotsSnapshot.docs.map((slot) {
          final rawApplications = slot['applications'];
          List<UsersAppliedModel> appliedUsers = [];

          if (rawApplications is Map<String, dynamic> &&
              rawApplications.containsKey(date)) {
            final appList = rawApplications[date];
            if (appList is List) {
              appliedUsers = appList
                  .map(
                    (e) => UsersAppliedModel.fromMap(e as Map<String, dynamic>),
                  )
                  .where((u) => u.status.toLowerCase() != "rejected")
                  .toList();
            }
          }

          return ClassTiming(
            timing: "${slot['start_time'] ?? ''}-${slot['end_time'] ?? ''}",
            appliedUsers: appliedUsers,
          );
        }).toList();

        // Build model
        allSlots.add(
          ClassAvailabilityModel(
            id: doc.id,
            className: doc.id,
            isClassroom: isClassroom,
            timingsList: timingList,
          ),
        );
      }

      // ---------------------------------------
      //  STEP 2: APPLY FILTERS **ONCE**
      // ---------------------------------------

      final hasInitialTiming = initialTiming.value.isNotEmpty;
      final hasHoursRequired = hoursRequired.value != 0.0;

      // Case A: No filters → return all slots
      if (!hasInitialTiming && !hasHoursRequired) {
        return allSlots;
      }

      // Case B: Start with initial timing filter if needed
      List<ClassAvailabilityModel> filteredList = allSlots;

      if (hasInitialTiming) {
        filteredList = filterSlotsAfter(allSlots, initialTiming.value);
      }

      // Case C: Apply consecutive hours requirement
      if (hasHoursRequired) {
        finalList = findConsecutiveSlots(filteredList, hoursRequired.value);
      } else {
        // Only initial timing filter applied
        finalList = filteredList;
      }
    } catch (e) {
      print("❌ Error fetching $section: $e");
    }

    return finalList;
  }

  Future<void> apply({
    required ClassAvailabilityModel classModel,
    required String timeslot, // might not exist in DB (merged slot)
    required String reason,
    List<String>? consideredSlots, // actual existing slots
  }) async {
    try {
      final day = _scheduleController.selectedDay.value;
      final dept = _scheduleController.selectedDept.value;
      final section = classModel.isClassroom ? "Classrooms" : "Labs";
      final date = _scheduleController.selectedDate.value;

      final batch = _firestore.batch();
      final bookingId = _firestore.collection("requests").doc().id;

      final session = await _sessionController.getSession();

      // ---------- REQUEST DATA (always stored once) ----------
      final requestRef = _firestore
          .collection("requests")
          .doc(dept)
          .collection("requests_list")
          .doc(bookingId);

      final requestData = {
        "bookingId": bookingId,
        "username": session["username"],
        "email": session["email"],
        "department": dept,
        "roomId": classModel.className,
        "reason": reason,
        "timeSlot": timeslot, // merged readable slot range
        "consideredSlots": consideredSlots ?? [],
        "status": "Pending",
        "day": day,
        "requestedDate": date,
        "createdAt": Timestamp.now(),
      };

      batch.set(requestRef, requestData);

      // Application object for each slot
      final application = {
        "bookingId": bookingId,
        "username": session["username"],
        "email": session["email"],
        "reason": reason,
        "requestedDate": date,
        "createdAt": Timestamp.now(),
        "status": "Pending",
      };

      // ---------- SLOT UPDATES ----------
      // CASE 1: Timeslot exists normally → update only that slot
      if (consideredSlots == null || consideredSlots.isEmpty) {
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
          "applications.$date": FieldValue.arrayUnion([application]),
        });
      }
      // CASE 2: Merged slots → update all individual existing slots
      else {
        for (final slot in consideredSlots) {
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
      }

      await batch.commit();
      Get.snackbar("Success", "Application submitted");
    } catch (e) {
      Get.snackbar("Error", "Failed to submit: $e");
      print("ERROR: $e");
    }
  }
}
