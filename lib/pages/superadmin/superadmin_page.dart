import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:schedule/controller/superadmin/superadmin_controller.dart';
import 'package:schedule/helper/security/generate_password.dart';
import 'package:schedule/pages/superadmin/manage_faculty_page.dart';

class SuperAdminPage extends StatefulWidget {
  const SuperAdminPage({super.key});

  @override
  State<SuperAdminPage> createState() => _SuperAdminPageState();
}

class _SuperAdminPageState extends State<SuperAdminPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController nameCtrl = TextEditingController();
  final TextEditingController emailCtrl = TextEditingController();
  // final TextEditingController passwordCtrl = TextEditingController();

  String? selectedDept;
  bool isAdmin = false;
  bool isHod = false;

  final List<String> departments = [
    "Information Technology",
    "Computer Engineering",
  ];

  Future<void> submitUser() async {
    if (!_formKey.currentState!.validate()) return;

    Map<String, dynamic> data = {
      "username": nameCtrl.text.trim(),
      "email": emailCtrl.text.trim(),
      "password": generateRandomPassword().trim(),
      "department": selectedDept,
      "isAdmin": isAdmin,
      "isHOD": isHod,
      "isSuperAdmin": false,
    };

    await Get.put(SuperAdminController()).addUser(data);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Faculty Management",
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _textField(nameCtrl, "Enter name"),
                  const SizedBox(height: 16),
                  _textField(emailCtrl, "Enter email"),
                  const SizedBox(height: 16),
                  _departmentDropdown(),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      _toggle("Time Table Coordinator", isAdmin, (v) {
                        setState(() => isAdmin = v);
                      }),
                      const SizedBox(width: 25),
                      _toggle("HOD", isHod, (v) {
                        setState(() => isHod = v);
                      }),
                    ],
                  ),

                  const SizedBox(height: 26),

                  _button(
                    "Add Faculty",
                    Colors.black87,
                    Colors.white,
                    Colors.black87,
                    submitUser,
                  ),
                  const SizedBox(height: 10),
                  _button(
                    "Manage Faculty",
                    Colors.white,
                    Colors.black87,
                    Colors.black87,
                    () {
                      Get.to(
                        () => ManageFacultyPage(),
                        transition: Transition.rightToLeft,
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _button(
    String text,
    Color bgColor,
    Color textColor,
    Color borderColor,
    VoidCallback callback,
  ) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: callback,
        style: ElevatedButton.styleFrom(
          backgroundColor: bgColor,
          foregroundColor: textColor,
          side: BorderSide(color: borderColor),
          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),

        child: Text(
          text,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
      ),
    );
  }

  Widget _textField(
    TextEditingController controller,
    String hint, {
    bool isPassword = false,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword,
      validator: (v) => v!.trim().isEmpty ? "Required" : null,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: const Color(0xFFEDEDED),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _departmentDropdown() {
    return DropdownButtonFormField<String>(
      initialValue: selectedDept,
      hint: const Text("Select Department"),
      validator: (v) => v == null ? "Please select a department" : null,
      decoration: InputDecoration(
        filled: true,
        fillColor: const Color(0xFFEDEDED),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14),
      ),
      items: departments
          .map((dept) => DropdownMenuItem(value: dept, child: Text(dept)))
          .toList(),
      onChanged: (v) => setState(() => selectedDept = v),
    );
  }

  Widget _toggle(String text, bool value, Function(bool) onChange) {
    return Row(
      children: [
        Text(
          text,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
        Switch(
          value: value,
          onChanged: onChange,
          activeThumbColor: Colors.green,
        ),
      ],
    );
  }
}
