import 'dart:convert';
import 'dart:io';

import 'package:device_preview/device_preview.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:schedule/logic/upload_data.dart';
import 'package:schedule/pages/home.dart';
import 'firebase_options.dart';


Future<Map<String, dynamic>> loadJsonFromAssets(String path) async {
  final jsonString = await rootBundle.loadString(path);
  return jsonDecode(jsonString);
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  
  const String jsonPath = 'assets/empty_slots.json';
  
  try {
    final jsonData = await loadJsonFromAssets(jsonPath);
    print("✅ JSON loaded successfully → ${jsonData.keys}");
    
    final uploader = FirestoreSlotUploader();
    await uploader.uploadSlotsFromFile(jsonPath);
  } catch (e) {
    print("❌ Failed to load JSON → $e");
  }


  runApp(DevicePreview(enabled: !kReleaseMode, builder: (context) => MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

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
      home: HomePage(),
    );
  }
}
