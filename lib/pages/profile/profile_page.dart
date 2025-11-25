import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:schedule/controller/login_controller.dart';
import 'package:schedule/controller/profile_controller.dart';
import 'package:schedule/controller/session_controller.dart';
import 'package:schedule/controller/user_controller.dart';
import 'package:schedule/pages/login/login_page.dart';

class ProfilePage extends StatelessWidget {
  final String loggedEmail;

  ProfilePage({super.key, required this.loggedEmail});

  final loginController = Get.put(LoginController());

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ProfileController(loggedEmail));

    return Scaffold(
      body: Obx(() {
        if (controller.loading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return Container(
          margin: const EdgeInsets.only(bottom: 20),
          padding: EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Profile Details",
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 30),
              _buildInfoTile("Name", controller.username.value),
              _buildInfoTile("Email", controller.email.value),
              _buildInfoTile(
                "Role",
                controller.isHOD.value
                    ? "Head of Department / Faculty"
                    : controller.isAdmin.value &&
                          !controller.isSuperAdmin.value &&
                          !controller.isHOD.value
                    ? "Time Table Coordinator / Faculty"
                    : controller.isSuperAdmin.value
                    ? "Super Admin"
                    : "Faculty",
              ),
              const SizedBox(height: 30),

              Text(
                "Change Password",
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              _buildChangePassword(),
              const Spacer(),

              _buildLogoutButton(),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildInfoTile(String title, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(value),
        ],
      ),
    );
  }

  Widget _buildChangePassword() {
    return Column(
      children: [
        _buildInputContainer(
          child: TextFormField(
            controller: loginController.oldPasswordController,
            decoration: const InputDecoration(
              border: InputBorder.none,
              hintText: "Enter Old Password",
              hintStyle: TextStyle(color: Colors.grey),
            ),
          ),
        ),
        const SizedBox(height: 15),
        _buildInputContainer(
          child: TextFormField(
            controller: loginController.newPasswordController,
            decoration: const InputDecoration(
              border: InputBorder.none,
              hintText: "Enter New Password",
              hintStyle: TextStyle(color: Colors.grey),
            ),
          ),
        ),
        const SizedBox(height: 15),
        _buildSubmitButton(),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      child: TextButton(
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.all(Colors.black87),
          padding: WidgetStateProperty.all(
            const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
          ),
          shape: WidgetStateProperty.all(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        onPressed: loginController.changePassword,
        child: const Text(
          "Reset Password",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
        ),
      ),
    );
  }

  Widget _buildInputContainer({required Widget child}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(10),
      ),
      child: child,
    );
  }

  Widget _buildLogoutButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.redAccent,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
        ),
        onPressed: () {
          // Clear user state
          if (Get.isRegistered<UserController>()) {
            final userController = Get.find<UserController>();
            final session = Get.find<SessionController>();

            userController.clearUser();
            session.clearSession();
          }

          // Navigate to login page and remove all previous routes
          Get.offAll(() => const LoginPage());
        },
        child: const Text("Logout"),
      ),
    );
  }
}
