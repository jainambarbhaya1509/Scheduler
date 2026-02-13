import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:googleapis_auth/auth_io.dart';

class FCMService {
  static Future<String> _getAccessToken() async {
    // Load service account json
    final jsonString =
        await rootBundle.loadString('assets/keys/scheduler-1a878-b2f2f5598019.json');
    final jsonMap = json.decode(jsonString);

    // Create credentials
    final credentials = ServiceAccountCredentials.fromJson(jsonMap);

    // Get auth client
    final scopes = ['https://www.googleapis.com/auth/firebase.messaging'];
    final client = await clientViaServiceAccount(credentials, scopes);

    final accessToken = client.credentials.accessToken.data;
    client.close();

    return accessToken;
  }

  static Future<void> sendNotification({
    required String deviceToken,
    required String title,
    required String body,
  }) async {
    final jsonString =
        await rootBundle.loadString('assets/keys/scheduler-1a878-b2f2f5598019.json');
    final projectId = json.decode(jsonString)['project_id']; // ⭐ FIX HERE

    final accessToken = await _getAccessToken();

    final url =
        'https://fcm.googleapis.com/v1/projects/$projectId/messages:send';

    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
      body: jsonEncode({
        "message": {
          "token": deviceToken,
          "notification": {
            "title": title,
            "body": body,
          },
          "data": {
            "click_action": "FLUTTER_NOTIFICATION_CLICK"
          }
        }
      }),
    );

    print("FCM Status: ${response.statusCode}");
    print("FCM Body: ${response.body}");
  }
}
