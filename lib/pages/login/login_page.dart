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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Scheduler",
              style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 30),

            // LOGIN CARD
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 25),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color.fromARGB(34, 193, 193, 193),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  const Text(
                    "Login",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 20),

                  // EMAIL
                  TextFormField(
                    controller: controller.emailController,
                    decoration: _inputDecoration("Email"),
                  ),

                  const SizedBox(height: 12),

                  // PASSWORD
                  TextFormField(
                    controller: controller.passwordController,
                    decoration: _inputDecoration("Password"),
                    obscureText: true,
                  ),

                  const SizedBox(height: 20),

                  // LOGIN BUTTON
                  Obx(() {
                    return TextButton.icon(
                      iconAlignment: IconAlignment.end,
                      onPressed: controller.isLoading.value
                          ? null
                          : () async {
                              final user = await controller.login();

                              if (user != null) {
                                // extract data
                                final email = controller.emailController.text
                                    .trim();
                                final isHOD = user["isHOD"] ?? false;

                                Get.off(
                                  () => HomePage(
                                    loggedEmail: email,
                                    isHOD: isHOD,
                                  ),
                                );
                              }
                            },
                      label: controller.isLoading.value
                          ? const Text("Loading…")
                          : const Text(
                              "Login",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                      icon: const Icon(Icons.arrow_right_alt_rounded),
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.grey[900],
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 25,
                          vertical: 10,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
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
