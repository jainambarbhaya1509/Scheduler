import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:schedule/controller/user_controller.dart';

class RequestsController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late final UserController _userController = Get.find<UserController>();

  final appliedRequests = <Map<String, dynamic>>[].obs;
  final allRequests = <Map<String, dynamic>>[].obs;
  final acceptedRequests = <Map<String, dynamic>>[].obs;
  final rejectedRequests = <Map<String, dynamic>>[].obs;
  final pendingRequests = <Map<String, dynamic>>[].obs;

  StreamSubscription? _userRequestsSubscription;
  StreamSubscription? _adminRequestsSubscription;

  @override
  void onInit() {
    super.onInit();
    _initializeListeners();
  }

  /// Set up real-time listeners instead of manual fetches
  void _initializeListeners() {
    if (_userController.isHOD.value) {
      _setupAdminListener();
    }
    _setupUserListener();
  }

  /// Real-time listener for user requests
  void _setupUserListener() {
    final userEmail = _userController.email.value;

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
  void _setupAdminListener() {
    final dept = _userController.department.value;

    _adminRequestsSubscription = _firestore
        .collection('requests')
        .doc(dept)
        .collection('requests_list')
        .snapshots()
        .listen((snapshot) {
          appliedRequests.assignAll(
            snapshot.docs.map((doc) => doc.data()).toList(),
          );
        });
  }

  /// Simplified update with batch operation
  /// TODO: [UPDATE THE LIST IN THE APPLICATION's LIST]
  Future<void> updateReservationStatus({
    required String bookingId,
    required String dept,
    required String newStatus,
    required String day,
    required String roomId,
    required String timeSlot,
    required bool isClassroom,
  }) async {
    try {
      final ref = _firestore
          .collection("requests")
          .doc(dept)
          .collection("requests_list")
          .doc(bookingId);

      await ref.update({"status": newStatus});

      // ───────────────────────────────────────
      // UPDATE slot applications also
      // ───────────────────────────────────────
      await _updateSlotApplicationStatus(
        day: day,
        dept: dept,
        roomId: roomId,
        timeSlot: timeSlot,
        bookingId: bookingId,
        newStatus: newStatus,
      );

      Get.snackbar("Success", "Application updated");
    } catch (e) {
      Get.snackbar("Error", "Failed: $e");
    }
  }

  Future<void> _updateSlotApplicationStatus({
    required String day,
    required String dept,
    required String roomId,
    required String timeSlot,
    required String bookingId,
    required String newStatus,
  }) async {
    try {
      final slotRef = _firestore
          .collection("slots")
          .doc(day)
          .collection("departments")
          .doc(dept)
          .collection("Classrooms") // OR Labs (will handle below)
          .doc(roomId)
          .collection("slots")
          .doc(timeSlot);

      final snapshot = await slotRef.get();
      if (!snapshot.exists) return;

      List apps = snapshot.data()?['applications'] ?? [];

      final updated = apps.map((app) {
        if (app['bookingId'] == bookingId) {
          return {...app, "status": newStatus};
        }
        return app;
      }).toList();

      await slotRef.update({"applications": updated});
    } catch (e) {
      print("ERROR updating slot app status: $e");
    }
  }

  @override
  void onClose() {
    _userRequestsSubscription?.cancel();
    _adminRequestsSubscription?.cancel();
    super.onClose();
  }
}
