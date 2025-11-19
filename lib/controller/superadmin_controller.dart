import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

class SuperAdminController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> addUser(Map<String, dynamic> data) async {
    try {
      await _firestore.collection("faculty").add(data);

      Get.snackbar(
        "Success",
        "User added successfully",
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        "Error",
        "Failed to add user: $e",
        snackPosition: SnackPosition.BOTTOM,
        colorText: const Color.fromARGB(255, 224, 0, 0),
      );
    }
  }
}
