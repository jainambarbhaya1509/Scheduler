import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:schedule/helper_func/generate_password.dart';
import 'package:schedule/helper_func/send_mail.dart';
import 'package:schedule/services/firestore_service.dart';
import 'package:schedule/services/error_handler.dart';

class ForgetPasswordController extends GetxController {
  final otp = "".obs;
  final generatedPassword = "".obs;

  final isOtpSending = false.obs;
  final isPasswordSending = false.obs;

  final emailController = TextEditingController();
  final otpController = TextEditingController();

  final showOtpField = false.obs;

  final _firestore = FirestoreService().instance;

  /// Generate 6-digit OTP
  void generateOtp() {
    final rand = Random();
    otp.value = (100000 + rand.nextInt(900000)).toString();
  }

  /// Send OTP email
  Future<void> sendOtp(String email) async {
    try {
      isOtpSending.value = true;
      generateOtp();

      await sendEmailNotification(
        facultyEmail: email,
        userName: "User",
        userEmail: email,
        subject: "Your Verification Code",
        emailMessage: "Your 6-digit verification code is: ${otp.value}",
      );

      isOtpSending.value = false;
      ErrorHandler.handleSuccess("Success", "OTP sent to your email");
    } catch (e) {
      isOtpSending.value = false;
      ErrorHandler.showError(e);
    }
  }

  /// Verify OTP
  bool verifyOtp(String userInput) => userInput.trim() == otp.value;

  /// Generate random password

  /// Update password in Firestore
  Future<void> _updateFirestorePassword(String email) async {
    try {
      final query = await _firestore
          .collection("faculty")
          .where("email", isEqualTo: email)
          .limit(1)
          .get();

      if (query.docs.isEmpty) {
        throw Exception("No user found with this email");
      }

      final docId = query.docs.first.id;
      await _firestore.collection("faculty").doc(docId).update({
        "password": generatedPassword.value,
      });
    } catch (e) {
      ErrorHandler.showError(e);
      rethrow;
    }
  }

  /// Send new password and update Firestore
  Future<void> sendNewPassword(String email) async {
    try {
      isPasswordSending.value = true;
      generatedPassword.value = generateRandomPassword();

      await Future.wait([
        sendEmailNotification(
          facultyEmail: email,
          userName: "User",
          userEmail: email,
          subject: "Your New Password",
          emailMessage: "Your new password is: ${generatedPassword.value}",
        ),
        _updateFirestorePassword(email),
      ]);

      ErrorHandler.handleSuccess("Success", "Password reset successfully");
      isPasswordSending.value = false;
    } catch (e) {
      isPasswordSending.value = false;
      ErrorHandler.showError(e);
    }
  }

  @override
  void onClose() {
    emailController.dispose();
    otpController.dispose();
    super.onClose();
  }
}
