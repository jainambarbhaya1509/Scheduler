import 'package:schedule/imports.dart';


class SuperAdminController extends GetxController {
  final _firestore = FirestoreService().instance;

  /// Add new user to faculty collection
  Future<void> addUser(Map<String, dynamic> data) async {
    try {
      // Check if user already exists
      final querySnapshot = await _firestore
          .collection("faculty")
          .where("email", isEqualTo: data["email"])
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        ErrorHandler.showError("User with this email already exists");
        return;
      }

      await _firestore.collection("faculty").add(data);
      await sendEmailNotification(
        facultyEmail: data["email"],
        userName: data["username"],
        userEmail: data["email"],
        subject: "Welcome to Faculty Portal",
        emailMessage:
            "Your account has been created successfully. Your password is: ${data["password"]}",
      );
      ErrorHandler.handleSuccess("Success", "User added successfully & Notification sent");
    } catch (e) {
      ErrorHandler.showError(e);
    }
  }
}
