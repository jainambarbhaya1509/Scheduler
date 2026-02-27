import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:schedule/controller/session/session_controller.dart';

import 'package:schedule/pages/splash_page.dart';
import 'package:schedule/services/notification_service.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  Get.put(SessionController());

  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await NotificationService.initialize();

      String? token = await NotificationService.getToken();
      print("FCM TOKEN: $token");
    });
  }

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Scheduler',
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.white,
        bottomSheetTheme: BottomSheetThemeData(
          backgroundColor: Colors.white,
          showDragHandle: true,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
      home: SplashPage(),
    );
  }
}

// TODO: [change isAdmin -> isTTC and isSuperAdmin -> isAdmin]
