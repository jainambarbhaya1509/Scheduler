import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:universal_html/html.dart';
import 'package:universal_html/html.dart' as html;

class NotificationService {
  static final FlutterLocalNotificationsPlugin _local =
      FlutterLocalNotificationsPlugin();

  static const String _vapidKey =
      "BGqbnxdYA8pWgmhv_T0QoYMgWIYizzLwFWg643BTzEveSoEIV-SdN2B7I4LebAvwXelcewHOmP4ubLJf5tJofuM";

  /// Initialize notifications
  static Future<void> initialize() async {
    await _requestPermission();

    if (!kIsWeb) {
      await _initLocalNotifications();
      _listenServiceWorkerMessages();
    }

    _setupFirebaseHandlers();
  }

  /// =================================
  /// WEB → Receive messages from SW
  /// =================================
  static void _listenServiceWorkerMessages() {
    html.window.onMessage.listen((event) {
      try {
        final data = event.data;

        if (data is Map && data['type'] == 'push') {
          final title = data['title'] ?? "New Notification";
          final body = data['body'] ?? "";

          // If tab is open → show browser notification
          if (html.Notification.permission == "granted") {
            html.Notification(title, body: body);
          }
        }
      } catch (e) {
        print("SW message error: $e");
      }
    });
  }

  /// ================================
  /// PERMISSION (Web + Mobile Safe)
  /// ================================
  static Future<void> _requestPermission() async {
    try {
      NotificationSettings settings = await FirebaseMessaging.instance
          .requestPermission(alert: true, badge: true, sound: true);

      print("Permission: ${settings.authorizationStatus}");
    } catch (e) {
      // This prevents the "permission-blocked" crash on web
      print("Permission error (safe to ignore on web): $e");
    }
  }

  /// ================================
  /// LOCAL NOTIFICATIONS (MOBILE ONLY)
  /// ================================
  static Future<void> _initLocalNotifications() async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iOS = DarwinInitializationSettings();

    const initSettings = InitializationSettings(android: android, iOS: iOS);

    await _local.initialize(settings: initSettings);
  }

  /// ================================
  /// FIREBASE MESSAGE LISTENERS
  /// ================================
  static void _setupFirebaseHandlers() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      _showNotification(message);
    });

    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      print("User tapped notification");
    });
  }

  /// ================================
  /// SHOW NOTIFICATION (Platform Aware)
  /// ================================
  static Future<void> _showNotification(RemoteMessage message) async {
    // ================= WEB FOREGROUND =================
    if (kIsWeb) {
      final title = message.notification?.title ?? "New Notification";
      final body = message.notification?.body ?? "";

      // Ask browser if we can show notifications
      if (Notification.permission == "granted") {
        Notification(title, body: body);
      } else {
        print("Browser notification permission not granted");
      }
      return;
    }

    // ================= MOBILE =================
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

  /// ================================
  /// GET TOKEN (Web needs VAPID)
  /// ================================
  static Future<String?> getToken() async {
    if (kIsWeb) {
      return await FirebaseMessaging.instance.getToken(vapidKey: _vapidKey);
    }

    return await FirebaseMessaging.instance.getToken();
  }
}
