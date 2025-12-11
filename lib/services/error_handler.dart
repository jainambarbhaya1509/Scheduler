import 'package:schedule/imports.dart';

/// Centralized error handling and user feedback
class ErrorHandler {
  static void handleError(String title, String message) {
    Get.snackbar(title, message);
    logger.d("[$title] $message");
  }

  static void handleSuccess(String title, String message) {
    Get.snackbar(title, message);
  }

  static void showError(dynamic error) {
    final errorMsg = error.toString();
    handleError("Error", errorMsg);
    logger.d("Error occurred: $errorMsg");
  }
}
