import 'dart:io';
import 'package:get/get.dart';
import 'package:file_picker/file_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:schedule/logic/tt_to_json.dart';

class UploadTTController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final RxString department = "".obs;
  final RxString classNo = "".obs;
  final RxBool running = false.obs;
  final RxString status = "".obs;

  File? file;
  String? path;

  /// department → class/lab list
  final Map<String, List<String>> departmentData = {
    'Information Technology': ['64', '65', '66', 'L1', 'L2', 'L3'],
  };

  List<String> get classOptions => departmentData[department.value] ?? [];

  void resetSelections() => classNo.value = "";

  void setRunning(bool v) => running.value = v;

  Future<void> pickFileAndProcess() async {
    if (classNo.value.isEmpty || department.value.isEmpty) {
      status.value = "Please select department & class!";
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

      final Map<String, dynamic> jsonResult = await excelToJson(
        department.value,
        classNo.value,
        path!,
        null,
        saveHtml: false,
        saveJson: false,
      );

      status.value = "Uploading extracted slots to Firestore...";

      await _uploadSlotsFromJson(jsonResult);

      status.value = "Success: Uploaded!";
    } catch (e) {
      status.value = "Error: $e";
    } finally {
      setRunning(false);
    }
  }

  Future<void> _uploadSlotsFromJson(Map<String, dynamic> data) async {
    try {
      // Load and decode JSON file

      final department = data["department"]?.toString();
      final className = data["class"]?.toString();
      final slotDays = data["slots"] as List?;

      if (department == null || className == null || slotDays == null) {
        throw Exception(
          "❌ Invalid JSON: Missing 'department', 'class', or 'slots'",
        );
      }

      // Determine if it's a Lab or Classroom
      final section = className.contains('L') ? "Labs" : "Classrooms";
      print("📁 Detected section: $section for class $className");

      // Iterate over all days in the JSON
      for (var dayData in slotDays) {
        final day = dayData["day"]?.toString();
        final emptySlots = dayData["empty_slots"] as List?;

        if (day == null || emptySlots == null) {
          print("⚠️ Skipping invalid entry: $dayData");
          continue;
        }

        print("📅 Uploading for Day: $day");

        // Level 1: Day document
        final dayRef = _firestore.collection("slots").doc(day);
        await dayRef.set({
          "createdAt": Timestamp.now(),
          "lastUpdated": Timestamp.now(),
        }, SetOptions(merge: true));

        // Level 2: Department
        final deptRef = dayRef.collection("departments").doc(department);
        await deptRef.set({
          "createdAt": Timestamp.now(),
          "lastUpdated": Timestamp.now(),
        }, SetOptions(merge: true));

        // Level 3: Section (_meta)
        final sectionRef = deptRef.collection(section).doc("_meta");
        await sectionRef.set({
          "sectionType": section,
          "createdAt": Timestamp.now(),
          "lastUpdated": Timestamp.now(),
        }, SetOptions(merge: true));

        // Level 4: Class
        final classRef = deptRef.collection(section).doc(className);
        await classRef.set({
          "className": className,
          "createdAt": Timestamp.now(),
          "lastUpdated": Timestamp.now(),
        }, SetOptions(merge: true));

        // Level 5: Slots — each with an empty applications list
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
          "✅ Uploaded slots for → $day / $department / $section / $className",
        );
      }

      print("🎉 All slot documents uploaded successfully!");
    } catch (e, st) {
      print("❌ Error uploading slots: $e");
      print(st);
    }
  }


}
