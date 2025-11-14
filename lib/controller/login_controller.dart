import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'user_controller.dart';

class LoginController extends GetxController {
  // TEXT CONTROLLERS
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  // LOADING STATE
  final isLoading = false.obs;

  // FIRESTORE INSTANCE
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // GLOBAL USER CONTROLLER
  final UserController userController = Get.find<UserController>();

  /// LOGIN FUNCTION
  Future<Map<String, dynamic>?> login() async {
    try {
      isLoading.value = true;

      final email = emailController.text.trim();
      final password = passwordController.text.trim();

      if (email.isEmpty || password.isEmpty) {
        Get.snackbar("Error", "Please fill all fields");
        return null;
      }

      // Check user in Firestore
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

      // PASSWORD MATCH
      if (user["password"] != password) {
        Get.snackbar("Login Failed", "Incorrect password");
        return null;
      }

      // SAVE USER ID + DATA
      final userCtrl = Get.find<UserController>();
      userCtrl.setUser(doc.id, user["username"], user["email"], user["department"]);

      // SUCCESS
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
