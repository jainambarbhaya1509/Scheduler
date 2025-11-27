import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:schedule/helper_func/send_mail.dart';

class ForgetPasswordController extends GetxController {
  final otp = "".obs;
  final generatedPassword = "".obs;

  final isOtpSending = false.obs;
  final isPasswordSending = false.obs;

  final emailController = TextEditingController();
  final otpController = TextEditingController();

  final showOtpField = false.obs;

  /// 1. Generate 6-digit OTP
  void generateOtp() {
    final rand = Random();
    otp.value = (100000 + rand.nextInt(900000)).toString();
  }

  /// 2. Send OTP using your existing sendEmailNotification()
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
    } catch (e) {
      isOtpSending.value = false;
      rethrow;
    }
  }

  /// 3. Verify OTP entered by user
  bool verifyOtp(String userInput) {
    return userInput.trim() == otp.value;
  }

  Future<void> updateFirestorePassword(String email) async {
    try {
      final query = await FirebaseFirestore.instance
          .collection("faculty")
          .where("email", isEqualTo: email)
          .get();

      if (query.docs.isNotEmpty) {
        final docId = query.docs.first.id;

        await FirebaseFirestore.instance
            .collection("faculty")
            .doc(docId)
            .update({"password": generatedPassword.value});
      } else {
        throw Exception("No user found with this email");
      }
    } catch (e) {
      throw Exception("Firestore update error: $e");
    }
  }

  /// 4. Generate random password
  void generateRandomPassword() {
    const chars =
        "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789@#%^*!?";
    final rand = Random.secure();

    generatedPassword.value = List.generate(
      10,
      (i) => chars[rand.nextInt(chars.length)],
    ).join();
  }

  /// 5. Send generated password email (after OTP verification passes)
  Future<void> sendNewPassword(String email) async {
    try {
      isPasswordSending.value = true;
      generateRandomPassword();

      // 1. Send password email
      await sendEmailNotification(
        facultyEmail: email,
        userName: "User",
        userEmail: email,
        subject: "Your New Password",
        emailMessage: "Your new password is: ${generatedPassword.value}",
      );

      // 2. Update in Firestore
      await updateFirestorePassword(email);

      isPasswordSending.value = false;
    } catch (e) {
      isPasswordSending.value = false;
      rethrow;
    }
  }
}
