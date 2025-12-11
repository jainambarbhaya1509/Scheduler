import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:schedule/imports.dart';

Future<void> sendEmailNotification({
  required String facultyEmail,
  required String userName,
  required String userEmail,
  required String subject,
  required String emailMessage,
}) async {
  const String username = 'pranavvdv@gmail.com';
  const String password = 'ucfnymzzeuwmrcip';

  if (kIsWeb) {
    final url = Uri.parse('https://email-api.onrender.com/send_email');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'recipient_email': facultyEmail,
        'subject': subject,
        'body': emailMessage,
      }),
    );

    if (response.statusCode == 200) {
      logger.d("Email sent!");
    } else {
      logger.d("Failed to send email: ${response.body}");
    }
    return;
  }

  final smtpServer = gmail(username, password);
  final message = Message()
    ..from = Address(username, 'Scheduler App')
    ..recipients.add(facultyEmail)
    ..subject = subject
    ..text = emailMessage;

  try {
    final sendReport = await send(message, smtpServer);
    logger.d('Email sent: $sendReport');
  } catch (e) {
    logger.d('Failed to send email: $e');
  }
}
