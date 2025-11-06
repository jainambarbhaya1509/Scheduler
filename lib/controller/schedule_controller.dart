import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:schedule/models/availability_model.dart';

class ScheduleController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  RxList<DepartmentAvailabilityModel> departmentAvailabilityList =
      <DepartmentAvailabilityModel>[].obs;

  /// Fetch availability for a given day
  Future<void> fetchAvailabilityForDay(String day) async {
    print("🔍 Fetching availability for day: $day");

    try {
      departmentAvailabilityList.clear();

      // Get all departments for that day
      final deptSnapshot = await _firestore
          .collection("slots")
          .doc(day)
          .collection("departments")
          .get();

      if (deptSnapshot.docs.isEmpty) {
        print("⚠️ No departments found for $day");
        return;
      }

      print("📦 Found ${deptSnapshot.docs.length} departments");

      // For each department, count classrooms and labs
      for (var deptDoc in deptSnapshot.docs) {
        final departmentId = deptDoc.id;
        print("🏢 Department: $departmentId");

        int classroomCount = 0;
        int labCount = 0;

        try {
          // Fetch Classrooms subcollection (ignore _meta)
          final classroomSnapshot = await _firestore
              .collection("slots")
              .doc(day)
              .collection("departments")
              .doc(departmentId)
              .collection("Classrooms")
              .get();

          classroomCount = classroomSnapshot.docs
              .where((doc) => doc.id != "_meta") // 👈 ignore _meta doc
              .length;
          print("🏫 $departmentId → Classrooms: $classroomCount");

          // Fetch Labs subcollection (ignore _meta)
          final labSnapshot = await _firestore
              .collection("slots")
              .doc(day)
              .collection("departments")
              .doc(departmentId)
              .collection("Labs")
              .get();

          labCount = labSnapshot.docs
              .where((doc) => doc.id != "_meta")
              .length; // 👈 ignore _meta doc
          print("🔬 $departmentId → Labs: $labCount");
        } catch (subError) {
          print(
            "⚠️ Error fetching subcollections for $departmentId: $subError",
          );
        }

        // Add department data to observable list
        departmentAvailabilityList.add(
          DepartmentAvailabilityModel(
            id: departmentId,
            deprtmantName: departmentId,
            totalAvailableClass: classroomCount.toString(),
            totalLabs: labCount.toString(),
            totalClass: (classroomCount + labCount).toString(),
          ),
        );
      }

      print("🎉 Availability fetched successfully");
    } catch (e, st) {
      print("❌ Error fetching availability: $e");
      print(st);
    }
  }

  Future<Map<String, List<Map<String, dynamic>>>> fetchAvailableRooms(
    String department,
  ) async {
    try {
      print("🔍 Fetching available rooms for department: $department");

      final Map<String, List<Map<String, dynamic>>> availableData = {
        "Classrooms": [],
        "Labs": [],
      };

      final sections = ["Classrooms", "Labs"];

      // Iterate through both sections
      for (final section in sections) {
        // Get all classes under this section
        final classesSnapshot = await _firestore
            .collectionGroup("slots")
            .where("status", isEqualTo: "available")
            .where("isEmpty", isEqualTo: true)
            .get();

        for (final doc in classesSnapshot.docs) {
          final pathSegments = doc.reference.path.split("/");
          // path: slots/{day}/departments/{department}/{section}/{className}/slots/{slotTime}
          final docDepartment = pathSegments[3];
          final docSection = pathSegments[4];
          final className = pathSegments[5];
          final slotTime = pathSegments.last;

          // Filter by selected department and section
          if (docDepartment == department && sections.contains(docSection)) {
            availableData[docSection]!.add({
              "day": pathSegments[1],
              "department": docDepartment,
              "section": docSection,
              "className": className,
              "slotTime": slotTime,
              ...doc.data(),
            });
          }
        }
      }

      print("✅ Fetched available data for $department");
      return availableData;
    } catch (e, st) {
      print("❌ Error fetching available rooms: $e");
      print(st);
      return {};
    }
  }
}
