import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreSlotUploader {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Uploads JSON data to Firestore with structure:
  /// slot_test/{day}/{department}/{section}/{class}/{slot_time}
  ///
  /// If class contains 'L' → goes to "Labs"
  /// Else → goes to "Classrooms"
  Future<void> uploadSlotsFromFile(String assetPath) async {
    try {
      // Load and decode JSON
      final String jsonString = await rootBundle.loadString(assetPath);
      final Map<String, dynamic> data = jsonDecode(jsonString);

      final department = data["department"]?.toString();
      final className = data["class"]?.toString();
      final slots = data["slots"] as List?;

      if (department == null || className == null || slots == null) {
        throw Exception("❌ Invalid JSON: Missing 'department', 'class', or 'slots'");
      }

      // Determine section type
      final section = className.contains('L') ? "Labs" : "Classrooms";
      print("📁 Detected section type: $section for class $className");

      for (var slot in slots) {
        final day = slot["day"]?.toString();
        final emptySlots = slot["empty_slots"] as List?;

        if (day == null || emptySlots == null) {
          print("⚠️ Skipping invalid slot entry → $slot");
          continue;
        }

        for (var slotTime in emptySlots) {
          final docRef = _firestore
              .collection("slot_test")
              .doc(day)
              .collection(department)
              .doc(section)
              .collection(className)
              .doc(slotTime); // each slot = separate document

          await docRef.set({
            "day": day,
            "time": slotTime,
            "description": "extra",
            "isbooked": "",
            "status": "booked",
            "uuid": "",
          });
        }

        print("✅ Uploaded all slots for → $day / $department / $section / $className");
      }

      print("🎉 All time slot documents uploaded successfully!");
    } catch (e, st) {
      print("❌ Error uploading slots: $e");
      print("Stack trace:\n$st");
    }
  }
}
