import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:schedule/controller/session_controller.dart';
import 'package:schedule/utils/firestore_helpers.dart';
import 'package:schedule/services/firestore_service.dart';
import 'package:schedule/services/error_handler.dart';

class LoginController extends GetxController {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final newPasswordController = TextEditingController();

  final isLoading = false.obs;

  bool isAuthenticated = false;
  bool isAuthenticating = false;
  String error = '';

  final _db = FirestoreService().instance;
  final _sessionController = SessionController();

  /// Optimized login with validation
  Future<Map<String, dynamic>?> login() async {
    try {
      isLoading.value = true;

      final email = emailController.text.trim();
      final password = passwordController.text.trim();

      if (email.isEmpty || password.isEmpty) {
        ErrorHandler.handleError("Error", "Please fill all fields");
        return null;
      }

      final query = await _db
          .collection("faculty")
          .where("email", isEqualTo: email)
          .limit(1)
          .get();

      if (query.docs.isEmpty) {
        ErrorHandler.handleError("Login Failed", "User not found");
        return null;
      }

      final user = query.docs.first.data();

      if (FirestoreHelpers.safeGet<String>(user, "password") != password) {
        ErrorHandler.handleError("Login Failed", "Incorrect password");
        return null;
      }

      await _sessionController.setSession(
        FirestoreHelpers.safeGet<String>(user, "username") ?? "",
        FirestoreHelpers.safeGet<String>(user, "email") ?? "",
        password,
        FirestoreHelpers.safeGet<String>(user, "department") ?? "",
        FirestoreHelpers.safeGet<bool>(user, "isHOD") ?? false,
        FirestoreHelpers.safeGet<bool>(user, "isSuperAdmin") ?? false,
        FirestoreHelpers.safeGet<bool>(user, "isAdmin") ?? false,
      );

      ErrorHandler.handleSuccess("Success", "Welcome ${user['username']}");
      return user;
    } catch (e) {
      ErrorHandler.showError(e);
      return null;
    } finally {
      isLoading.value = false;
    }
  }

  /// Change password with session update
  Future<void> changePassword() async {
    final session = await _sessionController.getSession();

    try {
      isLoading.value = true;
      final newPassword = newPasswordController.text.trim();

      if (newPassword.isEmpty) {
        ErrorHandler.handleError("Error", "Please enter new password");
        return;
      }

      final query = await _db
          .collection("faculty")
          .where("email", isEqualTo: session["email"])
          .limit(1)
          .get();

      if (query.docs.isEmpty) {
        ErrorHandler.handleError("Failed", "User not found");
        return;
      }

      final docId = query.docs.first.id;
      final user = query.docs.first.data();

      await _db.collection("faculty").doc(docId).update({"password": newPassword});

      await _sessionController.setSession(
        FirestoreHelpers.safeGet<String>(user, "username") ?? "",
        session["email"],
        newPassword,
        FirestoreHelpers.safeGet<String>(user, "department") ?? "",
        FirestoreHelpers.safeGet<bool>(user, "isHOD") ?? false,
        FirestoreHelpers.safeGet<bool>(user, "isSuperAdmin") ?? false,
        FirestoreHelpers.safeGet<bool>(user, "isAdmin") ?? false,
      );

      ErrorHandler.handleSuccess("Success", "Password changed successfully");
      newPasswordController.clear();
    } catch (e) {
      ErrorHandler.showError(e);
    } finally {
      isLoading.value = false;
    }
  }

  /// Logout
  Future<void> logout() async {
    await _sessionController.clearSession();
    Get.offAllNamed("/login");
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    newPasswordController.dispose();
    super.onClose();
  }
}
