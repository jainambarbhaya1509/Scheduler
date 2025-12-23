import 'package:schedule/imports.dart';

class TimetableController extends GetxController {
  final _firestore = FirestoreService().instance;

  final department = "".obs;
  final classNo = "".obs;
  final running = false.obs;
  final status = "".obs;
  final classes = [].obs;
  String? path;

  static const maxBatchOps = 450;

  final _sessionController = Get.put(SessionController());

  void setRunning(bool v) => running.value = v;

  @override
  void onInit() {
    super.onInit();
    fetchUploadedClass();
  }

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

      late List<Map<String, dynamic>> jsonResults;

      if (GetPlatform.isWeb) {
        // Web: use bytes
        if (file.bytes == null) {
          status.value = "Invalid web file.";
          setRunning(false);
          return;
        }

        status.value = "Converting Excel (web)...";

        // Destructure the named record
        final (:results, :classes) = await excelToJsonBytes(
          department.value,
          file.bytes!,
          saveHtml: false,
          saveJson: false,
          fileName: file.name,
        );
        await _uploadClasses(classes, department.value);
        jsonResults = results;
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

        // Destructure the named record
        final (:results, :classes) = await excelToJsonFile(
          department.value,
          path!,
          saveHtml: false,
          saveJson: false,
        );
        await _uploadClasses(classes, department.value);
        jsonResults = results;
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

  void fetchUploadedClass() {
    _sessionController.getSession().then((session) {
      department.value = session['department'] ?? '';
      if (department.value.isEmpty) return;

      _firestore
          .collection("classes")
          .doc(department.value)
          .collection("deptData")
          .snapshots()
          .listen(
            (snapshot) {
              classes.value = snapshot.docs.map((doc) => doc.id).toList();
            },
            onError: (e) {
              classes.value = [];
              logger.e("Error fetching classes realtime: $e");
            },
          );
    });
  }

  Future<void> deleteClass(String roomId) async {
    try {
      final session = await _sessionController.getSession();
      final dept = session['department'] ?? '';
      if (dept.isEmpty) return;

      final batch = _firestore.batch();

      // 1️⃣ Delete from classes collection
      final classDoc = _firestore
          .collection("classes")
          .doc(dept)
          .collection("deptData")
          .doc(roomId);
      batch.delete(classDoc);

      // 2️⃣ Delete from slots collection dynamically
      final slotsCollection = _firestore.collection("slots");
      final daysSnapshot = await slotsCollection.get(); // fetch all days
      final subCol = roomId.contains("L") ? "Labs" : "Classrooms";

      for (var dayDoc in daysSnapshot.docs) {
        final day = dayDoc.id;

        final roomDocRef = slotsCollection
            .doc(day)
            .collection("departments")
            .doc(dept)
            .collection(subCol)
            .doc(roomId);

        final docSnapshot = await roomDocRef.get();
        if (docSnapshot.exists) {
          batch.delete(roomDocRef);
        }
      }

      // 3️⃣ Delete from requests collection
      final requestsCollection = _firestore
          .collection("requests")
          .doc(dept)
          .collection("requests_list");

      final requestsSnapshot = await requestsCollection
          .where('roomId', isEqualTo: roomId)
          .get();

      for (var requestDoc in requestsSnapshot.docs) {
        batch.delete(requestsCollection.doc(requestDoc.id));
      }

      // 4️⃣ Commit the batch
      await batch.commit();

      // 5️⃣ Update local list
      classes.remove(roomId);

      logger.i("Class $roomId deleted successfully in a single batch.");
    } catch (e) {
      logger.e("Error deleting class $roomId: $e");
    }
  }

  Future<void> _uploadClasses(List<String> classes, String department) async {
    try {
      final deptRef = _firestore.collection("classes").doc(department);
      await deptRef.set({'createdAt': FieldValue.serverTimestamp()});
      for (final className in classes) {
        final classDocRef = deptRef.collection("deptData").doc(className);

        await classDocRef.set({
          'name': className,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }

      print("All classes uploaded successfully for department $department.");
    } catch (e) {
      print("Error uploading classes: $e");
    }
  }

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
      _createMetadataWrites(
        batch,
        day,
        departmentName,
        section,
        className,
        now,
      );
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

    batch.set(dayRef, {
      "createdAt": now,
      "lastUpdated": now,
    }, SetOptions(merge: true));
    batch.set(deptRef, {
      "createdAt": now,
      "lastUpdated": now,
    }, SetOptions(merge: true));
    batch.set(sectionRef, {
      "sectionType": section,
      "createdAt": now,
      "lastUpdated": now,
    }, SetOptions(merge: true));
    batch.set(classRef, {
      "className": className,
      "createdAt": now,
      "lastUpdated": now,
    }, SetOptions(merge: true));
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
