import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:schedule/controller/auth/login_controller.dart';
import 'package:schedule/controller/session/session_controller.dart';
import 'package:schedule/pages/login/login_page.dart';

class ProfilePage extends StatefulWidget {
  final String loggedEmail;
  const ProfilePage({super.key, required this.loggedEmail});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final loginController = Get.put(LoginController());
  final SessionController _sessionController = Get.put(SessionController());

  String username = '';
  String email = '';
  String department = '';
  bool isHOD = false;
  bool isAdmin = false;
  bool isSuperAdmin = false;

  late Future<void> _loadSessionFuture;

  @override
  void initState() {
    super.initState();
    _loadSessionFuture = _loadSessionData();
  }

  Future<void> _loadSessionData() async {
    final session = await _sessionController.getSession();
    setState(() {
      username = session['username'] ?? '';
      email = session['email'] ?? '';
      isHOD = session['isHOD'] ?? false;
      isAdmin = session['isAdmin'] ?? false;
      isSuperAdmin = session['isSuperAdmin'] ?? false;
      department = session['department'] ?? false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _loadSessionFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoTile("Name", username),
            _buildInfoTile("Email", email),
            _buildInfoTile("Department", department),

            _buildInfoTile(
              "Role",
              isHOD
                  ? "Head of Department / Faculty"
                  : isAdmin && !isSuperAdmin && !isHOD
                  ? "Time Table Coordinator / Faculty"
                  : isSuperAdmin
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

            const SizedBox(height: 20),
          ],
        );
      },
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
        onPressed: () async {
          await _sessionController.clearSession();
          Get.offAll(() => const LoginPage());
        },
        child: const Text("Logout"),
      ),
    );
  }
}
