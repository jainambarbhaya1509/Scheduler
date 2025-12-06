import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:schedule/controller/session_controller.dart';

class RequestsController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final appliedRequests = <Map<String, dynamic>>[].obs;
  final allRequests = <Map<String, dynamic>>[].obs;
  final acceptedRequests = <Map<String, dynamic>>[].obs;
  final rejectedRequests = <Map<String, dynamic>>[].obs;
  final pendingRequests = <Map<String, dynamic>>[].obs;

  StreamSubscription? _userRequestsSubscription;
  StreamSubscription? _adminRequestsSubscription;

  final SessionController _sessionController = Get.put(SessionController());

  @override
  void onInit() {
    super.onInit();
    _initializeListeners();
  }

  /// Set up real-time listeners instead of manual fetches

  void _initializeListeners() async {
    final session = await _sessionController.getSession();
    if (session["isHOD"]) {
      _setupAdminListener();
    }
    _setupUserListener();
  }

  /// Real-time listener for user requests
  void _setupUserListener() async {
    final session = await _sessionController.getSession();

    final userEmail = session["email"];

    _userRequestsSubscription = _firestore
        .collectionGroup('requests_list')
        .where('email', isEqualTo: userEmail)
        .snapshots()
        .listen((snapshot) {
          allRequests.clear();
          acceptedRequests.clear();
          rejectedRequests.clear();
          pendingRequests.clear();

          for (var doc in snapshot.docs) {
            final data = doc.data();

            allRequests.add(data);

            switch (data['status']?.toString().toLowerCase() ?? 'pending') {
              case 'accepted':
                acceptedRequests.add(data);
                break;
              case 'rejected':
                rejectedRequests.add(data);
                break;
              default:
                pendingRequests.add(data);
            }
          }
        });
  }

  /// Real-time listener for admin requests
  void _setupAdminListener() async {
    final session = await _sessionController.getSession();

    _adminRequestsSubscription = _firestore
        .collection('requests')
        .doc(session["department"])
        .collection('requests_list')
        .snapshots()
        .listen((snapshot) {
          appliedRequests.assignAll(
            snapshot.docs.map((doc) => doc.data()).toList(),
          );
        });
  }

  /// Simplified update with batch operation

  Future<void> updateReservationStatus({
    required String bookingId,
    required String dept,
    required String newStatus,
    required String day,
    required String roomId,
    required String timeSlot,
    required bool isClassroom,
    required String requestedDate,
    List<String>? consideredSlots,
  }) async {
    try {
      final ref = _firestore
          .collection("requests")
          .doc(dept)
          .collection("requests_list")
          .doc(bookingId);
      final snap = await ref.get();

      // Use provided consideredSlots if passed, otherwise fall back to stored value
      final List<String> effectiveConsideredSlots = consideredSlots ??
          List<String>.from(snap.data()?["consideredSlots"] ?? []);

      await ref.update({"status": newStatus});

      // Batch update slot applications
      await _updateSlotApplicationStatusBatch(
        day: day,
        dept: dept,
        roomId: roomId,
        timeSlot: timeSlot,
        bookingId: bookingId,
        newStatus: newStatus,
        isClassroom: isClassroom,
        consideredSlots: effectiveConsideredSlots,
      );

      Get.snackbar("Success", "Application updated");
    } catch (e) {
      Get.snackbar("Error", "Failed: $e");
    }
  }

  // Replaced per-document sequential updates with a batch-based updater
  Future<void> _updateSlotApplicationStatusBatch({
    required String day,
    required String dept,
    required String roomId,
    required String timeSlot,
    required String bookingId,
    required String newStatus,
    required bool isClassroom,
    List<String>? consideredSlots,
  }) async {
    try {
      final slotsToUpdate =
          consideredSlots != null && consideredSlots.isNotEmpty
              ? consideredSlots
              : [timeSlot];

      final WriteBatch batch = _firestore.batch();
      final List<DocumentReference> docsToUpdate = [];

      for (final slot in slotsToUpdate) {
        final slotRef = _firestore
            .collection("slots")
            .doc(day)
            .collection("departments")
            .doc(dept)
            .collection(isClassroom ? "Classrooms" : "Labs")
            .doc(roomId)
            .collection("slots")
            .doc(slot);

        final snapshot = await slotRef.get();
        if (!snapshot.exists) continue;

        final raw = snapshot.data()?['applications'];
        if (raw == null || raw is! Map<String, dynamic>) continue;

        final Map<String, dynamic> applications = Map<String, dynamic>.from(raw);

        bool updated = false;

        applications.forEach((dateKey, list) {
          if (list is List) {
            for (int i = 0; i < list.length; i++) {
              final app = list[i];
              if (app is Map && app['bookingId'] == bookingId) {
                // create a new map to avoid mutating original references unexpectedly
                list[i] = {...Map<String, dynamic>.from(app), "status": newStatus};
                updated = true;
              }
            }
          }
        });

        if (updated) {
          // queue update in batch
          batch.update(slotRef, {"applications": applications});
          docsToUpdate.add(slotRef);
        }
      }

      if (docsToUpdate.isNotEmpty) {
        await batch.commit();
      }
    } catch (e) {
      print("ERROR updating slot app status (batch): $e");
    }
  }

  // Future<void> transferBooking({
  //   required String bookingId,
  //   required String fromDept,
  //   required String toDept,
  // }) async {
  //   try {
  //     final fromRef = _firestore
  //         .collection("requests")
  //         .doc(fromDept)
  //         .collection("requests_list")
  //         .doc(bookingId);

  //     final toRef = _firestore
  //         .collection("requests")
  //         .doc(toDept)
  //         .collection("requests_list")
  //         .doc(bookingId);

  //     final snap = await fromRef.get();
  //     if (!snap.exists) {
  //       Get.snackbar("Error", "Booking not found in $fromDept");
  //       return;
  //     }

  //     final data = snap.data()!;
  //     await toRef.set(data);
  //     await fromRef.delete();

  //     Get.snackbar("Success", "Booking transferred to $toDept");
  //   } catch (e) {
  //     Get.snackbar("Error", "Transfer failed: $e");
  //   }
  // }

  // Future<void> releaseRemainingSlots({
  //   required String dept,
  //   required String bookingId,
  //   required bool isClassroom,
  // }) async {
  //   try {
  //     final requestRef = _firestore
  //         .collection("requests")
  //         .doc(dept)
  //         .collection("requests_list")
  //         .doc(bookingId);

  //     final requestSnap = await requestRef.get();
  //     if (!requestSnap.exists) return;

  //     final requestData = requestSnap.data();
  //     if (requestData == null) return;

  //     final consideredSlots = List<String>.from(
  //       requestData["consideredSlots"] ?? [],
  //     );

  //     for (final slotInfo in requestData["slotDetails"] ?? []) {
  //       final day = slotInfo["day"];
  //       final roomId = slotInfo["roomId"];
  //       final timeSlot = slotInfo["timeSlot"];

  //       if (!consideredSlots.contains(timeSlot)) {
  //         await _updateSlotApplicationStatus(
  //           day: day,
  //           dept: dept,
  //           roomId: roomId,
  //           timeSlot: timeSlot,
  //           bookingId: bookingId,
  //           newStatus: "released",
  //           isClassroom: isClassroom,
  //         );
  //       }
  //     }
  //   } catch (e) {
  //     print("ERROR releasing remaining slots: $e");
  //   }
  // }


  // Future<void> releaseSlot({
  //   required String day,
  //   required String dept,
  //   required String roomId,
  //   required String timeSlot,
  //   required String bookingId,
  //   required bool isClassroom,
  //   required String requestedDate,
  // }) async {
  //   try {
  //     final slotRef = _firestore
  //         .collection("slots")
  //         .doc(day)
  //         .collection("departments")
  //         .doc(dept)
  //         .collection(isClassroom ? "Classrooms" : "Labs")
  //         .doc(roomId)
  //         .collection("slots")
  //         .doc(timeSlot);

  //     final snapshot = await slotRef.get();
  //     if (!snapshot.exists) return;

  //     final raw = snapshot.data()?['applications'];
  //     if (raw == null || raw is! Map<String, dynamic>) return;

  //     final Map<String, dynamic> applications = Map.from(raw);

  //     bool updated = false;

  //     applications.forEach((dateKey, list) {
  //       if (dateKey == requestedDate && list is List) {
  //         list.removeWhere((app) => app['bookingId'] == bookingId);
  //         updated = true;
  //       }
  //     });

  //     if (updated) {
  //       await slotRef.update({"applications": applications});
  //     }

  //     Get.snackbar("Success", "Slot released successfully");
  //   } catch (e) {
  //     Get.snackbar("Error", "Failed to release slot: $e");
  //   }
  // }

  @override
  void onClose() {
    _userRequestsSubscription?.cancel();
    _adminRequestsSubscription?.cancel();
    super.onClose();
  }
}
