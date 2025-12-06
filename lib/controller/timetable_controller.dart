import 'package:get/get.dart';
import 'package:file_picker/file_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:schedule/controller/session_controller.dart';
import 'package:schedule/helper_func/convert_time.dart';
import 'package:schedule/helper_func/tt_to_json.dart';

class UploadTTController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final RxString department = "".obs;
  final RxString classNo = "".obs;
  final RxBool running = false.obs;
  final RxString status = "".obs;

  String? path;

  /// department → class/lab list
  final List<String> departmentData = [
    'Information Technology',
    'Computer Engineering',
  ];

  final SessionController _sessionController = Get.put(SessionController());

  // List<String> get classOptions => departmentData[department.value] ?? [];

  // void resetSelections() => classNo.value = "";

  void setRunning(bool v) => running.value = v;

  Future<void> pickFileAndProcess() async {
    department.value = await _sessionController.getSession().then(
      (session) => session['department'] ?? '',
    );

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

  // Updated function to handle list of JSON objects with safe batching
  Future<void> _uploadSlotsFromJsonList(
    List<Map<String, dynamic>> jsonList,
  ) async {
    const int maxBatchOps = 450; // safe margin under Firestore 500-op limit

    for (var data in jsonList) {
      try {
        data = convertScheduleTo24(data);
        final departmentName = data["department"]?.toString().trim();
        final className = data["class"]?.toString().trim();
        final slotDays = data["slots"] as List?;

        if (departmentName == null || className == null || slotDays == null) {
          print("⚠️ Skipping invalid JSON: $data");
          continue;
        }

        final section = className.contains('L') ? "Labs" : "Classrooms";
        print("📁 Detected section: $section for class $className");

        // Create a batch and op counter for this JSON payload
        WriteBatch batch = _firestore.batch();
        int ops = 0;

        Future<void> commitIfNeeded([int extraOps = 0]) async {
          if (ops + extraOps >= maxBatchOps) {
            await batch.commit();
            batch = _firestore.batch();
            ops = 0;
          }
        }

        for (var dayData in slotDays) {
          final day = dayData["day"]?.toString();
          final emptySlots = dayData["empty_slots"] as List?;

          if (day == null || emptySlots == null) continue;

          final now = Timestamp.now();

          final dayRef = _firestore.collection("slots").doc(day);
          final deptRef = dayRef.collection("departments").doc(departmentName);
          final sectionRef = deptRef.collection(section).doc("_meta");
          final classRef = deptRef.collection(section).doc(className);

          // Ensure we have room for the 4 meta writes before adding them
          await commitIfNeeded(4);
          batch.set(dayRef, {
            "createdAt": now,
            "lastUpdated": now,
          }, SetOptions(merge: true));
          ops++;

          batch.set(deptRef, {
            "createdAt": now,
            "lastUpdated": now,
          }, SetOptions(merge: true));
          ops++;

          batch.set(sectionRef, {
            "sectionType": section,
            "createdAt": now,
            "lastUpdated": now,
          }, SetOptions(merge: true));
          ops++;

          batch.set(classRef, {
            "className": className,
            "createdAt": now,
            "lastUpdated": now,
          }, SetOptions(merge: true));
          ops++;

          for (var slotTime in emptySlots) {
            if (slotTime == null) continue;
            final slotId = slotTime.toString();
            final parts = slotId.split('-');
            final start = parts.isNotEmpty ? parts.first : slotId;
            final end = parts.length > 1 ? parts.last : slotId;

            final slotRef = classRef.collection("slots").doc(slotId);

            // Ensure we have room for this slot write
            await commitIfNeeded(1);
            batch.set(slotRef, {
              "start_time": start,
              "end_time": end,
              "applications": {},
              "createdAt": now,
              "lastUpdated": now,
            }, SetOptions(merge: true));
            ops++;
          }

          // commit intermediate batch for this day if approaching limit (or continue accumulating)
          if (ops > 0 && ops >= (maxBatchOps * 0.8).toInt()) {
            await batch.commit();
            batch = _firestore.batch();
            ops = 0;
          }

          print(
            "✅ Prepared uploads for → $day / $departmentName / $section / $className",
          );
        }

        // commit any remaining operations for this JSON item
        if (ops > 0) {
          await batch.commit();
        }
      } catch (e, st) {
        print("❌ Error uploading slots: $e");
        print(st);
      }
    }

    print("🎉 All slot documents uploaded successfully!");
  }
}
