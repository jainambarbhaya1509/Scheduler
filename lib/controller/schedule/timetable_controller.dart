import 'package:schedule/imports.dart';


class TimetableController extends GetxController {
  final _firestore = FirestoreService().instance;

  final department = "".obs;
  final classNo = "".obs;
  final running = false.obs;
  final status = "".obs;

  String? path;

  static const maxBatchOps = 450;

  final _sessionController = Get.put(SessionController());

  void setRunning(bool v) => running.value = v;

  /// Pick and process file (web + mobile compatible)
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
        withData: true, // required for web
      );

      if (result == null || result.files.isEmpty) {
        status.value = "No file selected.";
        setRunning(false);
        return;
      }

      final file = result.files.single;

      List<Map<String, dynamic>> jsonResults;

      if (GetPlatform.isWeb) {
        // Web: use bytes
        if (file.bytes == null) {
          status.value = "Invalid web file.";
          setRunning(false);
          return;
        }

        status.value = "Converting Excel (web)...";
        jsonResults = await excelToJsonBytes(
          department.value,
          file.bytes!,
          saveHtml: false,
          saveJson: false,
          fileName: file.name,
        );
      } else {
        // Mobile/Desktop: use file path
        if (file.path == null) {
          status.value = "Invalid file path.";
          setRunning(false);
          return;
        }

        path = file.path;
        logger.d('Picked file path: $path');

        status.value = "Converting Excel...";
        jsonResults = await excelToJsonFile(
          department.value,
          path!,
          saveHtml: false,
          saveJson: false,
        );
      }

      status.value = "Uploading to Firestore...";
      await _uploadSlotsFromJsonList(jsonResults);

      status.value = "Success: Uploaded!";
    } catch (e, st) {
      status.value = "Error: $e";
      ErrorHandler.showError(e);
      logger.d("pickFileAndProcess error: $e");
      logger.d(st.toString());
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
          logger.d("Skipping invalid JSON: $data");
          continue;
        }

        final section = className.contains('L') ? "Labs" : "Classrooms";
        logger.d("Processing section: $section for class $className");

        await _uploadClassSlots(departmentName, className, section, slotDays);
      } catch (e, st) {
        logger.d("Error uploading slots: $e");
        logger.d(st.toString());
      }
    }

    logger.d("All slots upload attempts completed.");
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

      // Ensure space for metadata writes (4 writes reserved)
      if (ops + 4 > maxBatchOps) {
        await batch.commit();
        batch = _firestore.batch();
        ops = 0;
      }

      // Write metadata (4 writes)
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
        final parsed = _parseSlotTime(slotId);
        final start = parsed.start;
        final end = parsed.end;

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

      logger.d("Prepared uploads for → $day / $departmentName / $section");
    }

    if (ops > 0) {
      await batch.commit();
    }
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
    batch.set(classRef,
        {"className": className, "createdAt": now, "lastUpdated": now},
        SetOptions(merge: true));
  }

  /// Parse slot time string into start & end
  ({String start, String end}) _parseSlotTime(String slotId) {
    final parts = slotId.split('-');
    return (
      start: parts.isNotEmpty ? parts.first.trim() : slotId,
      end: parts.length > 1 ? parts.sublist(1).join('-').trim() : slotId,
    );
  }
}
