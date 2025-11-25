import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:schedule/controller/profile_controller.dart';
import 'package:schedule/controller/session_controller.dart';

class LoginController extends GetxController {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final oldPasswordController = TextEditingController();
  final newPasswordController = TextEditingController();

  final isLoading = false.obs;

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  late final SessionController session = Get.find<SessionController>();

  Future<Map<String, dynamic>?> login() async {
    try {
      isLoading.value = true;

      final email = emailController.text.trim();
      final password = passwordController.text.trim();

      if (email.isEmpty || password.isEmpty) {
        Get.snackbar("Error", "Email or Password cannot be empty");
        return null;
      }

      // Fetch user from Firestore — using "users" collection ONLY
      final query = await _db
          .collection("faculty")
          .where("email", isEqualTo: email)
          .limit(1)
          .get();

      if (query.docs.isEmpty) {
        Get.snackbar("Error", "User not found");
        return null;
      }

      final user = query.docs.first.data();

      if (user["password"] != password) {
        Get.snackbar("Error", "Incorrect password");
        return null;
      }

      // Save session
      await session.setSession(
        email,
        password,
        user["isHOD"] ?? false,
        user["isSuperAdmin"] ?? false,
        user["isAdmin"] ?? false,
      );

      return user;
    } catch (e) {
      Get.snackbar("Login Error", e.toString());
      return null;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> changePassword() async {
    try {
      isLoading.value = true;

      final profile = Get.find<ProfileController>();
      final email = profile.userEmail.trim();

      final oldPassword = oldPasswordController.text.trim();
      final newPassword = newPasswordController.text.trim();

      if (oldPassword.isEmpty || newPassword.isEmpty) {
        Get.snackbar("Error", "Please fill all fields");
        return;
      }

      // Fetch user from Firestore (same users collection)
      final query = await _db
          .collection("faculty")
          .where("email", isEqualTo: email)
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

      // Update Firestore
      await _db.collection("users").doc(doc.id).update({
        "password": newPassword,
      });

      // Update local session
      await session.setSession(
        email,
        newPassword,
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

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    oldPasswordController.dispose();
    newPasswordController.dispose();
    super.onClose();
  }
}
