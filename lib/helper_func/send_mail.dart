import 'dart:developer';

import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';

Future<void> sendEmailNotification({
  required String facultyEmail,
  required String userName,
  required String userEmail,
  required String subject,
  required String emailMessage
}) async {
  const String username = 'pranavvdv@gmail.com';
  const String password = 'ucfnymzzeuwmrcip'; 

  final smtpServer = gmail(username, password);

  final message = Message()
    ..from = Address(username, 'Scheduler App')
    ..recipients.add(facultyEmail)
    ..subject = subject
    ..text = emailMessage;

  try {
    final sendReport = await send(message, smtpServer);
    log('Email sent: $sendReport');
  } catch (e) {
    log('Failed to send email: $e');
  }
}
