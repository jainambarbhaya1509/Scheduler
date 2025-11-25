import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:schedule/controller/session_controller.dart';

class LoginController extends GetxController {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final isLoading = false.obs;

  final oldPasswordController = TextEditingController();
  final newPasswordController = TextEditingController();

  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final SessionController _sessionController = SessionController();

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

      await _sessionController.setSession(
        user["username"] ?? "",
        user["email"] ?? "",
        user["password"] ?? "",
        user["department"] ?? "",
        user["isHOD"] ?? false,
        user["isSuperAdmin"] ?? false,
        user["isAdmin"] ?? false,
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

  /// Change password with session update
  Future<void> changePassword() async {
    // final ProfileController profileController = Get.find<ProfileController>();
    final session = await _sessionController.getSession();

    try {
      isLoading.value = true;

      final oldPassword = oldPasswordController.text.trim();
      final newPassword = newPasswordController.text.trim();

      if (oldPassword.isEmpty || newPassword.isEmpty) {
        Get.snackbar("Error", "Please fill all fields");
        return;
      }

      final query = await _db
          .collection("faculty")
          .where("email", isEqualTo: session["email"])
          .limit(1)
          .get();

      if (query.docs.isEmpty) {
        Get.snackbar("Failed", "User not found");
        return;
      }

      final doc = query.docs.first;
      final user = doc.data();

      if (user["password"] != oldPassword) {
        Get.snackbar("Failed", "Old password is incorrect");
        return;
      }

      await _db.collection("faculty").doc(doc.id).update({
        "password": newPassword,
      });

      // ✅ Update session after password change
      await _sessionController.setSession(
        user["username"] ?? "",
        user["email"],
        newPassword,
        user["department"] ?? "",
        user["isHOD"] ?? false,
        user["isSuperAdmin"] ?? false,
        user["isAdmin"] ?? false,
      );

      Get.snackbar("Success", "Password changed successfully");

      oldPasswordController.clear();
      newPasswordController.clear();
    } catch (e) {
      Get.snackbar("Error", e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  /// Optional logout
  Future<void> logout() async {
    await _sessionController.clearSession();
    Get.offAllNamed("/login");
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    oldPasswordController.dispose();
    newPasswordController.dispose();
    super.onClose();
  }
}
