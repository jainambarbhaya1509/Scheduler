import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FCMTokenService {
  static final _messaging = FirebaseMessaging.instance;
  static final _db = FirebaseFirestore.instance;

  static Future<void> saveTokenToFaculty(String email) async {
    try {
      // Ask permission (Android 13+/iOS)
      await _messaging.requestPermission();

      // Get token from Firebase
      final token = await _messaging.getToken();

      if (token == null) {
        print("FCM token is NULL");
        return;
      }

      print("🔥 FCM TOKEN: $token");

      // Find faculty doc using email
      final query = await _db
          .collection("faculty")
          .where("email", isEqualTo: email)
          .limit(1)
          .get();

      if (query.docs.isEmpty) {
        print("Faculty doc not found");
        return;
      }

      final docId = query.docs.first.id;

      // Save token to Firestore ⭐
      await _db.collection("faculty").doc(docId).update({
        "fcmToken": token,
      });

      // Listen for token refresh
      FirebaseMessaging.instance.onTokenRefresh.listen((newToken) async {
        await _db.collection("faculty").doc(docId).update({
          "fcmToken": newToken,
        });
      });

      print("✅ Token saved to faculty collection");
    } catch (e) {
      print("FCM token save error: $e");
    }
  }
}
