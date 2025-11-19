import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:schedule/controller/profile_controller.dart';
import 'package:schedule/controller/user_controller.dart';
import 'package:schedule/pages/login/login_page.dart';

class ProfilePage extends StatelessWidget {
  final String loggedEmail;

  const ProfilePage({super.key, required this.loggedEmail});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ProfileController(loggedEmail));

    return Scaffold(
      body: Obx(() {
        if (controller.loading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return Container(
          margin: const EdgeInsets.all(20),
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
                    ? "Head of Department"
                    : controller.isAdmin.value
                    ? "Time Table Coordinator"
                    : controller.isSuperAdmin.value
                    ? "Super Admin"
                    : "Faculty",
              ),
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

  Widget _buildLogoutButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.redAccent,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        onPressed: () {
          // Clear user state
          if (Get.isRegistered<UserController>()) {
            final userController = Get.find<UserController>();
            userController.clearUser();
          }

          // Navigate to login page and remove all previous routes
          Get.offAll(() => const LoginPage());
        },
        child: const Text("Logout"),
      ),
    );
  }
}
