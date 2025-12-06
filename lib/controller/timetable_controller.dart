import 'dart:io';
import 'package:get/get.dart';
import 'package:file_picker/file_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:schedule/helper_func/convert_time.dart';
import 'package:schedule/helper_func/tt_to_json.dart';

class UploadTTController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final RxString department = "".obs;
  final RxString classNo = "".obs;
  final RxBool running = false.obs;
  final RxString status = "".obs;

  File? file;
  String? path;

  /// department → class/lab list
  final List<String> departmentData = [
    'Information Technology',
    'Computer Engineering',
  ];

  // List<String> get classOptions => departmentData[department.value] ?? [];

  void resetSelections() => classNo.value = "";

  void setRunning(bool v) => running.value = v;

  Future<void> pickFileAndProcess() async {
    if (department.value.isEmpty) {
      status.value = "Please select department!";
      return;
    }

    setRunning(true);
    status.value = "Picking file...";

    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ["xlsx", "xls"],
        withData: true,
      );

      if (result == null || result.files.isEmpty) {
        status.value = "No file selected.";
        setRunning(false);
        return;
      }

      path = result.files.single.path;
      if (path == null) {
        status.value = "Invalid file path.";
        setRunning(false);
        return;
      }

      status.value = "Converting Excel to JSON...";

      final List<Map<String, dynamic>> jsonResults = await excelToJson(
        department.value,
        path!,
        saveHtml: false,
        saveJson: false,
      );

      status.value = "Uploading extracted slots to Firestore...";

      await _uploadSlotsFromJsonList(jsonResults);

      status.value = "Success: Uploaded!";
    } catch (e) {
      status.value = "Error: $e";
    } finally {
      setRunning(false);
    }
  }

  // Updated function to handle list of JSON objects
  Future<void> _uploadSlotsFromJsonList(
    List<Map<String, dynamic>> jsonList,
  ) async {
    for (var data in jsonList) {
      try {
        data = convertScheduleTo24(data);
        final departmentName = data["department"]?.toString();
        final className = data["class"]?.toString();
        final slotDays = data["slots"] as List?;

        if (departmentName == null || className == null || slotDays == null) {
          print("⚠️ Skipping invalid JSON: $data");
          continue;
        }

        final section = className.contains('L') ? "Labs" : "Classrooms";
        print("📁 Detected section: $section for class $className");

        for (var dayData in slotDays) {
          final day = dayData["day"]?.toString();
          final emptySlots = dayData["empty_slots"] as List?;

          if (day == null || emptySlots == null) continue;

          final dayRef = _firestore.collection("slots").doc(day);
          await dayRef.set({
            "createdAt": Timestamp.now(),
            "lastUpdated": Timestamp.now(),
          }, SetOptions(merge: true));

          final deptRef = dayRef.collection("departments").doc(departmentName);
          await deptRef.set({
            "createdAt": Timestamp.now(),
            "lastUpdated": Timestamp.now(),
          }, SetOptions(merge: true));

          final sectionRef = deptRef.collection(section).doc("_meta");
          await sectionRef.set({
            "sectionType": section,
            "createdAt": Timestamp.now(),
            "lastUpdated": Timestamp.now(),
          }, SetOptions(merge: true));

          final classRef = deptRef.collection(section).doc(className);
          await classRef.set({
            "className": className,
            "createdAt": Timestamp.now(),
            "lastUpdated": Timestamp.now(),
          }, SetOptions(merge: true));

          for (var slotTime in emptySlots) {
            final slotRef = classRef.collection("slots").doc(slotTime);
            await slotRef.set({
              "start_time": slotTime.split('-').first,
              "end_time": slotTime.split('-').last,
              "applications": {},
              "createdAt": Timestamp.now(),
              "lastUpdated": Timestamp.now(),
            });
          }

          print(
            "✅ Uploaded slots for → $day / $departmentName / $section / $className",
          );
        }
      } catch (e, st) {
        print("❌ Error uploading slots: $e");
        print(st);
      }
    }

    print("🎉 All slot documents uploaded successfully!");
  }
}
