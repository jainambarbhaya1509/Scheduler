import 'dart:convert';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _local =
      FlutterLocalNotificationsPlugin();

  /// Initialize everything
  static Future<void> initialize() async {
    await _requestPermission();
    await _initLocalNotifications();
    _setupFirebaseHandlers();
  }

  /// Ask notification permission (iOS + Android 13+)
  static Future<void> _requestPermission() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;
    await messaging.requestPermission();
  }

  /// Local notification setup
  static Future<void> _initLocalNotifications() async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iOS = DarwinInitializationSettings();
    const initSettings = InitializationSettings(android: android, iOS: iOS);

    await _local.initialize(settings: initSettings);
  }

  /// Listen to FCM events
  static void _setupFirebaseHandlers() {
    // App in foreground
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      _showNotification(message);
    });

    // App opened from notification
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      print("User tapped notification");
    });
  }

  /// Show notification using flutter_local_notifications
  static Future<void> _showNotification(RemoteMessage message) async {
    const androidDetails = AndroidNotificationDetails(
      "default_channel",
      "General Notifications",
      importance: Importance.max,
      priority: Priority.high,
    );

    const details = NotificationDetails(android: androidDetails);

    await _local.show(
      id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title: message.notification?.title ?? "New Notification",
      body: message.notification?.body ?? "",
      notificationDetails: details,
      payload: jsonEncode(message.data),
    );
  }

  /// Get FCM device token (send this to your backend)
  static Future<String?> getToken() async {
    return await FirebaseMessaging.instance.getToken();
  }
}
