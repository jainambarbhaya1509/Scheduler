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

  List<String> get classOptions =>
      departmentData[department.value] ?? [];

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
        path!,
        null,
        saveHtml: false,
        saveJson: false,
      );

      status.value = "Uploading extracted slots to Firestore...";

      await _uploadSlotsFromJson(
        jsonResult,
        department: department.value,
        className: classNo.value,
      );

      status.value = "Success: Uploaded!";
    } catch (e) {
      status.value = "Error: $e";
    } finally {
      setRunning(false);
    }
  }

  Future<void> _uploadSlotsFromJson(
    Map<String, dynamic> data, {
    required String department,
    required String className,
  }) async {
    final slotDays = data["slots"] as List? ?? [];

    if (slotDays.isEmpty) {
      throw Exception("No slots found in file");
    }

    for (var dayData in slotDays) {
      final day = dayData["day"]?.toString();
      final emptySlots = (dayData["empty_slots"] as List?)
          ?.map((e) => e.toString())
          .toList();

      if (day == null || emptySlots == null) continue;

      final dayRef = _firestore.collection("slots").doc(day);

      await dayRef.set({
        "lastUpdated": Timestamp.now(),
      }, SetOptions(merge: true));

      final deptRef = dayRef.collection("departments").doc(department);
      await deptRef.set({
        "lastUpdated": Timestamp.now(),
      }, SetOptions(merge: true));

      final classRef = deptRef.collection("classes").doc(className);
      await classRef.set({
        "className": className,
        "lastUpdated": Timestamp.now(),
      }, SetOptions(merge: true));

      for (var slotTime in emptySlots) {
        final parts = slotTime.split('-').map((e) => e.trim()).toList();
        final start = parts.isNotEmpty ? parts.first : "";
        final end = parts.length > 1 ? parts.last : "";

        await classRef.collection("slots").doc(slotTime).set({
          "start_time": start,
          "end_time": end,
          "applications": {},
          "lastUpdated": Timestamp.now(),
        });
      }
    }
  }
}
