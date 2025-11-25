import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:schedule/controller/session_controller.dart';
import 'package:schedule/pages/home.dart';
import 'package:schedule/pages/login/login_page.dart';

class SplashPage extends StatelessWidget {
  SplashPage({super.key});

  final session = Get.find<SessionController>();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: session.getSession(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final data = snapshot.data!;
        final uuid = data["uuid"];

        if (uuid == null) {
          return LoginPage();
        }

        return HomePage(
          loggedEmail: data["email"],
          isHOD: data["isHOD"],
          isAdmin: data["isAdmin"],
          isSuperAdmin: data["isSuperAdmin"],
        );
      },
    );
  }
}
