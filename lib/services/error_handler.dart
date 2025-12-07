import 'dart:developer';

import 'package:get/get.dart';

/// Centralized error handling and user feedback
class ErrorHandler {
  static void handleError(String title, String message) {
    Get.snackbar(title, message);
    log("[$title] $message");
  }

  static void handleSuccess(String title, String message) {
    Get.snackbar(title, message);
  }

  static void showError(dynamic error) {
    final errorMsg = error.toString();
    handleError("Error", errorMsg);
    log("Error occurred: $errorMsg");
  }
}
