import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'user_controller.dart';

class LoginController extends GetxController {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final isLoading = false.obs;

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
        superadmin: user["isSuperAdmin"] ?? false
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

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
