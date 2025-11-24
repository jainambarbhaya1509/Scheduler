import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:schedule/controller/profile_controller.dart';
import 'user_controller.dart';

class LoginController extends GetxController {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final isLoading = false.obs;

  final oldPasswordController = TextEditingController();
  final newPasswordController = TextEditingController();


  final FirebaseFirestore _db = FirebaseFirestore.instance;
  late final UserController _userController = Get.find<UserController>();

  /// Optimized login with validation
  Future<Map<String, dynamic>?> login() async {
    try {
      isLoading.value = true;

      final email = emailController.text.trim();
      final password = passwordController.text.trim();

      if (email.isEmpty || password.isEmpty) {
        Get.snackbar("Error", "Please fill all fields");
        return null;
      }

      final query = await _db
          .collection("faculty")
          .where("email", isEqualTo: email)
          .limit(1)
          .get();

      if (query.docs.isEmpty) {
        Get.snackbar("Login Failed", "User not found");
        return null;
      }

      final doc = query.docs.first;
      final user = doc.data();

      if (user["password"] != password) {
        Get.snackbar("Login Failed", "Incorrect password");
        return null;
      }

      _userController.setUser(
        doc.id,
        user["username"] ?? "",
        user["email"] ?? "",
        user["department"] ?? "",
        hod: user["isHOD"] ?? false,
        admin: user["isAdmin"] ?? false,
        superadmin: user["isSuperAdmin"] ?? false,
      );

      Get.snackbar("Success", "Welcome ${user['username']}");
      return user;
    } catch (e) {
      Get.snackbar("Error", e.toString());
      return null;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> changePassword() async {
    final ProfileController profileController = Get.find<ProfileController>();
    print(profileController.userEmail);
    try {
      isLoading.value = true;

      final oldPassword = oldPasswordController.text.trim();
      final newPassword = newPasswordController.text.trim();

      // Basic validation
      if (oldPassword.isEmpty || newPassword.isEmpty) {
        Get.snackbar("Error", "Please fill all fields");
        return;
      }

      // Fetch user
      final query = await _db
          .collection("faculty")
          .where("email", isEqualTo: profileController.userEmail)
          .limit(1)
          .get();

      if (query.docs.isEmpty) {
        Get.snackbar("Failed", "User not found");
        return;
      }

      final doc = query.docs.first;
      final user = doc.data();

      // Old password validation
      if (user["password"] != oldPassword) {
        Get.snackbar("Failed", "Old password is incorrect");
        return;
      }

      // Update new password
      await _db.collection("faculty").doc(doc.id).update({
        "password": newPassword,
      });

      Get.snackbar("Success", "Password changed successfully");

      // Clear fields
      oldPasswordController.clear();
      newPasswordController.clear();
    } catch (e) {
      Get.snackbar("Error", e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
