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
              // Logo
              Image.asset(
                "assets/icon.png",
                height: MediaQuery.sizeOf(context).height / 4,
                width: MediaQuery.sizeOf(context).width / 4,
              ),

              const Text(
                "Scheduler Login",
                style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 30),

              _buildLoginCard(context, controller),

              // Forgot password
              TextButton(
                onPressed: () {
                  Get.snackbar("Coming soon", "Forgot password feature");
                },
                style: ButtonStyle(
                  padding: WidgetStateProperty.all(EdgeInsets.zero),
                  minimumSize: WidgetStateProperty.all(Size.zero),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  overlayColor:
                      WidgetStateProperty.all(Colors.transparent),
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

  /// Login Card UI
  Widget _buildLoginCard(BuildContext context, LoginController controller) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 25),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
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

  /// Login Button
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
                    Get.offAll(
                      () => HomePage(
                        loggedEmail: email,
                        isHOD: user["isHOD"] ?? false,
                        isAdmin: user["isAdmin"] ?? false,
                        isSuperAdmin: user["isSuperAdmin"] ?? false,
                      ),
                    );
                  }
                },
          label: controller.isLoading.value
              ? const Text(
                  "Loading…",
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.w500),
                )
              : const Text(
                  "Login",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
          icon: const Icon(Icons.arrow_right_alt_rounded),
          style: TextButton.styleFrom(
            backgroundColor: Colors.black,
            foregroundColor: Colors.white,
            padding:
                const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
      );
    });
  }

  /// Field decoration
  InputDecoration _buildInputDecoration(String hint) {
    return InputDecoration(
      filled: true,
      fillColor: Colors.grey[200],
      hintText: hint,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide.none,
      ),
      contentPadding:
          const EdgeInsets.symmetric(vertical: 12, horizontal: 15),
    );
  }
}
