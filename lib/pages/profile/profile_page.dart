import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:schedule/controller/login_controller.dart';
import 'package:schedule/controller/profile_controller.dart';

class ProfilePage extends StatelessWidget {
  final String loggedEmail; // passed from login

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

              _infoTile("Name", controller.username.value),
              _infoTile("Email", controller.email.value),
              _infoTile("Role", controller.isHOD.value ? "HOD" : "Faculty"),

              const Spacer(),

              Center(
                child: SizedBox(
                  width: double.infinity, // 🔥 FULL WIDTH BUTTON
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      foregroundColor: Colors.white, // 🔥 WHITE TEXT
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      textStyle: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold, // 🔥 BOLD TEXT
                      ),
                    ),
                    onPressed: () {
                      Get.offAllNamed("/login");
                    },
                    child: const Text("Logout"),
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _infoTile(String title, String value) {
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
}
