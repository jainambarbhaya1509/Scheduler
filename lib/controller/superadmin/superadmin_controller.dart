import 'package:schedule/imports.dart';
import 'package:schedule/models/faculty_model.dart';

class SuperAdminController extends GetxController {
  final _firestore = FirestoreService().instance;
  final RxList<FacultyModel> faculties = <FacultyModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    _bindFacultyStream();
  }

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

      try {
        final docRef = await _firestore.collection("faculty").add(data);

        try {
          await sendEmailNotification(
            facultyEmail: data["email"],
            userName: data["username"],
            subject: "Welcome to Faculty Portal",
            emailMessage:
                "Your account has been created successfully. Your password is: ${data["password"]}",
          );
        } catch (emailError) {
          await docRef.delete();
          rethrow;
        }
      } catch (e) {
        logger.d("Operation failed: $e");
      }

      ErrorHandler.handleSuccess(
        "Success",
        "User added successfully & Notification sent",
      );
    } catch (e) {
      ErrorHandler.showError(e);
    }
  }

  void _bindFacultyStream() {
    faculties.bindStream(
      _firestore
          .collection("faculty")
          .where("isSuperAdmin", isEqualTo: false)
          .snapshots()
          .map(
            (query) => query.docs.map((doc) {
              final data = doc.data();
              return FacultyModel(
                email: data['email'] ?? '',
                username: data['username'] ?? '',
                department: data['department'] ?? '',
                isHOD: data['isHOD'] ?? false,
                isAdmin: data['isAdmin'] ?? false,
              );
            }).toList(),
          ),
    );
  }

  /// Delete faculty
  Future<void> deleteUser({
    required String email,
    required String userName,
  }) async {
    try {
      final snapshot = await _firestore
          .collection("faculty")
          .where("email", isEqualTo: email)
          .get();

      for (final doc in snapshot.docs) {
        await doc.reference.delete();
      }

      await sendEmailNotification(
        facultyEmail: email,
        userName: userName,
        subject: "Faculty Account Deleted",
        emailMessage:
            "Your faculty account has been removed from the system. "
            "If this is a mistake, please contact the administrator.",
      );

      ErrorHandler.handleSuccess("Deleted", "Faculty deleted successfully");
    } catch (e) {
      ErrorHandler.showError(e.toString());
    }
  }
}
