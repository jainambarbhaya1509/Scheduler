import 'package:schedule/imports.dart';


class ClassAvailabilityModel {
  final String id;
  final bool isClassroom;
  final String className;
  final List<ClassTiming> timingsList;


  // Only to use when you apply date, hour or both filter
  List<ClassTiming>? filteredTimings;
  

  ClassAvailabilityModel({
    required this.id,
    required this.isClassroom,
    required this.className,
    required this.timingsList,
    this.filteredTimings,

  });
}

