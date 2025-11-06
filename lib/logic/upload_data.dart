import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreSlotUploader {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Uploads JSON data to Firestore with structure:
  /// slots/{day}/departments/{department}/{section}/{classNo}/slots/{slot_time}
  ///
  /// - If class contains 'L' → goes to "Labs"
  /// - Else → goes to "Classrooms"
  Future<void> uploadSlotsFromFile(String assetPath) async {
    try {
      // Load and decode JSON file
      final String jsonString = await rootBundle.loadString(assetPath);
      final Map<String, dynamic> data = jsonDecode(jsonString);

      final department = data["department"]?.toString();
      final className = data["class"]?.toString();
      final slotDays = data["slots"] as List?;

      if (department == null || className == null || slotDays == null) {
        throw Exception("❌ Invalid JSON: Missing 'department', 'class', or 'slots'");
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

        // Level 1: Create/ensure day document
        final dayRef = _firestore.collection("slots").doc(day);
        await dayRef.set({
          "createdAt": FieldValue.serverTimestamp(),
          "lastUpdated": FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));

        // Level 2: Create/ensure department document
        final deptRef = dayRef.collection("departments").doc(department);
        await deptRef.set({
          "createdAt": FieldValue.serverTimestamp(),
          "lastUpdated": FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));

        // Level 3: Create/ensure section document
        final sectionRef = deptRef.collection(section).doc("_meta");
        await sectionRef.set({
          "sectionType": section,
          "createdAt": FieldValue.serverTimestamp(),
          "lastUpdated": FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));

        // Level 4: Create/ensure class document
        final classRef = deptRef.collection(section).doc(className);
        await classRef.set({
          "className": className,
          "createdAt": FieldValue.serverTimestamp(),
          "lastUpdated": FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));

        // Level 5: Upload each empty slot as a separate document
        for (var slotTime in emptySlots) {
          final slotRef = classRef.collection("slots").doc(slotTime);
          await slotRef.set({
            "start_time": slotTime.split('-').first,
            "end_time": slotTime.split('-').last,
            "isEmpty": true,
            "reservedBy": null,
            "status": "available",
            "createdAt": FieldValue.serverTimestamp(),
            "lastUpdated": FieldValue.serverTimestamp(),
          });
        }

        print("✅ Uploaded slots for → $day / $department / $section / $className");
      }

      print("🎉 All slot documents uploaded successfully!");
    } catch (e, st) {
      print("❌ Error uploading slots: $e");
      print(st);
    }
  }
}
