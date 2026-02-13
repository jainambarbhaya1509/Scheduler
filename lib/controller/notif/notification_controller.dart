import 'package:cloud_firestore/cloud_firestore.dart';
import '../session/session_controller.dart';
import '../../models/notification_model.dart';

class NotificationController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// 🔹 Get faculty doc id using session email
  Future<String?> getFacultyDocId() async {
    final session = await SessionController().getSession();

    final snapshot = await _firestore
        .collection("faculty")
        .where("email", isEqualTo: session["email"])
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) return null;
    return snapshot.docs.first.id;
  }

  Stream<List<NotificationModel>> getNotificationsStream() async* {
    final collectionRef = await _getNotificationCollection();

    if (collectionRef == null) {
      yield [];
      return;
    }

    yield* collectionRef
        .orderBy("createdAt", descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => NotificationModel.fromDoc(doc))
              .toList(),
        );
  }

  Future<void> addNotificationForUser({
    required String email,
    required String title,
    required String body,
    String? bookingId,
  }) async {
    try {
      // 🔥 STEP 1 — find faculty document using email
      final snapshot = await _firestore
          .collection("faculty")
          .where("email", isEqualTo: email)
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) {
        print("❌ Faculty not found for notification");
        return;
      }

      final facultyDocId = snapshot.docs.first.id;

      // 🔥 STEP 2 — add notification to REAL document
      await _firestore
          .collection("faculty")
          .doc(facultyDocId)
          .collection("notifications")
          .add({
            "title": title,
            "body": body,
            "createdAt": FieldValue.serverTimestamp(),
            "isRead": false,
            "type": "request_update",
            "bookingId": bookingId,
          });

      print("✅ Notification stored successfully");
    } catch (e) {
      print("Error adding user notification: $e");
    }
  }

  /// ✅ MARK AS READ
  Future<void> markAsRead(String notificationId) async {
    final collectionRef = await _getNotificationCollection();
    if (collectionRef == null) return;

    await collectionRef.doc(notificationId).update({"isRead": true});
  }

  /// 🗑 DELETE NOTIFICATION
  Future<void> deleteNotification(String notificationId) async {
    final collectionRef = await _getNotificationCollection();
    if (collectionRef == null) return;

    await collectionRef.doc(notificationId).delete();
  }

  /// 🔥 Get current user's notification collection (faculty OR user)
  Future<CollectionReference<Map<String, dynamic>>?>
  _getNotificationCollection() async {
    final session = await SessionController().getSession();
    final snapshot = await _firestore
        .collection("faculty")
        .where("email", isEqualTo: session["email"])
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) return null;

    final facultyId = snapshot.docs.first.id;

    return _firestore
        .collection("faculty")
        .doc(facultyId)
        .collection("notifications");
  }
}
