import 'package:rxdart/rxdart.dart';
import 'package:schedule/controller/notif/notification_controller.dart';
import 'package:schedule/helper/date_time/is_same_day.dart';
import 'package:schedule/imports.dart';
import 'package:schedule/services/push_notif_sender.dart';

class TimingsController extends GetxController {
  final _firestore = FirestoreService().instance;

  final isLoading = false.obs;

  final classroomList = <ClassAvailabilityModel>[].obs;
  final labList = <ClassAvailabilityModel>[].obs;

  final hoursRequired = 0.0.obs;
  final initialTiming = "".obs;

  final _scheduleController = Get.put(ScheduleController(), permanent: true);
  final _sessionController = Get.put(SessionController());
  final NotificationController _notifController = NotificationController();

  StreamSubscription? _classroomSub;
  StreamSubscription? _labSub;

  void fetchTimings(DepartmentAvailabilityModel deptModel) {
    final day = _scheduleController.selectedDay.value;
    final deptName = deptModel.departmentName!;
    final date = _scheduleController.selectedDate.value;

    isLoading.value = true;

    _classroomSub?.cancel();
    _labSub?.cancel();

    _classroomSub = _sectionStream(day, deptName, "Classrooms", true, date)
        .listen((data) {
          classroomList.value = data;
          isLoading.value = false;
        });

    _labSub = _sectionStream(day, deptName, "Labs", false, date).listen((data) {
      labList.value = data;
      isLoading.value = false;
    });
  }

  List<ClassAvailabilityModel> filterPastSlotsForToday(
    List<ClassAvailabilityModel> rooms,
    String selectedDate,
  ) {
    // 🔥 Only filter for TODAY
    if (!isToday(selectedDate)) return rooms;

    final now = TimeOfDay.now();
    final currentMinutes = now.hour * 60 + now.minute;

    return rooms
        .map((room) {
          final validTimings = room.timingsList.where((timing) {
            final startPart = timing.timing.split('-').last.trim();

            final parts = startPart.split(':');
            final startMinutes = int.parse(parts[0]) * 60 + int.parse(parts[1]);

            return startMinutes > currentMinutes;
          }).toList();

          if (validTimings.isEmpty) return null;

          return ClassAvailabilityModel(
            id: room.id,
            className: room.className,
            isClassroom: room.isClassroom,
            timingsList: validTimings,
          );
        })
        .whereType<ClassAvailabilityModel>()
        .toList();
  }

  Stream<List<ClassAvailabilityModel>> _sectionStream(
    String day,
    String deptName,
    String section,
    bool isClassroom,
    String date,
  ) {
    return _firestore
        .collection('slots')
        .doc(day)
        .collection('departments')
        .doc(deptName)
        .collection(section)
        .snapshots()
        .asyncExpand((roomsSnapshot) {
          final roomStreams = roomsSnapshot.docs
              .where((doc) => doc.id != "_meta")
              .map((roomDoc) {
                return roomDoc.reference.collection('slots').snapshots().map((
                  slotsSnapshot,
                ) {
                  final timings = slotsSnapshot.docs.map((slotDoc) {
                    final appliedUsers =
                        FirestoreHelpers.filterApplicationsByStatus(
                          slotDoc['applications'],
                          date,
                          'rejected',
                          exclude: true,
                        ).map((e) => UsersAppliedModel.fromMap(e)).toList();

                    return ClassTiming(
                      timing: "${slotDoc['start_time']}-${slotDoc['end_time']}",
                      appliedUsers: appliedUsers,
                    );
                  }).toList();

                  return ClassAvailabilityModel(
                    id: roomDoc.id,
                    className: roomDoc.id,
                    isClassroom: isClassroom,
                    timingsList: timings,
                  );
                });
              })
              .toList();

          if (roomStreams.isEmpty) {
            return Stream.value(<ClassAvailabilityModel>[]);
          }

          return CombineLatestStream.list(roomStreams).map((rooms) {
            var filtered = rooms;

            // 🔥 Remove past slots for today
            filtered = filterPastSlotsForToday(filtered, date);

            if (initialTiming.value.isNotEmpty) {
              filtered = filterSlotsAfter(filtered, initialTiming.value);
            }

            if (hoursRequired.value > 0) {
              filtered = findConsecutiveSlots(filtered, hoursRequired.value);
            }

            return filtered;
          });
        });
  }

  Future<void> apply({
    required ClassAvailabilityModel classModel,
    required String timeslot,
    required String reason,
    List<String>? consideredSlots,
  }) async {
    try {
      final day = _scheduleController.selectedDay.value;
      final dept = _scheduleController.selectedDept.value;
      final date = _scheduleController.selectedDate.value;
      final section = classModel.isClassroom ? "Classrooms" : "Labs";

      final session = await _sessionController.getSession();

      final bookingId = _firestore.collection("requests").doc().id;

      final application = {
        "bookingId": bookingId,
        "username": session["username"],
        "email": session["email"],
        "reason": reason,
        "requestedDate": date,
        "createdAt": Timestamp.now(),
        "status": "Pending",
      };

      final batch = _firestore.batch();

      // Store request
      final requestRef = _firestore
          .collection("requests")
          .doc(dept)
          .collection("requests_list")
          .doc(bookingId);

      batch.set(requestRef, {
        ...application,
        "department": dept,
        "roomId": classModel.className,
        "timeSlot": timeslot,
        "consideredSlots": consideredSlots ?? [],
        "day": day,
      });

      // Update slots
      final slots = consideredSlots?.isNotEmpty == true
          ? consideredSlots!
          : [timeslot];

      for (final slot in slots) {
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

      // 🔔 Notify HOD
      final hods = await _firestore
          .collection('faculty')
          .where('department', isEqualTo: dept)
          .where('isHOD', isEqualTo: true)
          .get();
      for (final hod in hods.docs) {
        final data = hod.data();

        final token = data['fcmToken'];

        // 🚫 Skip faculty without token
        if (token == null || token.toString().isEmpty) {
          print("⚠️ HOD ${data['email']} has no FCM token yet");
          continue;
        }

        await FCMService.sendNotification(
          deviceToken: token,
          title: "New Booking Request",
          body:
              "Booking request from ${session['username']}\nClass: ${classModel.className}\nDate: $date\nSlot: $timeslot",
        );
        await _notifController.addNotificationForUser(
          email: data['email'], // ✅ userUid actually stores email
          title: "New Booking Request",
          body:
              "Booking request from ${session['username']}\nClass: ${classModel.className}\nDate: $date\nSlot: $timeslot",
          bookingId: bookingId,
        );
      }

      Get.snackbar("Success", "Request submitted");
    } catch (e) {
      Get.snackbar("Error", e.toString());
    }
  }

  @override
  void onClose() {
    _classroomSub?.cancel();
    _labSub?.cancel();
    super.onClose();
  }
}
