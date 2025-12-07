import 'dart:developer';

import 'package:get/get.dart';
import 'package:file_picker/file_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:schedule/controller/session_controller.dart';
import 'package:schedule/helper_func/convert_time.dart';
import 'package:schedule/helper_func/tt_to_json.dart';
import 'package:schedule/services/firestore_service.dart';
import 'package:schedule/services/error_handler.dart';

class TimetableController extends GetxController {
  final _firestore = FirestoreService().instance;

  final department = "".obs;
  final classNo = "".obs;
  final running = false.obs;
  final status = "".obs;

  String? path;

  static const departmentData = [
    'Information Technology',
    'Computer Engineering',
  ];

  static const sections = ["Classrooms", "Labs"];
  static const maxBatchOps = 450;

  final _sessionController = Get.put(SessionController());

  void setRunning(bool v) => running.value = v;

  /// Pick and process file
  Future<void> pickFileAndProcess() async {
    department.value = await _sessionController.getSession().then(
          (session) => session['department'] ?? '',
        );

    setRunning(true);
    status.value = "Picking file...";

    try {
      final result = await FilePicker.platform.pickFiles(
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

      final jsonResults = await excelToJson(
        department.value,
        path!,
        saveHtml: false,
        saveJson: false,
      );

      status.value = "Uploading to Firestore...";
      await _uploadSlotsFromJsonList(jsonResults);

      status.value = "Success: Uploaded!";
    } catch (e) {
      status.value = "Error: $e";
      ErrorHandler.showError(e);
    } finally {
      setRunning(false);
    }
  }

  /// Optimized upload with batching and validation
  Future<void> _uploadSlotsFromJsonList(
    List<Map<String, dynamic>> jsonList,
  ) async {
    for (var data in jsonList) {
      try {
        data = convertScheduleTo24(data);
        final departmentName = data["department"]?.toString().trim();
        final className = data["class"]?.toString().trim();
        final slotDays = data["slots"] as List?;

        if (departmentName == null || className == null || slotDays == null) {
          log("Skipping invalid JSON: $data");
          continue;
        }

        final section = className.contains('L') ? "Labs" : "Classrooms";
        log("Processing section: $section for class $className");

        await _uploadClassSlots(departmentName, className, section, slotDays);
      } catch (e, st) {
        log("Error uploading slots: $e");
        log(st as String);
      }
    }

    log("All slots uploaded successfully!");
  }

  /// Extracted slot upload logic with better batch management
  Future<void> _uploadClassSlots(
    String departmentName,
    String className,
    String section,
    List<dynamic> slotDays,
  ) async {
    var batch = _firestore.batch();
    var ops = 0;
    final now = Timestamp.now();

    for (var dayData in slotDays) {
      final day = dayData["day"]?.toString();
      final emptySlots = dayData["empty_slots"] as List?;

      if (day == null || emptySlots == null) continue;

      // Ensure space for metadata writes
      if (ops + 4 > maxBatchOps) {
        await batch.commit();
        batch = _firestore.batch();
        ops = 0;
      }

      // Write metadata
      _createMetadataWrites(batch, day, departmentName, section, className, now);
      ops += 4;

      // Write slots
      for (var slotTime in emptySlots) {
        if (slotTime == null) continue;

        if (ops >= maxBatchOps) {
          await batch.commit();
          batch = _firestore.batch();
          ops = 0;
        }

        final slotId = slotTime.toString();
        final (:start, :end) = _parseSlotTime(slotId);

        final slotRef = _firestore
            .collection("slots")
            .doc(day)
            .collection("departments")
            .doc(departmentName)
            .collection(section)
            .doc(className)
            .collection("slots")
            .doc(slotId);

        batch.set(slotRef, {
          "start_time": start,
          "end_time": end,
          "applications": {},
          "createdAt": now,
          "lastUpdated": now,
        }, SetOptions(merge: true));

        ops++;
      }

      log("Prepared uploads for → $day / $departmentName / $section");
    }

    if (ops > 0) await batch.commit();
  }

  /// Create metadata writes for day/department/section
  void _createMetadataWrites(
    WriteBatch batch,
    String day,
    String departmentName,
    String section,
    String className,
    Timestamp now,
  ) {
    final dayRef = _firestore.collection("slots").doc(day);
    final deptRef = dayRef.collection("departments").doc(departmentName);
    final sectionRef = deptRef.collection(section).doc("_meta");
    final classRef = deptRef.collection(section).doc(className);

    batch.set(dayRef, {"createdAt": now, "lastUpdated": now},
        SetOptions(merge: true));
    batch.set(deptRef, {"createdAt": now, "lastUpdated": now},
        SetOptions(merge: true));
    batch.set(sectionRef, {
      "sectionType": section,
      "createdAt": now,
      "lastUpdated": now,
    }, SetOptions(merge: true));
    batch.set(classRef, {"className": className, "createdAt": now, "lastUpdated": now},
        SetOptions(merge: true));
  }

  /// Parse slot time string
  ({String start, String end}) _parseSlotTime(String slotId) {
    final parts = slotId.split('-');
    return (
      start: parts.isNotEmpty ? parts.first : slotId,
      end: parts.length > 1 ? parts.last : slotId,
    );
  }
}
