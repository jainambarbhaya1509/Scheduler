import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';

Future<void> sendEmailNotification({
  required String facultyEmail,
  required String userName,
  required String room,
  required String date,
  required String time,
  required String reason,
  required String userEmail
}) async {
  const String username = 'pranavvdv@gmail.com';
  const String password = 'ucfnymzzeuwmrcip'; // Use raw string if it has $ signs

  final smtpServer = gmail(username, password);

  final message = Message()
    ..from = Address(username, 'Scheduler App')
    ..recipients.add(facultyEmail)
    ..subject = 'New Booking Request'
    ..text = 'Hello, Your request for application of booking $room on $date at $time for $reason is successful!.\n\nThank you!\n\nScheduler App Team';

  try {
    final sendReport = await send(message, smtpServer);
    print('Email sent: ' + sendReport.toString());
  } catch (e) {
    print('Failed to send email: $e');
  }
}
