import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:file_picker/file_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:schedule/logic/tt_to_json.dart';

class UploadTTController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final RxString department = RxString('Information Technology');
  final RxString classNo = RxString("");
  final running = false.obs;
  final RxString status = RxString("");
  File? file;
  String? path;

  final Map<String, List<String>> departmentData = {
    'Information Technology': ['64', '65', '66', 'L1', 'L2', 'L3'],
  };

  List<String> get classOptions {
    return departmentData[department.value] ?? [];
  }

  void setStatus(String s) => status.value = s;
  void setRunning(bool v) => running.value = v;

  void resetSelections() {
    classNo.value = "";
  }

  Future<void> pickFileAndProcess() async {
    if (classNo.value.isEmpty) {
      setStatus('Error: Please select Department and Class/Section');
      return;
    }

    setRunning(true);

    setStatus('Picking Excel file...');

    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ["xlsx", "xls"],
      );

      if (result != null) {
        file = File(result.files.single.path!);
        path = file?.path;
      } else {
        return;
      }
      if (result.files.isEmpty) {
        setStatus('No file selected.');
        setRunning(false);
        return;
      }

      if (path == null) {
        setStatus('Could not get file path.');
        setRunning(false);
        return;
      }

      setStatus('Converting Excel to JSON (extracting empty slots)...');

      final Map<String, dynamic> jsonResult = await excelToJson(
        path!,
        null,
        saveHtml: false,
        saveJson: false,
      );

      setStatus('Conversion done. Uploading extracted slots to Firestore...');

      await _uploadSlotsFromJson(
        jsonResult,
        department: department.value,
        className: classNo.value,
      );

      setStatus('Success: Timetable slots uploaded.');
    } on PlatformException catch (e) {
      debugPrint('Platform error: ${e.message}');
      setStatus('Error: File picker not available. Please reinstall the app.');
    } catch (e, st) {
      debugPrint('Error: $e\n$st');
      setStatus('Error: $e');
    } finally {
      setRunning(false);
    }
  }

  Future<void> _uploadSlotsFromJson(
    Map<String, dynamic> data, {
    required String department,
    required String className,
  }) async {
    final slotDays = (data['slots'] as List?) ?? [];

    if (slotDays.isEmpty) {
      throw Exception('No slots found in the parsed JSON.');
    }

    for (var dayData in slotDays) {
      final day = dayData['day']?.toString();
      final emptySlots = (dayData['empty_slots'] as List?)
          ?.map((e) => e.toString())
          .toList();

      if (day == null || emptySlots == null) {
        debugPrint('Skipping invalid day entry: $dayData');
        continue;
      }

      final dayRef = _firestore.collection('slots').doc(day);
      await dayRef.set({
        'createdAt': Timestamp.now(),
        'lastUpdated': Timestamp.now(),
      }, SetOptions(merge: true));

      final deptRef = dayRef.collection('departments').doc(department);
      await deptRef.set({
        'createdAt': Timestamp.now(),
        'lastUpdated': Timestamp.now(),
      }, SetOptions(merge: true));

      final classRef = deptRef.collection('classes').doc(className);
      await classRef.set({
        'className': className,
        'createdAt': Timestamp.now(),
        'lastUpdated': Timestamp.now(),
      }, SetOptions(merge: true));

      for (var slotTime in emptySlots) {
        final s = slotTime.toString();
        final startEnd = s.split('-').map((p) => p.trim()).toList();
        final start = startEnd.isNotEmpty ? startEnd.first : '';
        final end = startEnd.length > 1 ? startEnd.last : '';

        final slotRef = classRef.collection('slots').doc(s);
        await slotRef.set({
          'start_time': start,
          'end_time': end,
          'applications': <String, dynamic>{},
          'createdAt': Timestamp.now(),
          'lastUpdated': Timestamp.now(),
        });
      }

      debugPrint('Uploaded for $day / $department / $className');
    }
  }
}
