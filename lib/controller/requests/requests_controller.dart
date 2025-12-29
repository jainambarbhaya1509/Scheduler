import 'package:schedule/imports.dart';

class RequestsController extends GetxController {
  final _firestore = FirestoreService().instance;

  final appliedRequests = <Map<String, dynamic>>[].obs;
  final allRequests = <Map<String, dynamic>>[].obs;
  final acceptedRequests = <Map<String, dynamic>>[].obs;
  final rejectedRequests = <Map<String, dynamic>>[].obs;
  final pendingRequests = <Map<String, dynamic>>[].obs;

  StreamSubscription? _userRequestsSubscription;
  StreamSubscription? _adminRequestsSubscription;

  final _sessionController = Get.put(SessionController());

  @override
  void onInit() {
    super.onInit();
    _initializeListeners();
  }

  /// Initialize real-time listeners based on user role
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
        .listen((snapshot) => _processUserRequests(snapshot));
  }

  /// Extracted request processing logic
  void _processUserRequests(QuerySnapshot<Map<String, dynamic>> snapshot) {
    allRequests.clear();
    acceptedRequests.clear();
    rejectedRequests.clear();
    pendingRequests.clear();

    final now = DateTime.now();

    for (var doc in snapshot.docs) {
      final data = doc.data();

      final requestedDateStr = data['requestedDate'];
      final timeSlotStr = data['timeSlot'];

      // 🔒 Safety checks
      if (requestedDateStr == null || timeSlotStr == null) {
        continue;
      }

      // Parse date: dd-MM-yyyy
      final dateParts = requestedDateStr.split('-');
      if (dateParts.length != 3) continue;

      final day = int.parse(dateParts[0]);
      final month = int.parse(dateParts[1]);
      final year = int.parse(dateParts[2]);

      // Extract END time: "08:30-11:30"
      final endTime = timeSlotStr.split('-')[1];
      final timeParts = endTime.split(':');

      final hour = int.parse(timeParts[0]);
      final minute = int.parse(timeParts[1]);

      final expiryDateTime = DateTime(year, month, day, hour, minute);

      // ❌ Skip expired requests
      if (now.isAfter(expiryDateTime)) {
        continue;
      }

      // ✅ Still valid → process normally
      allRequests.add(data);

      switch ((data['status'] as String?)?.toLowerCase() ?? 'pending') {
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
          final now = DateTime.now();

          final filtered = snapshot.docs
              .where((doc) {
                final data = doc.data();

                final requestedDateStr = data['requestedDate'];
                final timeSlotStr = data['timeSlot'];

                if (requestedDateStr == null || timeSlotStr == null) {
                  return false;
                }

                // Parse date: dd-MM-yyyy
                final dateParts = requestedDateStr.split('-');
                if (dateParts.length != 3) return false;

                final day = int.parse(dateParts[0]);
                final month = int.parse(dateParts[1]);
                final year = int.parse(dateParts[2]);

                // Extract END time from slot: "08:30-11:30"
                final endTime = timeSlotStr.split('-')[1];
                final timeParts = endTime.split(':');

                final hour = int.parse(timeParts[0]);
                final minute = int.parse(timeParts[1]);

                final expiryDateTime = DateTime(year, month, day, hour, minute);

                // KEEP only if expiry is in the future
                return now.isBefore(expiryDateTime);
              })
              .map((doc) => doc.data())
              .toList();

          appliedRequests.assignAll(filtered);
        });
  }

  /// Update reservation status with batch operations
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
      final requestData = snap.data();

      final effectiveSlots =
          consideredSlots ??
          List<String>.from(requestData?["consideredSlots"] ?? []);

      await ref.update({"status": newStatus});

      await _updateSlotApplicationStatusBatch(
        day: day,
        dept: dept,
        roomId: roomId,
        timeSlot: timeSlot,
        bookingId: bookingId,
        newStatus: newStatus,
        isClassroom: isClassroom,
        consideredSlots: effectiveSlots,
      );

      ErrorHandler.handleSuccess("Success", "Application updated");

      // Send notification based on status
      if (newStatus.toLowerCase() == 'accepted' ||
          newStatus.toLowerCase() == 'rejected') {
        final userEmail = requestData?['email'];
        final userName = requestData?['username'];
        final subject = newStatus.toLowerCase() == 'accepted'
            ? 'Room Request Accepted'
            : 'Room Request Rejected';
        final emailMessage = newStatus.toLowerCase() == 'accepted'
            ? 'Dear $userName,\n\nYour room request on $roomId for $timeSlot on $requestedDate has been accepted.\n\nBest regards,\nSchedule Team'
            : 'Dear $userName,\n\nYour room request on $roomId for $timeSlot on $requestedDate has been rejected.\n\nBest regards,\nSchedule Team';

        sendEmailNotification(
          facultyEmail: userEmail,
          userName: userName,
          subject: subject,
          emailMessage: emailMessage,
        );
      }
    } catch (e) {
      ErrorHandler.showError(e);
    }
  }

  /// Optimized batch update with efficient slot processing
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
      final slotsToUpdate = (consideredSlots?.isNotEmpty ?? false)
          ? consideredSlots!
          : [timeSlot];

      final batch = _firestore.batch();
      int ops = 0;

      for (final slot in slotsToUpdate) {
        if (ops >= 450) {
          await batch.commit();
          ops = 0;
        }

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

        final applications = Map<String, dynamic>.from(raw);
        bool updated = false;

        applications.forEach((dateKey, list) {
          if (list is List) {
            for (int i = 0; i < list.length; i++) {
              final app = list[i];
              if (app is Map && app['bookingId'] == bookingId) {
                list[i] = {...app, "status": newStatus};
                updated = true;
              }
            }
          }
        });

        if (updated) {
          batch.update(slotRef, {"applications": applications});
          ops++;
        }
      }

      if (ops > 0) await batch.commit();
    } catch (e) {
      logger.d("ERROR updating slot app status: $e");
    }
  }

  @override
  void onClose() {
    _userRequestsSubscription?.cancel();
    _adminRequestsSubscription?.cancel();
    super.onClose();
  }
}
