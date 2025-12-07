import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:schedule/controller/forget_password_controller.dart';
import 'package:schedule/controller/login_controller.dart';
import 'package:schedule/pages/home.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(LoginController());

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Image.asset(
                  "assets/icon.png",
                  height: MediaQuery.sizeOf(context).height / 4,
                  width: MediaQuery.sizeOf(context).width / 4,
                ),
              ),

              const Text(
                "Scheduler Login",
                style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 30),
              _buildLoginCard(context, controller),
              TextButton(
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.white,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(20),
                      ),
                    ),
                    builder: (BuildContext builder) {
                      return GetBuilder<ForgetPasswordController>(
                        init: ForgetPasswordController(),
                        builder: (logic) {
                          return SizedBox(
                            height: MediaQuery.sizeOf(context).height / 3,
                            child: Padding(
                              padding: EdgeInsets.only(
                                left: 25,
                                right: 25,
                                top: 20,
                                bottom:
                                    MediaQuery.of(context).viewInsets.bottom +
                                    20,
                              ),
                              child: Obx(() {
                                return Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    // ---------- Title ----------
                                    Text(
                                      "Forgot Password?",
                                      style: const TextStyle(
                                        color: Colors.black87,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),

                                    const SizedBox(height: 20),

                                    // ---------- Email Input ----------
                                    TextFormField(
                                      controller: logic.emailController,
                                      decoration: _buildInputDecoration(
                                        "Email",
                                      ),
                                    ),

                                    const SizedBox(height: 15),

                                    // ---------- SEND OTP BUTTON ----------
                                    if (logic.showOtpField.value == false)
                                      SizedBox(
                                        width: double.infinity,
                                        child: TextButton.icon(
                                          iconAlignment: IconAlignment.end,
                                          onPressed: logic.isOtpSending.value
                                              ? null
                                              : () async {
                                                  await logic.sendOtp(
                                                    logic.emailController.text,
                                                  );
                                                  logic.showOtpField.value =
                                                      true;
                                                },
                                          label: Text(
                                            logic.isOtpSending.value
                                                ? "Sending..."
                                                : "Send Code",
                                          ),
                                          icon: const Icon(
                                            Icons.arrow_right_alt_rounded,
                                          ),
                                          style: TextButton.styleFrom(
                                            backgroundColor: Colors.grey[900],
                                            foregroundColor: Colors.white,
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 25,
                                              vertical: 10,
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                          ),
                                        ),
                                      ),

                                    // ---------- OTP FIELD ----------
                                    if (logic.showOtpField.value) ...[
                                      TextFormField(
                                        controller: logic.otpController,
                                        keyboardType: TextInputType.number,
                                        decoration: _buildInputDecoration(
                                          "Enter OTP",
                                        ),
                                      ),
                                      const SizedBox(height: 15),

                                      // ---------- VERIFY OTP BUTTON ----------
                                      SizedBox(
                                        width: double.infinity,
                                        child: TextButton.icon(
                                          iconAlignment: IconAlignment.end,
                                          onPressed:
                                              logic.isPasswordSending.value
                                              ? null
                                              : () async {
                                                  if (logic.verifyOtp(
                                                    logic.otpController.text,
                                                  )) {
                                                    await logic.sendNewPassword(
                                                      logic
                                                          .emailController
                                                          .text,
                                                    );

                                                    Get.snackbar(
                                                      "Success",
                                                      "New password sent to your email",
                                                      snackPosition:
                                                          SnackPosition.BOTTOM,
                                                    );

                                                    Get.back();
                                                  } else {
                                                    Get.snackbar(
                                                      "Error",
                                                      "Invalid OTP",
                                                      snackPosition:
                                                          SnackPosition.BOTTOM,
                                                    );
                                                  }
                                                },
                                          label: Text(
                                            logic.isPasswordSending.value
                                                ? "Verifying..."
                                                : "Verify Code",
                                          ),
                                          icon: const Icon(
                                            Icons.check_circle_outline,
                                          ),
                                          style: TextButton.styleFrom(
                                            backgroundColor: Colors.grey[900],
                                            foregroundColor: Colors.white,
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 25,
                                              vertical: 10,
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ],
                                );
                              }),
                            ),
                          );
                        },
                      );
                    },
                  );
                },
                style: ButtonStyle(
                  padding: WidgetStateProperty.all(EdgeInsets.zero),
                  minimumSize: WidgetStateProperty.all(Size.zero),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  overlayColor: WidgetStateProperty.all(
                    Colors.white,
                  ), // optional: remove ripple padding
                ),
                child: const Text(
                  "Forgot Password ?",
                  style: TextStyle(color: Colors.black87),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Extracted login card widget
  Widget _buildLoginCard(BuildContext context, LoginController controller) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 25),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        // color: const Color.fromARGB(34, 193, 193, 193),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          // const SizedBox(height: 20),
          TextFormField(
            controller: controller.emailController,
            decoration: _buildInputDecoration("Email"),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: controller.passwordController,
            decoration: _buildInputDecoration("Password"),
            obscureText: true,
          ),
          const SizedBox(height: 20),
          _buildLoginButton(controller),
        ],
      ),
    );
  }

  /// Extracted login button widget
  Widget _buildLoginButton(LoginController controller) {
    return Obx(() {
      return SizedBox(
        width: double.infinity,
        child: TextButton.icon(
          iconAlignment: IconAlignment.end,
          onPressed: controller.isLoading.value
              ? null
              : () async {
                  final user = await controller.login();

                  if (user != null) {
                    final email = controller.emailController.text.trim();
                    final isHOD = user["isHOD"] ?? false;
                    final isAdmin = user["isAdmin"] ?? false;
                    final isSuperAdmin = user["isSuperAdmin"] ?? false;
                    Get.off(
                      () => HomePage(
                        loggedEmail: email,
                        isHOD: isHOD,
                        isAdmin: isAdmin,
                        isSuperAdmin: isSuperAdmin,
                      ),
                    );
                  }
                },
          label: controller.isLoading.value
              ? const Text(
                  "Loading…",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                )
              : const Text(
                  "Login",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
          icon: const Icon(Icons.arrow_right_alt_rounded),
          style: TextButton.styleFrom(
            backgroundColor: Colors.grey[900],
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
      );
    });
  }

  /// Extracted input decoration helper
  InputDecoration _buildInputDecoration(String hint) {
    return InputDecoration(
      filled: true,
      fillColor: Colors.grey[200],
      hintText: hint,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 15),
    );
  }
}
