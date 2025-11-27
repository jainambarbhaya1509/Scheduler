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
  const String password = 'ucfnymzzeuwmrcip'; // Use raw string if it has $ signs

  final smtpServer = gmail(username, password);

  final message = Message()
    ..from = Address(username, 'Scheduler App')
    ..recipients.add(facultyEmail)
    ..subject = subject
    ..text = emailMessage;

  try {
    final sendReport = await send(message, smtpServer);
    print('Email sent: ' + sendReport.toString());
  } catch (e) {
    print('Failed to send email: $e');
  }
}
