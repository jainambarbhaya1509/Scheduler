import 'package:flutter/material.dart';
import 'package:get/get.dart';
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
                  print(123);
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
